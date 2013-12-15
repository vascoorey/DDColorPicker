//
//  DDMagnifierView.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 15/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDMagnifierView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDMagnifierView ()

@property (nonatomic, strong) UIView *targetView;

- (id)initWithTargetView:(UIView *)targetView;

@end

@implementation DDMagnifierView

#pragma mark - Class

+ (instancetype)magnifierWithTargetView:(UIView *)targetView
{
  return [[self alloc] initWithTargetView:targetView];
}

#pragma mark - Properties

- (void)setTouchPoint:(CGPoint)touchPoint
{
  _touchPoint = touchPoint;
  // Offset y-axis to take into account the user's finger
  self.center = CGPointMake(touchPoint.x, touchPoint.y - (self.bounds.size.width * .5f));
  [self setNeedsDisplay];
}

#pragma mark - Lifecycle

- (id)initWithTargetView:(UIView *)targetView
{
  if((self = [super init]))
  {
    _targetView = targetView;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 3.f : 2.f;
    self.layer.borderColor = UIColor.blackColor.CGColor;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.layer.cornerRadius = .5f * self.bounds.size.width;
}

/**
 *  http://coffeeshopped.com/2010/03/a-simpler-magnifying-glass-loupe-view-for-the-iphone
 */
- (void)drawRect:(CGRect)rect
{
	// here we're just doing some transforms on the view we're magnifying,
	// and rendering that view directly into this view,
	// rather than the previous method of copying an image.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 2.f, 2.f);
	CGContextTranslateCTM(context,-1*(self.touchPoint.x),-1*(self.touchPoint.y));
	[self.targetView.layer renderInContext:context];
}

@end
