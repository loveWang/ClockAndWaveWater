//
//  ClockView.m
//  WCircleProgress
//
//  Created by wq on 2017/7/14.
//  Copyright © 2017年 songmao. All rights reserved.
//

#import "ClockView.h"
#import "UIView+Extension.h"

@interface ClockView ()<CAAnimationDelegate>

@property (nonatomic, assign) CGFloat majorScaleNum;

@property (nonatomic, strong) UIImageView *hourView;

@property (nonatomic, strong) UIImageView *minuteView;

@property (nonatomic, strong) UIImageView *secondView;

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation ClockView

-(instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self drawCircleClock];
        [self addSubview:self.hourView];
        [self addSubview:self.minuteView];
        [self addSubview:self.secondView];
        self.hourView.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
        self.minuteView.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
        self.secondView.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
        [self updateHandsAnimated:NO];
        //        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        //        [[NSRunLoop currentRunLoop] run];
        
    }
    return self;
}

-(void)timeTick
{
    [self updateHandsAnimated:YES];
}

-(void)updateHandsAnimated:(BOOL)animated
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger units = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
    NSLog(@"%ld %ld %ld",components.hour,components.minute,components.second);
    //时
    CGFloat hoursAngle = (components.hour / 12.0) * M_PI * 2.0;
    //分
    CGFloat minsAngle = (components.minute / 60.0) * M_PI * 2.0;
    //秒
    CGFloat secsAngle = (components.second / 60.0) * M_PI * 2.0;
    
//    self.hourView.transform = CGAffineTransformMakeRotation(hoursAngle);
//    self.minuteView.transform = CGAffineTransformMakeRotation(minsAngle);
//    self.secondView.transform = CGAffineTransformMakeRotation(secsAngle);

    [self setAngle:hoursAngle forHand:self.hourView animated:animated];
    [self setAngle:minsAngle forHand:self.minuteView animated:animated];
    [self setAngle:secsAngle forHand:self.secondView animated:animated];
}

-(void)setAngle:(CGFloat)angle forHand:(UIView *)handView animated:(BOOL)animated
{
    CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animation];
        [self updateHandsAnimated:NO];
        animation.keyPath = @"transform";
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        animation.duration = 0.5;
        animation.delegate = self;
        [animation setValue:handView forKey:@"handView"];
        [handView.layer addAnimation:animation forKey:nil];
    }else{
        handView.layer.transform = transform;
    }
}
-(void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    UIView *handView = [anim valueForKey:@"handView"];
    handView.layer.transform = [anim.toValue CATransform3DValue];
}


-(UIImageView *)hourView
{
    if (!_hourView) {
        _hourView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/2 - 8, self.height/2 - 40, 16, 80)];
        _hourView.image = [UIImage imageNamed:@"pointerV2.png"];
    }
    return _hourView;
}

-(UIImageView *)minuteView
{
    if (!_minuteView) {
        _minuteView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/2 - 8, self.height/2 - 40, 16, 80)];
        _minuteView.image = [UIImage imageNamed:@"pointerV2"];
    }
    return _minuteView;
}

-(UIImageView *)secondView
{
    if (!_secondView) {
        _secondView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/2 - 8, self.height/2 - 40, 16, 80)];
        _secondView.image = [UIImage imageNamed:@"pointerV2"];
    }
    return _secondView;
}



-(void)drawCircleClock
{
    [self drawCircle];
    
    [self drawScalBig];
    
    [self drawScaleNum];
    
}

-(void)drawCircle
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(self.width/2, self.height/2) radius:100 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = path.CGPath;
    arc.lineWidth = 1;
    arc.fillColor = [UIColor clearColor].CGColor;
    arc.strokeColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:arc];
}

-(void)drawScalBig
{
    CGFloat totalScale;
    CGFloat perAngle;
    
    totalScale = 12 * 5;
    
    perAngle = M_PI*2/totalScale;
    for (int i = 0; i < totalScale; i++) {
        CGFloat startAngle = perAngle*i;
        if (i % 5 == 0) {
            //major
            CGFloat endAngle = startAngle + 5/(2*M_PI*100);
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2, self.height/2) radius:95 startAngle:startAngle endAngle:endAngle clockwise:YES];
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.strokeColor = [UIColor redColor].CGColor;
            layer.path = path.CGPath;
            layer.lineWidth = 10;
            [self.layer addSublayer:layer];
        }else{
            //small
            CGFloat endAngle = startAngle + 3/(2*M_PI*100);
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2, self.height/2) radius:96 startAngle:startAngle endAngle:endAngle clockwise:YES];
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.strokeColor = [UIColor orangeColor].CGColor;
            layer.path = path.CGPath;
            layer.lineWidth = 5;
            [self.layer addSublayer:layer];
        }
        
    }
}

-(void)drawScaleNum
{
    NSMutableArray *textArr = [NSMutableArray array];
    for (int i = 0; i < 12; i++) {
        [textArr addObject:@(i)];
    }
    [self creatLable:textArr];
}

-(void)creatLable:(NSArray *)textArray
{
    CGFloat singleAngle = 2*M_PI / (textArray.count);
    UIFont *scalFont = [UIFont systemFontOfSize:10];
    for (int i = 0; i < textArray.count; i++) {
        CGFloat degree = -M_PI/2 + i * singleAngle;
        //对应文字的Size
        CGSize textSize = [self stringSize:[NSString stringWithFormat:@"%@",textArray[i]] withFont:scalFont size:CGSizeMake(MAXFLOAT, scalFont.lineHeight)];
        
        //对应的center
        CGFloat textRadius = 100 - 20;
        CGPoint majorCenter = CGPointMake(self.width/2+textRadius*cosf(degree), self.height/2+textRadius*sinf(degree));
        UILabel *scaleLable      = [[UILabel alloc] init];
        
        
        scaleLable.frame = CGRectMake(0, 0, textSize.width, scalFont.lineHeight);
        scaleLable.text          = [NSString stringWithFormat:@"%@",textArray[i]];
        scaleLable.font          = scalFont;
        scaleLable.textColor     = [UIColor redColor];
        [self addSubview:scaleLable];
        
        CGFloat offx = 0;
        CGFloat offy = 0;
        NSInteger angleCos = (10000 * cosf(degree));
        if (angleCos == 0) {
            offx = -textSize.width/2;
            offy = -textSize.height/2;
        } else if (angleCos < 0) {
            offy = -textSize.height/2;
        } else {
            offy = -textSize.height/2;
            offx = -textSize.width;
        }
        
        scaleLable.frame = CGRectMake(majorCenter.x+offx, majorCenter.y+offy, textSize.width, scalFont.lineHeight);
    }
    
}

#pragma mark - 字体长度
- (CGSize)stringSize:(NSString *)string withFont:(UIFont *)font size:(CGSize)size
{
    
    CGSize resultSize;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
        //段落样式
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        
        //字体大小，换行模式
        NSDictionary *attributes = @{NSFontAttributeName : font , NSParagraphStyleAttributeName : style};
        resultSize = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    } else {
        //计算正文的高度
        resultSize = [string sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    }
    return resultSize;
}

@end

