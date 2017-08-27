//
//  ViewController.m
//  ClockAndWaveWater
//
//  Created by WXQ on 2017/7/14.
//  Copyright © 2017年 WXQ. All rights reserved.
//

#import "ViewController.h"
#import "WaveWaterView.h"
#import "ClockView.h"

#define SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)


@interface ViewController ()

@property (nonatomic, strong) WaveWaterView *waterView;

@property (nonatomic, strong) ClockView *clockView;

@property (nonatomic, strong) UISlider *slider;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.waterView];
    
    [self.view addSubview:self.slider];
    
    
    [self.view addSubview:self.clockView];

}

-(void)click:(UISlider *)slider
{
    NSLog(@"%f",slider.value);
    [_waterView setProgress:slider.value];
}

#pragma mark ---懒加载
-(UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, SCREEN_HEIGHT-80, 200, 10)];
        [_slider addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _slider;
}

-(WaveWaterView *)waterView
{
    if (!_waterView) {
        _waterView = [[WaveWaterView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, 350, 200, 200)];
    }
    return _waterView;
}

-(ClockView *)clockView
{
    if (!_clockView) {
        _clockView = [[ClockView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 300)];
    }
    return _clockView;
}

@end
