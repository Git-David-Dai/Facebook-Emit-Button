//
//  EmitterView.m
//  EmitButton
//
//  Created by David.Dai on 2017/5/23.
//  Copyright © 2017年 David.Dai. All rights reserved.
//

#import "EmitterView.h"
#import "Masonry.h"

#define kEmitterAnimationKey  @"emitterPositionAnimation"
#define kFloatingAnimationKey @"floatingPositionAnimation"

@interface EmitterView()<CAAnimationDelegate>
@property (nonatomic,strong) UIImage *defaultImage;
@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,strong) UIImageView *imageView;


@property (nonatomic,weak)   UIView  *inView;
@property (nonatomic,assign) CGPoint emitterEndPoint;
@property (nonatomic,assign) CGRect  originalFrame;
@end

@implementation EmitterView

- (instancetype)initWithDefaultImage:(UIImage *)defaultImage
                           iconImage:(UIImage *)icon
{
    if(self = [super init]){
        self.defaultImage = defaultImage;
        self.iconImage = icon;
        
        self.imageView = [[UIImageView alloc]init];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)animateInView:(UIView *)view
{
    self.imageView.image = (self.iconImage) ? self.iconImage : self.defaultImage;
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imageView.layer.cornerRadius  = self.imageView.frame.size.height / 2.0;
    self.imageView.clipsToBounds = YES;
    self.originalFrame = self.frame;
    
    //从小变大然后回弹效果
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }completion:^(BOOL finished){
        [self lineDismissAnimation];
        
        [UIView animateWithDuration:0.8 delay:0.0
             usingSpringWithDamping:0.25
              initialSpringVelocity:10
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                             self.imageView.transform = CGAffineTransformIdentity;
                         }completion:^(BOOL finished) {
                             self.imageView.image = self.defaultImage;
                             [self floatingAnimation:self.inView starPoint:self.emitterEndPoint];
                         }];
    }];
    
    [self emitterAnimation:view];
}

#pragma mark - Animations
- (void)emitterAnimation:(UIView *)view
{
    NSTimeInterval totalAnimationDuration = 1.5;
    
    CGFloat viewSize    = CGRectGetWidth(self.bounds);
    CGFloat viewCenterX = self.center.x;
    CGFloat viewHeight  = CGRectGetHeight(view.bounds);
    
    //旋转角度
    NSInteger i = arc4random_uniform(2);
    NSInteger rotationDirection = 1 - (2 * i);// -1 OR 1
    
    //弹出路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.center];
    CGPoint endPoint = CGPointMake(viewCenterX + (rotationDirection) * arc4random_uniform(2*viewSize),
                                   viewHeight/5 * 4 - arc4random_uniform(viewHeight/15.0));
    [path addLineToPoint:endPoint];
    self.emitterEndPoint = endPoint;
    self.inView = view;
    
    CAKeyframeAnimation *emitterAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    emitterAnimation.path           = path.CGPath;
    emitterAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    emitterAnimation.duration       = totalAnimationDuration;
    emitterAnimation.delegate       = self;
    [self.layer addAnimation:emitterAnimation forKey:kEmitterAnimationKey];
    
}

- (void)lineDismissAnimation
{
    CGFloat totalAnimationDuration = 0.25;
    
    CGFloat perAngle = 2 * M_PI / 10;
    
    CGPoint centerPoint = CGPointMake(self.originalFrame.size.width / 2, self.originalFrame.size.width / 2);
    CGPoint startPoint  = centerPoint;
    CGPoint endPoint    = CGPointMake(0, 0);
    CGFloat radius      = self.originalFrame.size.width;
    for (int i = 0; i< 10; i++)
    {
        CGFloat startAngel = perAngle * i;
    
        startPoint.x = centerPoint.x + radius * cosf(startAngel) * 0.5;
        startPoint.y = centerPoint.y + radius * sinf(startAngel) * 0.5;
        
        endPoint.x = centerPoint.x + radius * cosf(startAngel);
        endPoint.y = centerPoint.y + radius * sinf(startAngel);
        
        UIBezierPath *linePath = [[UIBezierPath alloc]init];
        [linePath moveToPoint:startPoint];
        [linePath addLineToPoint:endPoint];
        linePath.lineCapStyle = kCGLineCapRound;
        
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.strokeColor   = (i % 2 == 0) ? [UIColor redColor].CGColor : [UIColor whiteColor].CGColor;
        perLayer.lineWidth     = 1;
        perLayer.path          = linePath.CGPath;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.duration  = totalAnimationDuration;
        pathAnimation.fromValue = @0;
        pathAnimation.toValue   = @1;
        pathAnimation.repeatCount = 1;
        [perLayer addAnimation:pathAnimation forKey:NSStringFromSelector(@selector(strokeEnd))];
        perLayer.strokeStart = 0.0;
        perLayer.strokeEnd   = 1;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            perLayer.strokeStart = 1.0;
            perLayer.strokeEnd   = 2.0;
        });

        [self.layer addSublayer:perLayer];
    }
}

- (void)floatingAnimation:(UIView *)view starPoint:(CGPoint)starPoint
{
    NSTimeInterval totalAnimationDuration = 1.5;
    
    NSInteger i = arc4random_uniform(2);
    NSInteger rotationDirection = 1 - ( 2 * i);
    NSInteger rotationFraction  = arc4random_uniform(10);
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeRotation(rotationDirection * M_PI/(16 + rotationFraction*0.2));
    } completion:NULL];
    
    UIBezierPath *travelPath = [UIBezierPath bezierPath];
    [travelPath moveToPoint:starPoint];

//    CGFloat viewHeight  = CGRectGetHeight(view.bounds);
//    CGFloat viewCenterX = self.center.x;
//    NSInteger j = arc4random_uniform(2);
//    NSInteger travelDirection = 1 - (2 * j);
    
//    //纵向移动
//    CGPoint endPoint = CGPointMake(viewCenterX + (rotationDirection) * arc4random_uniform(2 * viewWidth),
//                                   viewHeight/6.0 + arc4random_uniform(viewHeight/4.0));
//    CGFloat xDelta = (viewWidth/2.0 + arc4random_uniform(2 * viewWidth)) * travelDirection;
//    CGFloat yDelta = MAX(endPoint.y ,MAX(arc4random_uniform(8 * viewWidth), viewWidth));
//    CGPoint controlPoint1 = CGPointMake(viewCenterX + xDelta, viewHeight - yDelta);
//    CGPoint controlPoint2 = CGPointMake(viewCenterX - 2*xDelta, yDelta);
    
    //横向移动
    CGFloat viewWidth = CGRectGetWidth(view.bounds);
    NSInteger travelDirection = 1;
    CGPoint endPoint = CGPointMake(starPoint.x + viewWidth, starPoint.y);
    CGFloat xDelta = ([self getRandomNumber:viewWidth/2 to:viewWidth]) * travelDirection;
    CGFloat yDelta = [self getRandomNumber:starPoint.y + 30 to:starPoint.y + 130];
    CGPoint controlPoint1 = CGPointMake(xDelta , yDelta);
    CGPoint controlPoint2 = CGPointMake(xDelta * 2, 0.9 * yDelta);
    
    [travelPath addCurveToPoint:endPoint
                  controlPoint1:controlPoint1
                  controlPoint2:controlPoint2];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = travelPath.CGPath;
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyFrameAnimation.duration = totalAnimationDuration + endPoint.x/viewWidth;
    [self.layer addAnimation:keyFrameAnimation forKey:kFloatingAnimationKey];
    
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
