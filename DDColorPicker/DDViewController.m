//
//  DDViewController.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDViewController.h"
#import "DDColorWheel.h"
#import "DDColorPickerViewController.h"

@interface DDViewController () <DDColorPicking>
@property (nonatomic, strong) DDColorWheel *colorWheel;
@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UIButton *button;
@end

@implementation DDViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.view bringSubviewToFront:self.button];
}

- (IBAction)showPicker:(UIButton *)sender
{
  self.popover = [[UIPopoverController alloc] initWithContentViewController:[DDColorPickerViewController colorPickerWithDelegate:self]];
  [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - DDColorPicking

- (void)colorPicker:(DDColorPickerViewController *)viewController didHighlightColor:(UIColor *)color
{
  self.colorView.backgroundColor = color;
}

- (void)colorPicker:(DDColorPickerViewController *)viewController didPickColor:(UIColor *)color
{
  self.colorView.backgroundColor = color;
}

@end
