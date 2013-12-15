//
//  DDColorWheelGenerationOperation.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 05/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDColorWheelGenerator : NSOperation

/**
 *  @return A new generation operation for the given lightness
 */
+ (instancetype)generatorWithWidth:(NSUInteger)width height:(NSUInteger)height lightness:(CGFloat)lightness completionBlock:(void (^)(UIImage *))block;

/**
 *  Generate RGB values from HSL
 *
 *  @param hue        Hue
 *  @param saturation Saturation
 *  @param lightness  Lightness
 *  @param red        Pointer to red
 *  @param green      Pointer to green
 *  @param blue       Pointer to blue
 */
+ (void)hue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness toRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue;

/**
 *  Get the hue and saturation values 
 *
 *  @param side       Side length
 *  @param x          x
 *  @param y          y
 *  @param hue        Hue
 *  @param saturation Saturation
 */
+ (void)getColorWheelValue:(int)side x:(int)x y:(int)y toHue:(CGFloat *)hue saturation:(CGFloat *)saturation;

@end
