//
//  UITextField+Extensions.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 2/20/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "UITextField+Extensions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextField (Extensions)

-(void)configureBottomBorder {

    CGRect rect = self.frame;
    CGFloat underLineWide = 1.0;
    UIColor *underlineColor = [UIColor blackColor];

    UIView *underlineView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - underLineWide, rect.size.width, underLineWide)];
    [underlineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [underlineView setBackgroundColor:underlineColor];

    [self addSubview:underlineView];
}

@end
