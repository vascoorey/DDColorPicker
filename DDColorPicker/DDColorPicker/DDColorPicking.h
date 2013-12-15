//
//  DDColorPicking.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 10/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDColorPickerViewController;

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
