//
//  DDColorWheel.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorWheel.h"

@interface DDColorWheel ()

/**
 *  The currently displayed color wheel. Updated whenever drawRect: is called.
 */
@property (nonatomic, strong) UIImage *colorWheel;

@property (nonatomic, strong, readwrite) UIColor *currentColor;

@property (nonatomic, strong) UIColor *previousColor;

/**
 *  Get the color wheel's color at the given point
 */
- (UIColor *)colorAtPoint:(CGPoint)point;

/**
 *  Check if the given point is inside the color wheel
 */
- (BOOL)isValidPoint:(CGPoint)point;

@end

@implementation DDColorWheel
{
  unsigned char *_pixelData;
  NSUInteger _totalPixels;
  NSUInteger _imageWidth;
  NSUInteger _imageHeight;
}

#pragma mark - Properties

- (void)setColorWheel:(UIImage *)colorWheel
{
  if(colorWheel != _colorWheel)
  {
    if(_pixelData)
    {
      free(_pixelData);
    }
    // Get the image into the data buffer
    CGImageRef imageRef = [colorWheel CGImage];
    _imageWidth = CGImageGetWidth(imageRef);
    _imageHeight = CGImageGetHeight(imageRef);
    
    // Save total ammount of pixels for colorAtPoint:
    _totalPixels = _imageWidth * _imageHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create the buffer (was freed earlier on).
    _pixelData = (unsigned char*) calloc(_imageHeight * _imageWidth * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * _imageWidth;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(_pixelData, _imageWidth, _imageHeight,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, _imageWidth, _imageHeight), imageRef);
    CGContextRelease(context);
  }
  _colorWheel = colorWheel;
}

#pragma mark - Lifecycle

- (void)drawRect:(CGRect)rect
{
  int dim = self.bounds.size.width; // should always be square.
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, dim * dim * 4);
  generateColorWheelBitmap(CFDataGetMutableBytePtr(bitmapData), dim, .5f);
  UIImage *image = createUIImageWithRGBAData(bitmapData, self.bounds.size.width, self.bounds.size.height);
  CFRelease(bitmapData);
  [image drawAtPoint:CGPointZero];
  self.colorWheel = image;
}

- (void)dealloc
{
  if(_pixelData)
  {
    free(_pixelData);
  }
}

#pragma mark - Touch

- (UIColor *)colorAtPoint:(CGPoint)point
{
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * _imageWidth;
  NSUInteger byteIndex = (bytesPerRow * ceilf(point.y)) + ceilf(point.x) * bytesPerPixel;
  CGFloat red   = _pixelData[byteIndex] / 255.0;
  CGFloat green = _pixelData[byteIndex + 1] / 255.0;
  CGFloat blue  = _pixelData[byteIndex + 2] / 255.0;
  CGFloat alpha = _pixelData[byteIndex + 3] / 255.0;
  
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (BOOL)isValidPoint:(CGPoint)point
{
  CGFloat xx = powf(2.f, (point.x - CGRectGetMidX(self.bounds)));
  CGFloat yy = powf(2.f, (point.y - CGRectGetMidY(self.bounds)));
  CGFloat rr = powf(2.f, CGRectGetMidX(self.bounds));
  return (xx + yy) < rr;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.previousColor = self.currentColor;
  CGPoint location = [[touches anyObject] locationInView:self];
  if([self isValidPoint:location])
  {
    self.currentColor = [self colorAtPoint:location];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint location = [[touches anyObject] locationInView:self];
  if([self isValidPoint:location])
  {
    self.currentColor = [self colorAtPoint:location];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
  else
  {
    self.currentColor = self.previousColor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint location = [[touches anyObject] locationInView:self];
  if([self isValidPoint:location])
  {
    self.currentColor = [self colorAtPoint:location];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
  else
  {
    self.currentColor = self.previousColor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

#pragma mark - Color Wheel Code

// http://stackoverflow.com/a/5110332/1132931)

void generateColorWheelBitmap(UInt8 *bitmap, int widthHeight, float l)
{
  // I think maybe you can do 1/3 of the pie, then do something smart to generate the other two parts, but for now we'll brute force it.
  for (int y = 0; y < widthHeight; y++)
  {
    for (int x = 0; x < widthHeight; x++)
    {
      float h, s, r, g, b, a;
      getColorWheelValue(widthHeight, x, y, &h, &s);
      if (s < 1.0)
      {
        // Antialias the edge of the circle.
        if (s > 0.99) a = (1.0 - s) * 100;
        else a = 1.0;
        
        HSL2RGB(h, s, l, &r, &g, &b);
      }
      else
      {
        r = g = b = a = 0.0f;
      }
      
      int i = 4 * (x + y * widthHeight);
      bitmap[i] = r * 0xff;
      bitmap[i+1] = g * 0xff;
      bitmap[i+2] = b * 0xff;
      bitmap[i+3] = a * 0xff;
    }
  }
}

void getColorWheelValue(int widthHeight, int x, int y, float *outH, float *outS)
{
  int c = widthHeight / 2;
  float dx = (float)(x - c) / c;
  float dy = (float)(y - c) / c;
  float d = sqrtf((float)(dx*dx + dy*dy));
  *outS = d;
  *outH = acosf((float)dx / d) / M_PI / 2.0f;
  if (dy < 0) *outH = 1.0 - *outH;
}

UIImage *createUIImageWithRGBAData(CFDataRef data, int width, int height)
{
  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpace,  kCGBitmapByteOrder32Big, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  CGImageRelease(imageRef);
  return image;
}

// Adapted from Apple sample code.  See http://en.wikipedia.org/wiki/HSV_color_space#Comparison_of_HSL_and_HSV
void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
  float temp1, temp2;
  float temp[3];
  int i;
  
  // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
  if(s == 0.0)
  {
    *outR = l;
    *outG = l;
    *outB = l;
    return;
  }
  
  // Test for luminance and compute temporary values based on luminance and saturation
  if(l < 0.5)
    temp2 = l * (1.0 + s);
  else
    temp2 = l + s - l * s;
  temp1 = 2.0 * l - temp2;
  
  // Compute intermediate values based on hue
  temp[0] = h + 1.0 / 3.0;
  temp[1] = h;
  temp[2] = h - 1.0 / 3.0;
  
  for(i = 0; i < 3; ++i)
  {
    // Adjust the range
    if(temp[i] < 0.0)
      temp[i] += 1.0;
    if(temp[i] > 1.0)
      temp[i] -= 1.0;
    
    
    if(6.0 * temp[i] < 1.0)
      temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
    else {
      if(2.0 * temp[i] < 1.0)
        temp[i] = temp2;
      else {
        if(3.0 * temp[i] < 2.0)
          temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
        else
          temp[i] = temp1;
      }
    }
  }
  
  // Assign temporary values to R, G, B
  *outR = temp[0];
  *outG = temp[1];
  *outB = temp[2];
}

@end
