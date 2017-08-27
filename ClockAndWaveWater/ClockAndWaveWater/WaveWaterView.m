//
//  WaveWaterView.m
//  WCircleProgress
//
//  Created by wq on 2017/7/12.
//  Copyright © 2017年 songmao. All rights reserved.
//

#import "WaveWaterView.h"
#import "UIView+Extension.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface WaveWaterView ()
{
    CGFloat _wave_offsety;//根据进度计算(波峰所在位置的y坐标)
    
    CGFloat _offsety_scale;//上升的速度
    
    CGFloat _wave_move_width;//移动的距离，配合速率设置
    
    CGFloat _wave_offsetx;//偏移,animation
    
    CADisplayLink *_waveDisplaylink;
    
}

@end

@implementation WaveWaterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
    }
    return self;
}

-(void)initView
{
    _wave_Amplitude = self.frame.size.height/20;
    _wave_Cycle = 2*M_PI/(self.frame.size.width * .9);
    
    
    _wave_h_distance = 2*M_PI/_wave_Cycle * .65;
    _wave_v_distance = _wave_Amplitude * .2;
    
    _wave_move_width = 0.5;
    
    _wave_scale = 0.3;
    
    _offsety_scale = 0.01;
    
    _topColor = [UIColor colorWithRed:79/255.0 green:240/255.0 blue:255/255.0 alpha:1];
    _bottomColor = [UIColor colorWithRed:79/255.0 green:240/255.0 blue:255/255.0 alpha:.3];
    
    _progress = 0.0;
    _progress_animation = YES;
    _wave_offsety = (1-_progress) * (self.height + 2* _wave_Amplitude);
    [self startWave];
}

-(void)drawRect:(CGRect)rect
{
    //圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.width, self.height)];
    _borderPath = path;
    [path setLineWidth:1];
    
    //心形
//    CGFloat radius =self.width/4;
//    CGPoint center1 = CGPointMake(radius, radius);
//    CGPoint center2 = CGPointMake(3*radius, radius);
//    CGPoint bottom = CGPointMake(2*radius, self.height);
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center1 radius:radius startAngle:0 endAngle:3*M_PI_4 clockwise:NO];
//    _borderPath = path;
//    [path addLineToPoint:bottom];
//    [path addArcWithCenter:center2 radius:radius startAngle:M_PI_4 endAngle:M_PI clockwise:NO];
//    [path setLineCapStyle:kCGLineCapRound];
//    [path setLineWidth:1];
    
    //五角星
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    _borderPath = path;
//    //中心点
//    CGPoint centerPoint = CGPointMake(self.width/2, self.width/2);
//    //半径
//    CGFloat bigRadius = rect.size.width/2;
//    CGFloat smallRadius = bigRadius * sin(2*M_PI/20) / cos(2*M_PI/10);
//    //起始点
//    CGPoint start = CGPointMake(rect.size.width/2, 0);
//    [path moveToPoint:start];
//    CGFloat angle = 2*M_PI/5.0;
//    for (int i = 1; i <=10; i++) {
//        CGFloat x;
//        CGFloat y;
//        NSInteger c = i/2;
//        if (i%2 == 0) {
//            x = centerPoint.x - sinf(c*angle)*bigRadius;
//            y = centerPoint.y - cosf(c*angle)*bigRadius;
//        }else{
//            x = centerPoint.x -sinf(c*angle + angle/2)*smallRadius;
//            y = centerPoint.y -cosf(c*angle + angle/2)*smallRadius;
//        }
//        [path addLineToPoint:CGPointMake(x, y)];
//    }
//    [path setLineWidth:1];
    
    if (_borderPath) {
        _border_fillColor = [UIColor groupTableViewBackgroundColor];
        if (_border_fillColor) {
            [_border_fillColor setFill];
            [_borderPath fill];
        }
        
        if (_border_strokeColor) {
            [_border_strokeColor setStroke];
            [_borderPath stroke];
        }
        [_borderPath addClip];
    }
    [self drawWaveColor:_topColor offsetx:0 offsety:0];
    [self drawWaveColor:_bottomColor offsetx:_wave_h_distance offsety:_wave_v_distance];
}

- (void)drawWaveColor:(UIColor *)color offsetx:(CGFloat)offsetx offsety:(CGFloat)offsety
{
    //波浪动画，所以进度的实际操作范围是，多加上两个振幅的高度,到达设置进度的位置y坐标
    CGFloat end_offY = (1-_progress) * (self.height + 2*_wave_Amplitude);
    if (_progress_animation) {
        if (_wave_offsety != end_offY) {
            if (end_offY < _wave_offsety) {//上升
                _wave_offsety = MAX(_wave_offsety-=(_wave_offsety - end_offY)*_offsety_scale, end_offY);
            }else{
                _wave_offsety = MIN(_wave_offsety+=(end_offY - _wave_offsety)*_offsety_scale, end_offY);
            }
        }
    }else{
        _wave_offsety = end_offY;
    }
    
    UIBezierPath *wave = [UIBezierPath bezierPath];
    for (float next_x= 0.f; next_x <= self.width; next_x ++) {
        //正弦函数 y=Asin（ωx+φ）+h
        CGFloat next_y = _wave_Amplitude * sin(_wave_Cycle*next_x + _wave_offsetx + offsetx/self.width*2*M_PI) + _wave_offsety + offsety;
        if (next_x == 0) {
            [wave moveToPoint:CGPointMake(next_x, next_y - _wave_Amplitude)];
        } else {
            [wave addLineToPoint:CGPointMake(next_x, next_y - _wave_Amplitude)];
        }
    }

    [wave addLineToPoint:CGPointMake(self.width, self.height)];
    [wave addLineToPoint:CGPointMake(0, self.height)];
    [color set];
    [wave fill];
}

-(void)startWave
{
    if (!_waveDisplaylink) {
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeoff)];
        [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)changeoff
{
    _wave_offsetx += _wave_move_width * _wave_scale;
    [self setNeedsDisplay];
}

- (void)dealloc {
    if (_waveDisplaylink) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
    }
}

@end
