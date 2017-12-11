//
//  TOTPViewController.m
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 5/4/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "TOTPViewController.h"

#import "Constants.h"
#import "UIColor+Extensions.h"
#import <CoreGraphics/CoreGraphics.h>

#define circleRadius 25
#define circleLineWidth 6

@interface TOTPViewController ()

@property (nonatomic, strong) NSTimer *totpTimer;

@end

@implementation TOTPViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self drawBackgroundCircle];

    [self configureTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureNavigationBar];
    [self configureTOTP];
}

- (void)viewWillDisappear:(BOOL)animated {

    [self invalidateTimer];
}

- (void)invalidateTimer {

    if (self.totpTimer) {
        [self.totpTimer invalidate];
        self.totpTimer = nil;
    }

}

- (void)configureNavigationBar {

    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.navigationItem.title = @"Tokens";
    self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTOTP {

    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];
    [sharedTwilioAuth getTOTPsWithDelegate:self];

}

- (void)configureTimer {

    [self invalidateTimer];
    [self showTimerAnimation];
    self.totpTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(refreshTimer:) userInfo:nil repeats:NO];

}

- (void)configureTOTPWithText:(NSDictionary <NSString*, NSString*> *)totps {

    NSString *serialIdAsString = [NSString stringWithFormat:@"%@", self.currentAppId];


    NSString *totpText = [totps objectForKey:serialIdAsString];
    NSMutableAttributedString *totpAttributedString;
    if(totpText) {
        totpAttributedString = [[NSMutableAttributedString alloc] initWithString:totpText];
    } else {
        totpAttributedString = [[NSMutableAttributedString alloc] initWithString:@"------"];
    }
    [totpAttributedString addAttribute:NSKernAttributeName value:@3.5 range:NSMakeRange(0, totpAttributedString.length)];
    [self.totpLabel setAttributedText:totpAttributedString];
}

- (void)refreshTimer:(NSTimer *)timer {
    [self configureTOTP];
}

- (void)showTimerAnimation {

    CAShapeLayer *circle = [CAShapeLayer layer];
    CGFloat xPosition = self.timerImage.layer.bounds.size.width/2;
    CGFloat yPosition = self.timerImage.layer.bounds.size.height/2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 2*M_PI - M_PI_2;

    circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xPosition, yPosition)
                                                 radius:circleRadius
                                             startAngle:startAngle
                                               endAngle:endAngle
                                              clockwise:YES].CGPath;

    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor colorWithHexString:defaultColor].CGColor;
    circle.lineWidth = circleLineWidth;

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

- (void)drawBackgroundCircle {

    UIImage *circle = nil;

    CGSize size = self.timerImage.layer.bounds.size;

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, rect);

    [[UIColor colorWithHexString:@"#D9D9D9"] setStroke];

    CGFloat xPosition = size.width/2;
    CGFloat yPosition = size.height/2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 2*M_PI - M_PI_2;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xPosition, yPosition)
                                                 radius:circleRadius
                                             startAngle:startAngle
                                               endAngle:endAngle
                                              clockwise:YES];


    path.lineWidth = circleLineWidth;
    [path stroke];

    CGContextRestoreGState(ctx);
    circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.timerImage setImage:circle];


}

#pragma mark - TOTP Delegate
- (void)didReceiveTOTP:(NSDictionary <NSString*, NSString*> *)totps withError:(NSError *)error {

    dispatch_async(dispatch_get_main_queue(), ^{

        if (error != nil) {
            NSLog(@"Error %@", error.localizedDescription);
            return;
        }

        if (totps == nil) {
            return;
        }

        [self configureTOTPWithText:totps];
        [self configureTimer];

    });
}

@end
