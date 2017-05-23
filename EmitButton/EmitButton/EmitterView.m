//
//  EmitterView.m
//  EmitButton
//
//  Created by David.Dai on 2017/5/23.
//  Copyright © 2017年 David.Dai. All rights reserved.
//

#import "EmitterView.h"

@interface EmitterView()<CAAnimationDelegate>
@property (nonatomic,strong) UIImage *defaultImage;
@property (nonatomic,strong) UIImage *iconImage;
@end

@implementation EmitterView

- (instancetype)initWithDefaultImage:(UIImage *)defaultImage iconImage:(UIImage *)icon
{
    if(self = [super initWithImage:defaultImage]){
        self.defaultImage = defaultImage;
        self.iconImage = icon;
    }
    return self;
}

- (void)animateInView:(UIView *)view{
    
    //Pre-Animation setup
    self.transform = CGAffineTransformMakeScale(0, 0);
    self.alpha = 0;
    
    self.image = (self.iconImage) ? self.iconImage : self.defaultImage;
    
    //心跳回弹效果
    [UIView animateWithDuration:1
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 0.9;
                         
                         
    } completion:NULL];


    [self emitterAnimation:view];
}

- (void)emitterAnimation:(UIView *)view
{
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
    
    CAKeyframeAnimation *emitterAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    emitterAnimation.path           = path.CGPath;
    emitterAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    emitterAnimation.duration       = 1;
    emitterAnimation.delegate       = self;
    [self.layer addAnimation:emitterAnimation forKey:@"positionOnPath"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self lineDismissAnimation];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self floatingAnimation:view starPoint:endPoint];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.image = self.defaultImage;
}

- (void)lineDismissAnimation
{
    CGFloat perAngle = 2 * M_PI / 10;
    
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    CGPoint startPoint  = centerPoint;
    CGPoint endPoint    = CGPointMake(0, 0);
    CGFloat radius      = self.frame.size.width;
    CGFloat duration    = 0.4;
    for (int i = 0; i< 10; i++)
    {
        CGFloat startAngel = perAngle * i;
    
        startPoint.x = centerPoint.x + radius * cosf(startAngel) * 0.7;
        startPoint.y = centerPoint.y + radius * sinf(startAngel) * 0.7;
        
        endPoint.x = centerPoint.x + radius * cosf(startAngel);
        endPoint.y = centerPoint.y + radius * sinf(startAngel);
        
        UIBezierPath *linePath = [[UIBezierPath alloc]init];
        [linePath moveToPoint:startPoint];
        [linePath addLineToPoint:endPoint];
        linePath.lineCapStyle = kCGLineCapRound;
        
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.strokeColor   = [UIColor whiteColor].CGColor;
        perLayer.lineWidth     = 1;
        perLayer.path          = linePath.CGPath;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.duration  = duration;
        pathAnimation.fromValue = @0;
        pathAnimation.toValue   = @1;
        pathAnimation.repeatCount = 1;
        [perLayer addAnimation:pathAnimation forKey:NSStringFromSelector(@selector(strokeEnd))];
        perLayer.strokeStart = 0.0;
        perLayer.strokeEnd   = 1;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            perLayer.strokeStart = 1.0;
            perLayer.strokeEnd   = 2.0;
        });

        [self.layer addSublayer:perLayer];
    }
}

- (void)floatingAnimation:(UIView *)view starPoint:(CGPoint)starPoint
{
    NSTimeInterval totalAnimationDuration = 3;
    CGFloat viewSize = CGRectGetWidth(self.bounds);
    CGFloat viewCenterX = self.center.x;
    CGFloat viewHeight = CGRectGetHeight(view.bounds);
    
    NSInteger i = arc4random_uniform(2);
    NSInteger rotationDirection = 1 - (2*i);// -1 OR 1
    NSInteger rotationFraction  = arc4random_uniform(10);
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeRotation(rotationDirection * M_PI/(16 + rotationFraction*0.2));
    } completion:NULL];
    
    UIBezierPath *travelPath = [UIBezierPath bezierPath];
    [travelPath moveToPoint:starPoint];
    
    CGPoint endPoint = CGPointMake(viewCenterX + (rotationDirection) * arc4random_uniform(2*viewSize), viewHeight/6.0 + arc4random_uniform(viewHeight/4.0));
    
    NSInteger j = arc4random_uniform(2);
    NSInteger travelDirection = 1 - (2*j);// -1 OR 1
    
    //三节贝塞尔曲线
    CGFloat xDelta = (viewSize/2.0 + arc4random_uniform(2 * viewSize)) * travelDirection;
    CGFloat yDelta = MAX(endPoint.y ,MAX(arc4random_uniform(8 * viewSize), viewSize));
    CGPoint controlPoint1 = CGPointMake(viewCenterX + xDelta, viewHeight - yDelta);
    CGPoint controlPoint2 = CGPointMake(viewCenterX - 2*xDelta, yDelta);
    
    [travelPath addCurveToPoint:endPoint
                  controlPoint1:controlPoint1
                  controlPoint2:controlPoint2];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = travelPath.CGPath;
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyFrameAnimation.duration = totalAnimationDuration + endPoint.y/viewHeight;
    [self.layer addAnimation:keyFrameAnimation forKey:@"positionOnPath"];
    
    //Alpha & remove from superview
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}


@end
