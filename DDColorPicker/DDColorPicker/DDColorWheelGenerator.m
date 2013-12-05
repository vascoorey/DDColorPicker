//
//  DDColorWheelGenerationOperation.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 05/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorWheelGenerator.h"

#import <Accelerate/Accelerate.h>

@interface DDColorWheelGenerator ()

@property BOOL isExecuting;

@property BOOL isFinished;

@property CGFloat lightness;

@property int width;

@property int height;

@property UIImage *generatedImage;

@property (copy) void (^completion)(UIImage *);

@end

@implementation DDColorWheelGenerator

+ (instancetype)generatorWithWidth:(NSUInteger)width height:(NSUInteger)height lightness:(CGFloat)lightness completionBlock:(void (^)(UIImage *))block
{
  return [[self alloc] initWithWidth:width height:height lightness:lightness completionBlock:block];
}

- (id)initWithWidth:(NSUInteger)width height:(NSUInteger)height lightness:(CGFloat)lightness completionBlock:(void (^)(UIImage *))block
{
  if((self = [super init]))
  {
    _lightness = lightness;
    _completion = [block copy];
    _width = (int)width;
    _height = (int)height;
    __weak typeof (self) weakself = self;
    [self setCompletionBlock:^{
      if(weakself.completion && weakself.generatedImage)
      {
        weakself.completion(weakself.generatedImage);
      }
    }];
  }
  return self;
}

- (void)start
{
  if ([self isCancelled])
  {
    // Must move the operation to the finished state if it is canceled.
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  [self willChangeValueForKey:@"isExecuting"];
  [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
  self.isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)main
{
  if ([self isCancelled])
  {
    // Must move the operation to the finished state if it is canceled.
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, self.width * self.width * 4);
  [self generateColorWheelBitmap:CFDataGetMutableBytePtr(bitmapData) side:self.width];
  if ([self isCancelled])
  {
    CFRelease(bitmapData);
    // Must move the operation to the finished state if it is canceled.
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  self.generatedImage = [self imageWithRGBAData:bitmapData width:self.width height:self.height];
  CFRelease(bitmapData);
  [self completeOperation];
}

- (void)completeOperation
{
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  self.isFinished = YES;
  self.isExecuting = NO;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Color Wheel Generation

// http://stackoverflow.com/a/5110332/1132931)

- (void)generateColorWheelBitmap:(UInt8 *)bitmap side:(int)side
{
  // I think maybe you can do 1/3 of the pie, then do something smart to generate the other two parts, but for now we'll brute force it.
  static dispatch_queue_t generatorQueue = nil;
  if(!generatorQueue)
  {
    generatorQueue = dispatch_queue_create("com.deltadog.colorpicker.generatorqueue", DISPATCH_QUEUE_CONCURRENT);
  }
  dispatch_apply((size_t)side, generatorQueue, ^(size_t y) {
    dispatch_apply((size_t)side, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t x) {
      if ([self isCancelled])
      {
        return;
      }
      CGFloat h, s, r, g, b, a;
      [[self class] getColorWheelValue:side x:x y:y toHue:&h saturation:&s];
      
      a = 1.f;
      
      [[self class] hue:h saturation:s lightness:self.lightness toRed:&r green:&g blue:&b];
      
      int i = 4 * (x + y * side);
      bitmap[i] = r * 0xff;
      bitmap[i+1] = g * 0xff;
      bitmap[i+2] = b * 0xff;
      bitmap[i+3] = a * 0xff;
    });
  });
}

- (UIImage *)imageWithRGBAData:(CFDataRef)data width:(NSUInteger)width height:(NSUInteger)height
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

+ (void)getColorWheelValue:(int)side x:(int)x y:(int)y toHue:(CGFloat *)hue saturation:(CGFloat *)saturation
{
  int c = side / 2;
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
  *saturation = d;
  vvacosf(&temp, &calc, &size);
  *hue = temp / M_PI / 2.f;
  //  *outH = acosf((float)dx / d) / M_PI / 2.0f;
  if (dy < 0) *hue = 1.0 - *hue;
}

// Adapted from Apple sample code.  See http://en.wikipedia.org/wiki/HSV_color_space#Comparison_of_HSL_and_HSV
+ (void)hue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness toRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue
{
  float temp1, temp2;
  float temp[3];
  int i;
  
  // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
  if(saturation == 0.0)
  {
    *red = lightness;
    *green = lightness;
    *blue = lightness;
    return;
  }
  
  // Test for luminance and compute temporary values based on luminance and saturation
  if(lightness < 0.5)
    temp2 = lightness * (1.0 + saturation);
  else
    temp2 = lightness + saturation - lightness * saturation;
  temp1 = 2.0 * lightness - temp2;
  
  // Compute intermediate values based on hue
  temp[0] = hue + 1.0 / 3.0;
  temp[1] = hue;
  temp[2] = hue - 1.0 / 3.0;
  
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
  *red = temp[0];
  *green = temp[1];
  *blue = temp[2];
}

@end
