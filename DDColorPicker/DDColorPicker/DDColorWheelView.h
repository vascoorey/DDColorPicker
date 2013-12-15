//
//  DDColorWheel.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  DDColorWheel acts as a 2 dimensional UISlider. Will send UIControlEventValueChanged events.
 */
@interface DDColorWheelView : UIControl

/**
 *  The currently selected color.
 */
@property (nonatomic, readonly) UIColor *currentColor;

/**
 *  The lightness of the color wheel (HSL). 0.0 - 1.0
 */
@property (nonatomic) CGFloat lightness;

/**
 *  The alpha of the color wheel. 0.0 - 1.0
 */
@property (nonatomic) CGFloat wheelAlpha;

/**
 *  @return A new color wheel view.
 */
+ (instancetype)colorWheel;

/**
 *  Updates the color wheel
 */
- (void)updateColorWheel;

@end
