//
//  RequestDetailViewController.h
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 11/26/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestDetailViewController : UIViewController

@property (nonatomic, strong) AUTApprovalRequest *approvalRequest;
@property (nonatomic, strong) AUTApp *currentApp;

@end
