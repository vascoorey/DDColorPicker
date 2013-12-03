//
//  DDColorPickerViewController.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDColorPicking;

/**
 *  Color picking view controller. Presents a color wheel, alpha & hue sliders.
 */
@interface DDColorPickerViewController : UIViewController

/**
 *  The delegate to the view controller. Set this property if you wish to be notified of the user's interactions.
 */
@property (nonatomic, weak) id <DDColorPicking> delegate;

@end

/**
 *  Color picking protocol. All methods are optional.
 */
@protocol DDColorPicking <NSObject>
@optional

/**
 *  Sent to the delegate when the user specifically selected the given color.
 *
 *  @param viewController The sender instance
 *  @param color          The selected color
 */
- (void)viewController:(DDColorPickerViewController *)viewController didPickColor:(UIColor *)color;

/**
 *  Sent to the delegate when the specified color has been highlighted (i.e. the user swiped over the color).
 *
 *  @param viewController The sender instance
 *  @param color          The highlighted color
 */
- (void)viewController:(DDColorPickerViewController *)viewController didHighlightColor:(UIColor *)color;

@end
