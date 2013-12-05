//
//  DDColorWheel.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorWheel.h"
#import "DDColorWheelGenerator.h"

#import <Accelerate/Accelerate.h>

static CGFloat const kMinimumValue = .005f;

@interface DDColorWheel ()

/**
 *  The currently displayed color wheel. Updated whenever drawRect: is called.
 */
@property (nonatomic, strong) UIImage *colorWheel;

@property (nonatomic, strong, readwrite) UIColor *currentColor;

@property (nonatomic, strong) UIColor *previousColor;

@property (nonatomic, strong) DDColorWheelGenerator *generator;

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
    _imageView.alpha = wheelAlpha;
    [_imageView setNeedsDisplay];
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
  CGFloat hue = 0.f, saturation = 0.f, red = 0.f, green = 0.f, blue = 0.f;
  [DDColorWheelGenerator getColorWheelValue:(int)_imageWidth x:(NSUInteger)point.x y:(NSUInteger)point.y toHue:&hue saturation:&saturation];
  [DDColorWheelGenerator hue:hue saturation:saturation lightness:self.lightness toRed:&red green:&green blue:&blue];
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
//  if(self.generator)
//  {
//    [self.generator cancel];
//    [self.generator setCompletionBlock:nil];
//  }
  self.generator = [DDColorWheelGenerator generatorWithWidth:self.bounds.size.width height:self.bounds.size.height lightness:self.lightness completionBlock:^(UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^{
      _imageView.image = image;
      _imageView.alpha = self.wheelAlpha;
      self.colorWheel = image;
      [self setNeedsDisplay];
    });
  }];
  [self.generator start];
}

@end
