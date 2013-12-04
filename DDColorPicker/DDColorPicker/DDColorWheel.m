//
//  DDColorWheel.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorWheel.h"

#import <Accelerate/Accelerate.h>

static CGFloat const kMinimumValue = .01f;

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
  UIImageView *_imageView;
}

#pragma mark - Class Methods

+ (instancetype)colorWheel
{
  return [[self alloc] init];
}

#pragma mark - Properties

- (void)setColorWheel:(UIImage *)colorWheel
{
  if(colorWheel != _colorWheel)
  {
    CGImageRef imageRef = [colorWheel CGImage];
    _imageWidth = CGImageGetWidth(imageRef);
    _imageHeight = CGImageGetHeight(imageRef);
    
    // Save total ammount of pixels for colorAtPoint:
    _totalPixels = _imageWidth * _imageHeight;
  }
  _colorWheel = colorWheel;
}

- (void)setLightness:(CGFloat)lightness
{
  if(lightness < 0.f)
  {
    lightness = 0.f;
  }
  else if(lightness > 1.f)
  {
    lightness = 1.f;
  }
  if(_lightness != lightness && fabsf(lightness - _lightness) > kMinimumValue)
  {
    _lightness = lightness;
    [self updateColorWheel];
  }
}

- (void)setWheelAlpha:(CGFloat)wheelAlpha
{
  if(wheelAlpha < 0.f)
  {
    wheelAlpha = 0.f;
  }
  else if(wheelAlpha > 1.f)
  {
    wheelAlpha = 1.f;
  }
  if(_wheelAlpha != wheelAlpha && fabsf(wheelAlpha - _wheelAlpha) > kMinimumValue)
  {
    _wheelAlpha = wheelAlpha;
    [self updateColorWheel];
  }
}

#pragma mark - Lifecycle

- (void)setup
{
  self.backgroundColor = [UIColor clearColor];
  _imageView = [[UIImageView alloc] init];
  [self addSubview:_imageView];
  
  [_imageView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  
  self.layer.masksToBounds = YES;
  self.layer.drawsAsynchronously = YES;
}

- (id)init
{
  if((self = [super init]))
  {
    [self setup];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if((self = [super initWithCoder:aDecoder]))
  {
    [self setup];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  if((self = [super initWithFrame:frame]))
  {
    [self setup];
  }
  return self;
}

- (void)dealloc
{
  if(_pixelData)
  {
    free(_pixelData);
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.layer.cornerRadius = .5f * self.bounds.size.width;
  [self updateColorWheel];
}

#pragma mark - Touch

- (UIColor *)colorAtPoint:(CGPoint)point
{
  float hue = 0.f, saturation = 0.f, red = 0.f, green = 0.f, blue = 0.f;
  getColorWheelValue((int)_imageWidth, floorf(point.x), floorf(point.y), &hue, &saturation);
  HSL2RGB(hue, saturation, self.lightness, &red, &green, &blue);
  return [UIColor colorWithRed:red green:green blue:blue alpha:self.wheelAlpha];
}

- (BOOL)isValidPoint:(CGPoint)point
{
  CGFloat dx = fabsf(point.x - (_imageWidth * .5f));
  CGFloat dy = fabsf(point.y - (_imageHeight * .5f));
  CGFloat radius = _imageHeight * .5f;
  if(dx + dy <= radius)
  {
    return YES;
  }
  else if(dx > radius || dy > radius)
  {
    return NO;
  }
  else
  {
    return (powf(dx, 2) + powf(dy, 2)) < powf(radius, 2);
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.previousColor = nil;
  CGPoint location = [[touches anyObject] locationInView:self];
  if([self isValidPoint:location])
  {
    self.previousColor = self.currentColor;
    self.currentColor = [self colorAtPoint:location];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint location = [[touches anyObject] locationInView:self];
  if([self isValidPoint:location])
  {
    if(!self.previousColor)
    {
      self.previousColor = self.currentColor;
    }
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
    if(!self.previousColor)
    {
      self.previousColor = self.currentColor;
    }
    self.currentColor = [self colorAtPoint:location];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
  else if(self.previousColor)
  {
    self.currentColor = self.previousColor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

#pragma mark - Color Wheel Code

- (void)updateColorWheel
{
  if(!(int)self.bounds.size.width)
  {
    return;
  }
  static dispatch_queue_t colorWheelQueue = nil;
  if(!colorWheelQueue)
  {
    colorWheelQueue = dispatch_queue_create("com.deltadog.colorwheelqueue", DISPATCH_QUEUE_CONCURRENT);
  }
  
  int dim = self.bounds.size.width; // should always be square.
  dispatch_async(colorWheelQueue, ^{
    CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
    CFDataSetLength(bitmapData, dim * dim * 4);
    [self generateColorWheelBitmap:CFDataGetMutableBytePtr(bitmapData) side:dim];
    UIImage *image = createUIImageWithRGBAData(bitmapData, self.bounds.size.width, self.bounds.size.height);
    CFRelease(bitmapData);
    dispatch_async(dispatch_get_main_queue(), ^{
      _imageView.image = image;
      _imageView.alpha = self.wheelAlpha;
      self.colorWheel = image;
      [self setNeedsDisplay];
    });
  });
}

// http://stackoverflow.com/a/5110332/1132931)

- (void)generateColorWheelBitmap:(UInt8 *)bitmap side:(int)side 
{
  // I think maybe you can do 1/3 of the pie, then do something smart to generate the other two parts, but for now we'll brute force it.
  for (int y = 0; y < side; y++)
  {
    for (int x = 0; x < side; x++)
    {
      float h, s, r, g, b, a;
      getColorWheelValue(side, x, y, &h, &s);
    
      a = self.wheelAlpha;
      
      HSL2RGB(h, s, self.lightness, &r, &g, &b);
      
      int i = 4 * (x + y * side);
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
  int size = 1;
  float dx = (float)(x - c) / c;
  float dy = (float)(y - c) / c;
  float calc = (float)(dx*dx + dy*dy);
  float temp = 0.f;
  float d = 0.f;
//  float d = sqrtf((float)(dx*dx + dy*dy));
  vvsqrtf(&d, &calc, &size);
  calc = (float)dx / d;
  temp = 0.f;
  *outS = d;
  vvacosf(&temp, &calc, &size);
  *outH = temp / M_PI / 2.f;
//  *outH = acosf((float)dx / d) / M_PI / 2.0f;
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
    
    
    CGFloat test = 6.f * temp[i];
    if(test < 1.0)
      temp[i] = temp1 + (temp2 - temp1) * test;
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
