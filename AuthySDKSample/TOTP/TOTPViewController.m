//
//  TOTPViewController.m
//  AuthySDKSample
//
//  Created by Adriana Pineda on 5/4/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "TOTPViewController.h"
#import <TwilioAuth/TwilioAuth.h>

@interface TOTPViewController ()

@end

@implementation TOTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    TwilioAuth *sharedTwiliAuth = [TwilioAuth sharedInstance];
    NSError *totpError;
    self.totpLabel.text = [sharedTwiliAuth getTOTPWithError:&totpError];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
