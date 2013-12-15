//
//  DDMagnifierView.h
//  DDColorPicker
//
//  Created by Vasco d'Orey on 15/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDMagnifierView : UIView

@property (nonatomic) CGPoint touchPoint;

+ (instancetype)magnifierWithTargetView:(UIView *)targetView;

@end
