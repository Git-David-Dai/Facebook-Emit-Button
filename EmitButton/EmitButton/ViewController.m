//
//  ViewController.m
//  EmitButton
//
//  Created by David.Dai on 2017/5/23.
//  Copyright © 2017年 David.Dai. All rights reserved.
//

#import "ViewController.h"
#import "EmitterView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showEmitterView)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)showEmitterView
{
    EmitterView* heart = [[EmitterView alloc] initWithDefaultImage:[UIImage imageNamed:@"like"]
                                                         iconImage:[UIImage imageNamed:@"love"]];
    heart.frame = CGRectMake(0, 0, 36, 36);
    [self.view addSubview:heart];
    CGPoint fountainSource = CGPointMake(20 + 36/2.0, self.view.bounds.size.height - 36/2.0 - 10);
    heart.center = fountainSource;
    [heart animateInView:self.view];
}


@end
