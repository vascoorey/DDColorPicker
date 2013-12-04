//
//  DDColorPickerViewController.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDColorPickerViewController.h"
#import "DDColorWheel.h"

#define MAS_SHORTHAND
#import <Masonry/Masonry.h>

@interface DDColorPickerViewController ()

@property (nonatomic) DDColorPickerOptions options;

@property (nonatomic, strong) DDColorWheel *colorWheel;

@property (nonatomic, strong) UISlider *lightnessSlider;

@property (nonatomic, strong) UISlider *alphaSlider;

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
    make.width.lessThanOrEqualTo(self.view.width);
    make.left.equalTo(self.view.left).with.offset(15);
    make.right.equalTo(self.view.right).with.offset(-15);
    make.top.equalTo(self.view.top).with.offset(15);
  }];
  
  if(self.options & DDColorPickerOptionsShowAlpha)
  {
    self.alphaSlider = [[UISlider alloc] init];
    self.alphaSlider.minimumValue = 0.f;
    self.alphaSlider.maximumValue = 1.f;
    self.alphaSlider.value = 1.f;
    [self.alphaSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.alphaSlider];
    
    [self.alphaSlider makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.view.left).with.offset(15);
      make.right.equalTo(self.view.right).with.offset(-15);
      make.top.equalTo(self.colorWheel.bottom);
      if(!(self.options & DDColorPickerOptionsShowLightness))
      {
        make.bottom.equalTo(self.view.bottom).with.offset(-15);
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
    [self.view addSubview:self.lightnessSlider];
    
    [self.lightnessSlider makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.view.left).with.offset(15);
      make.right.equalTo(self.view.right).with.offset(-15);
      if(self.options & DDColorPickerOptionsShowAlpha)
      {
        make.top.equalTo(self.alphaSlider.bottom);
      }
      else
      {
        make.top.equalTo(self.colorWheel.bottom);
      }
      make.bottom.equalTo(self.view.bottom).with.offset(-15);
    }];
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.colorWheel updateColorWheel];
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

@end
