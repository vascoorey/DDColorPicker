//
//  DDColorPickerViewController.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDColorWheel.h"

typedef NS_ENUM(uint32_t, DDColorPickerOptions)
{
  DDColorPickerOptionsShowAlpha = (1 << 0),
  DDColorPickerOptionsShowLightness = (1 << 1),
  DDColorPickerOptionsShowDoneButton = (1 << 2),
  DDColorPickerOptionsShowDismissButton = (1 << 3),
  DDColorPickerOptionsDefault = DDColorPickerOptionsShowAlpha | DDColorPickerOptionsShowLightness | DDColorPickerOptionsShowDoneButton | DDColorPickerOptionsShowDismissButton
};

@protocol DDColorPicking;

/**
 *  Color picking view controller. Presents a color wheel, alpha & hue sliders.
 */
@interface DDColorPickerViewController : UIViewController

/**
 *  The delegate to the view controller. Set this property if you wish to be notified of the user's interactions.
 */
@property (nonatomic, weak) id <DDColorPicking> delegate;

/**
 *  The color wheel object managed by this view controller
 */
@property (nonatomic, readonly) DDColorWheel *colorWheel;

@property (nonatomic, readonly) UISlider *lightnessSlider;

@property (nonatomic, readonly) UISlider *alphaSlider;

@property (nonatomic, readonly) UIButton *doneButton;

@property (nonatomic, readonly) UIButton *dismissButton;

/**
 *  Creates a new color picker
 */
+ (instancetype)colorPicker;

/**
 *  Creates a new color picker with the given delegate and default options
 */
+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate;

/**
 *  Creates a new color picker with the given delegate and options
 */
+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate options:(DDColorPickerOptions)options;

@end

/**
 *  Color picking protocol. All methods are optional.
 */
@protocol DDColorPicking <NSObject>

@required

/**
 *  Sent to the delegate when the user specifically selected the given color.
 *
 *  @param viewController The sender instance
 *  @param color          The selected color
 */
- (void)colorPicker:(DDColorPickerViewController *)viewController didPickColor:(UIColor *)color;

@optional

/**
 *  Sent to the delegate when the specified color has been highlighted (i.e. the user swiped over the color).
 *
 *  @param viewController The sender instance
 *  @param color          The highlighted color
 */
- (void)colorPicker:(DDColorPickerViewController *)viewController didHighlightColor:(UIColor *)color;

/**
 *  Sent to the delegate if the user explicitly dismissed the controller
 */
- (void)colorPickerDidDismiss:(DDColorPickerViewController *)viewController;

@end
