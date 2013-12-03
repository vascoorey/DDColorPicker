//
//  DDViewController.m
//  DDColorPicker
//
//  Created by Vasco d'Orey on 03/12/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDViewController.h"
#import "DDColorWheel.h"

@interface DDViewController ()

@end

@implementation DDViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  DDColorWheel *wheel = [[DDColorWheel alloc] init];
  [self.view addSubview:wheel];
  
  [wheel addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventValueChanged];
  
  [wheel makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(self.view.width);
    make.height.equalTo(self.view.width);
    make.center.equalTo(self.view);
  }];
}

- (void)colorChanged:(DDColorWheel *)sender
{
  self.view.backgroundColor = sender.currentColor;
}

@end
