//
//  DDViewController.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDViewController.h"
#import "DDColorWheelView.h"
#import "DDColorPickerViewController.h"

@interface DDViewController () <DDColorPicking>
@property (nonatomic, strong) DDColorWheelView *colorWheel;
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
  DDColorPickerViewController *picker = [DDColorPickerViewController colorPickerWithDelegate:self];
  picker.overrideLayout = NO;
  self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
  [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)presentPicker:(id)sender
{
  DDColorPickerViewController *picker = [DDColorPickerViewController colorPickerWithDelegate:self];
  picker.overrideLayout = NO;
  picker.makeLayout = ^(DDColorPickerViewController *vc) {
    NSLog(@"Should make the layout here.");
  };
  picker.updateLayout = ^(DDColorPickerViewController *vc) {
    NSLog(@"Should update the layout here");
  };
  [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - DDColorPicking

- (void)colorPicker:(DDColorPickerViewController *)viewController didHighlightColor:(UIColor *)color
{
  self.colorView.backgroundColor = color;
}

- (void)colorPicker:(DDColorPickerViewController *)viewController didPickColor:(UIColor *)color
{
  self.colorView.backgroundColor = color;
  if(self.presentedViewController)
  {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)colorPickerDidDismiss:(DDColorPickerViewController *)viewController
{
  if(self.presentedViewController)
  {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
