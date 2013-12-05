//
//  DDColorPickerViewController.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorPickerViewController.h"

#define MAS_SHORTHAND
#import <Masonry/Masonry.h>

@interface DDColorPickerViewController ()

@property (nonatomic) DDColorPickerOptions options;

@property (nonatomic, strong, readwrite) DDColorWheel *colorWheel;

@property (nonatomic, strong, readwrite) UISlider *lightnessSlider;

@property (nonatomic, strong, readwrite) UISlider *alphaSlider;

@property (nonatomic, strong, readwrite) UIButton *doneButton;

@property (nonatomic, strong, readwrite) UIButton *dismissButton;

@property (nonatomic, strong) id <MASConstraint> colorWheelTopOffsetConstraint;

@end

@implementation DDColorPickerViewController

#pragma mark - Class Methods

+ (instancetype)colorPicker
{
  return [[self alloc] init];
}

+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate
{
  DDColorPickerViewController *picker = [[self alloc] init];
  picker.delegate = delegate;
  return picker;
}

+ (instancetype)colorPickerWithDelegate:(id <DDColorPicking>)delegate options:(DDColorPickerOptions)options
{
  DDColorPickerViewController *picker = [self colorPickerWithDelegate:delegate];
  picker.options = options;
  return picker;
}

#pragma mark - Lifecycle

- (id)init
{
  if((self = [super init]))
  {
    // Set default options
    _options = DDColorPickerOptionsDefault;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // UI components will be setup depending on what options are set.
  
  self.colorWheel = [DDColorWheel colorWheel];
  self.colorWheel.wheelAlpha = 1.f;
  self.colorWheel.lightness = .5f;
  [self.colorWheel addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.colorWheel];
  
  [self.colorWheel makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(self.colorWheel.width);
    make.width.equalTo(self.view.width).multipliedBy(.8f);
    make.centerX.equalTo(self.view.centerX);
    self.colorWheelTopOffsetConstraint = make.top.equalTo(self.view.top).with.offset(15);
  }];
  
  UIView *sliderView = [[UIView alloc] init];
  [self.view addSubview:sliderView];
  
  [sliderView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.colorWheel.bottom);
    make.left.equalTo(self.view.left);
    make.right.equalTo(self.view.right);
  }];
  
  if(self.options & DDColorPickerOptionsShowAlpha)
  {
    self.alphaSlider = [[UISlider alloc] init];
    self.alphaSlider.minimumValue = 0.f;
    self.alphaSlider.maximumValue = 1.f;
    self.alphaSlider.value = 1.f;
    [self.alphaSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:self.alphaSlider];
    
    [self.alphaSlider makeConstraints:^(MASConstraintMaker *make) {
      make.width.equalTo(sliderView.width).multipliedBy(.8f);
      make.centerX.equalTo(sliderView.centerX);
      make.top.equalTo(self.colorWheel.bottom);
      if(!(self.options & DDColorPickerOptionsShowLightness))
      {
        make.bottom.equalTo(sliderView.bottom).with.offset(-15);
      }
    }];
  }
  
  if(self.options & DDColorPickerOptionsShowLightness)
  {
    self.lightnessSlider = [[UISlider alloc] init];
    self.lightnessSlider.minimumValue = 0.f;
    self.lightnessSlider.maximumValue = 1.f;
    self.lightnessSlider.value = .5f;
    [self.lightnessSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:self.lightnessSlider];
    
    [self.lightnessSlider makeConstraints:^(MASConstraintMaker *make) {
      make.width.equalTo(sliderView.width).multipliedBy(.8f);
      make.centerX.equalTo(sliderView.centerX);
      if(self.options & DDColorPickerOptionsShowAlpha)
      {
        make.top.equalTo(self.alphaSlider.bottom);
      }
      else
      {
        make.top.equalTo(self.colorWheel.bottom);
      }
      make.bottom.equalTo(sliderView.bottom).with.offset(-15);
    }];
  }
  
  UIView *buttonView = [[UIView alloc] init];
  [self.view addSubview:buttonView];
  
  if(self.options & DDColorPickerOptionsShowDoneButton)
  {
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:self.doneButton];
    
    [self.doneButton makeConstraints:^(MASConstraintMaker *make) {
      make.trailing.equalTo(buttonView.right).with.offset(-15);
      make.top.equalTo(buttonView.top);
      make.bottom.equalTo(buttonView.bottom).with.offset(-15);
    }];
  }
  
  if(self.options & DDColorPickerOptionsShowDismissButton)
  {
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dismissButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:self.dismissButton];
    
    [self.dismissButton makeConstraints:^(MASConstraintMaker *make) {
      make.leading.equalTo(buttonView.left).with.offset(15);
      make.top.equalTo(buttonView.top);
      make.bottom.equalTo(buttonView.bottom).with.offset(-15);
    }];
  }
  
  [buttonView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(sliderView.bottom);
    make.left.equalTo(self.view.left);
    make.right.equalTo(self.view.right);
    make.bottom.equalTo(self.view.bottom);
  }];
}

- (void)viewWillLayoutSubviews
{
  [self.colorWheelTopOffsetConstraint uninstall];
  [self.colorWheel makeConstraints:^(MASConstraintMaker *make) {
    self.colorWheelTopOffsetConstraint = make.top.equalTo(self.view.top).with.offset(self.view.bounds.size.width * .1f);
  }];
  [super viewWillLayoutSubviews];
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - Actions

- (void)valueChanged:(id)sender
{
  if(sender == self.lightnessSlider)
  {
    self.colorWheel.lightness = self.lightnessSlider.value;
  }
  else if(sender == self.alphaSlider)
  {
    self.colorWheel.wheelAlpha = self.alphaSlider.value;
  }
  else if(sender == self.colorWheel && [self.delegate respondsToSelector:@selector(colorPicker:didHighlightColor:)])
  {
    [self.delegate colorPicker:self didHighlightColor:self.colorWheel.currentColor];
  }
}

- (void)buttonTapped:(id)sender
{
  if(sender == self.doneButton)
  {
    [self.delegate colorPicker:self didPickColor:self.colorWheel.currentColor];
  }
  else if(sender == self.dismissButton && [self.delegate respondsToSelector:@selector(colorPickerDidDismiss:)])
  {
    [self.delegate colorPickerDidDismiss:self];
  }
}

@end
