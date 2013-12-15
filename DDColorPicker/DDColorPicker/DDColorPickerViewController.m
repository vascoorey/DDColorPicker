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

@property (nonatomic, strong, readwrite) DDColorWheelView *colorWheel;

@property (nonatomic, strong, readwrite) UISlider *lightnessSlider;

@property (nonatomic, strong, readwrite) UISlider *alphaSlider;

@property (nonatomic, strong, readwrite) UIButton *doneButton;

@property (nonatomic, strong, readwrite) UIButton *dismissButton;

@property (nonatomic, strong, readwrite) UIView *colorPreviewView;

@property (nonatomic, strong, readwrite) UIView *sliderView;

@property (nonatomic, strong, readwrite) UIView *buttonView;

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
  
  self.view.backgroundColor = UIColor.whiteColor;
  
  self.colorWheel = [DDColorWheelView colorWheel];
  self.colorWheel.wheelAlpha = 1.f;
  self.colorWheel.lightness = .5f;
  [self.colorWheel addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.colorWheel];
  
  self.colorPreviewView = [[UIView alloc] init];
  self.colorPreviewView.backgroundColor = UIColor.clearColor;
  [self.view addSubview:self.colorPreviewView];
  
  self.sliderView = [[UIView alloc] init];
  [self.view addSubview:self.sliderView];
  
  
  if(self.options & DDColorPickerOptionsShowAlpha)
  {
    self.alphaSlider = [[UISlider alloc] init];
    self.alphaSlider.minimumValue = 0.f;
    self.alphaSlider.maximumValue = 1.f;
    self.alphaSlider.value = 1.f;
    [self.alphaSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView addSubview:self.alphaSlider];
  }
  
  if(self.options & DDColorPickerOptionsShowLightness)
  {
    self.lightnessSlider = [[UISlider alloc] init];
    self.lightnessSlider.minimumValue = 0.f;
    self.lightnessSlider.maximumValue = 1.f;
    self.lightnessSlider.value = .5f;
    [self.lightnessSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView addSubview:self.lightnessSlider];
  }
  
  self.buttonView = [[UIView alloc] init];
  [self.view addSubview:self.buttonView];
  
  if(self.options & DDColorPickerOptionsShowDoneButton)
  {
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:self.doneButton];
  }
  
  if(self.options & DDColorPickerOptionsShowDismissButton)
  {
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:self.dismissButton];
  }
  
  if(self.overrideLayout)
  {
    if(self.makeLayout)
    {
      self.makeLayout(self);
    }
  }
  else
  {
    [self.sliderView makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.view.left);
      make.right.equalTo(self.view.right);
    }];
    
    [self.colorWheel makeConstraints:^(MASConstraintMaker *make) {
      make.height.equalTo(self.colorWheel.width);
      make.width.equalTo(self.view.width).multipliedBy(.8f);
      make.centerX.equalTo(self.view.centerX);
    }];
    
    [self.colorPreviewView makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.colorWheel.left);
      make.top.equalTo(self.colorWheel.top);
      make.width.equalTo(self.colorWheel.width).multipliedBy(.125f);
      make.height.equalTo(self.colorPreviewView.width);
    }];
    
    if(self.options & DDColorPickerOptionsShowAlpha)
    {
      [self.alphaSlider makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.sliderView.width).multipliedBy(.8f);
        make.centerX.equalTo(self.sliderView.centerX);
        make.top.equalTo(self.sliderView.top);
      }];
    }
    
    if(self.options & DDColorPickerOptionsShowLightness)
    {
      [self.lightnessSlider makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.sliderView.width).multipliedBy(.8f);
        make.centerX.equalTo(self.sliderView.centerX);
      }];
    }
    
    if(self.options & DDColorPickerOptionsShowDoneButton)
    {
      [self.doneButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.buttonView.right);
        make.top.equalTo(self.buttonView.top);
        make.bottom.equalTo(self.buttonView.bottom);
      }];
    }
    
    if(self.options & DDColorPickerOptionsShowDismissButton)
    {
      [self.dismissButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.buttonView.left);
        make.top.equalTo(self.buttonView.top);
        make.bottom.equalTo(self.buttonView.bottom);
      }];
    }
    
    [self.buttonView makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.colorWheel.left);
      make.right.equalTo(self.colorWheel.right);
    }];
  }
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewWillLayoutSubviews
{
  if(self.overrideLayout)
  {
    if(self.updateLayout)
    {
      self.updateLayout(self);
    }
  }
  else
  {
    CGFloat offset = self.view.frame.size.width * .1f;
    
    [self.colorWheel updateConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.view.top).with.offset(offset);
    }];
    
    [self.sliderView updateConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.colorWheel.bottom).with.offset(offset);
    }];
    
    [self.alphaSlider updateConstraints:^(MASConstraintMaker *make) {
      if(!(self.options & DDColorPickerOptionsShowLightness))
      {
        make.bottom.equalTo(self.sliderView.bottom);
      }
    }];
    
    [self.lightnessSlider updateConstraints:^(MASConstraintMaker *make) {
      if(self.options & DDColorPickerOptionsShowAlpha)
      {
        make.top.equalTo(self.alphaSlider.bottom).with.offset(offset * .5f);
      }
      else
      {
        make.top.equalTo(self.sliderView.top);
      }
      make.bottom.equalTo(self.sliderView.bottom);
    }];
    
    [self.buttonView updateConstraints:^(MASConstraintMaker *make) {
      make.top.lessThanOrEqualTo(self.sliderView.bottom).with.offset(offset);
      make.bottom.equalTo(self.view.bottom).with.offset(-offset);
    }];
  }
  [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
  self.colorPreviewView.layer.cornerRadius = .5f * self.colorPreviewView.bounds.size.width;
  [super viewDidLayoutSubviews];
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
  self.colorPreviewView.backgroundColor = self.colorWheel.currentColor;
  [self.colorPreviewView setNeedsDisplay];
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
