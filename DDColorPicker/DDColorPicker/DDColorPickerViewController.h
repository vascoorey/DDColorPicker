//
//  DDColorPickerViewController.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDCOlorPicking.h"
#import "DDColorWheelView.h"

typedef NS_ENUM(uint32_t, DDColorPickerOptions)
{
  DDColorPickerOptionsShowAlpha = (1 << 0),
  DDColorPickerOptionsShowLightness = (1 << 1),
  DDColorPickerOptionsShowDoneButton = (1 << 2),
  DDColorPickerOptionsShowDismissButton = (1 << 3),
  DDColorPickerOptionsDefault = DDColorPickerOptionsShowAlpha | DDColorPickerOptionsShowLightness | DDColorPickerOptionsShowDoneButton | DDColorPickerOptionsShowDismissButton
};

/**
 *  Color picking view controller. Presents a color wheel, alpha & hue sliders.
 */
@interface DDColorPickerViewController : UIViewController

/**
 *  The delegate to the view controller. Set this property if you wish to be notified of the user's interactions.
 */
@property (nonatomic, weak) id <DDColorPicking> delegate;

/**
 *  Set this property to YES if you want to specify your own layout.
 */
@property (nonatomic) BOOL overrideLayout;

/**
 *  Set this block with your own custom layout code. Will get called in viewDidLoad after all views have been added to the superview.
 */
@property (nonatomic, copy) void (^makeLayout)(DDColorPickerViewController *);

/**
 *  Set this block with you custom layout update code. Will get called in viewWillLayoutSubviews.
 */
@property (nonatomic, copy) void (^updateLayout)(DDColorPickerViewController *);

/**
 *  The color wheel object managed by this view controller
 */
@property (nonatomic, readonly) DDColorWheelView *colorWheel;

/**
 *  The color preview view
 */
@property (nonatomic, readonly) UIView *colorPreviewView;

/**
 *  The lightness (luminance) slider
 */
@property (nonatomic, readonly) UISlider *lightnessSlider;

/**
 *  The alpha slider
 */
@property (nonatomic, readonly) UISlider *alphaSlider;

/**
 *  The view to which any sliders are added
 */
@property (nonatomic, readonly) UIView *sliderView;

/**
 *  The done button
 */
@property (nonatomic, readonly) UIButton *doneButton;

/**
 *  The dismiss button
 */
@property (nonatomic, readonly) UIButton *dismissButton;

/**
 *  The view to which any buttons are added
 */
@property (nonatomic, readonly) UIView *buttonView;

/**
 *  @return A new color picker with no delegate and default options
 */
+ (instancetype)colorPicker;

/**
 *  @return A new color picker with the given delegate and default options
 */
+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate;

/**
 *  @return A new color picker with the given delegate and options
 */
+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate options:(DDColorPickerOptions)options;

@end
