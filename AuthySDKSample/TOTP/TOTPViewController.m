//
//  TOTPViewController.m
//  AuthySDKSample
//
//  Created by Adriana Pineda on 5/4/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "TOTPViewController.h"
#import <TwilioAuth/TwilioAuth.h>

#import "UIColor+Extensions.h"
#import <CoreGraphics/CoreGraphics.h>

@interface TOTPViewController ()

@end

@implementation TOTPViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self configureTOTP];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTOTP {

    TwilioAuth *sharedTwiliAuth = [TwilioAuth sharedInstance];

    [sharedTwiliAuth getSyncedTOTP:^(NSString *totp, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (totp == nil) {
                return;
            }
            [self configureTOTPWithText:totp];
            [self configureTimer];
        });

    }];
}

- (void)configureTimer {

    [self showTimerAnimation];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(refreshTimer:) userInfo:nil repeats:NO];

}

- (void)configureTOTPWithText:(NSString *)totpText {

    NSMutableAttributedString *totpAttributedString = [[NSMutableAttributedString alloc] initWithString:totpText];
    [totpAttributedString addAttribute:NSKernAttributeName value:@5 range:NSMakeRange(0, totpAttributedString.length)];
    [self.totpLabel setAttributedText:totpAttributedString];
}

- (void)refreshTimer:(NSTimer *)timer {

    [self configureTOTP];

}

- (void)showTimerAnimation {

    CAShapeLayer *circle = [CAShapeLayer layer];
    int radius = 40;
    CGFloat xPosition = self.timerImage.bounds.size.width/2;
    CGFloat yPosition = self.timerImage.bounds.origin.y;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 2*M_PI - M_PI_2;

    circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xPosition, yPosition)
                                                 radius:radius
                                             startAngle:startAngle
                                               endAngle:endAngle
                                              clockwise:YES].CGPath;

    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor colorWithHexString:@"#1b89cf"].CGColor;
    circle.lineWidth = 8;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 20;
    animation.removedOnCompletion = NO;
    animation.fromValue = @(1);
    animation.toValue = @(0);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [circle addAnimation:animation forKey:@"drawCircleAnimation"];

    [self.timerImage.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.timerImage.layer addSublayer:circle];


}

@end
