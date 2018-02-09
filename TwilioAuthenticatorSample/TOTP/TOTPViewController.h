//
//  TOTPViewController.h
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 5/4/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOTPViewController : UIViewController <AUTMultiAppDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totpLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenName;
@property (weak, nonatomic) IBOutlet UIImageView *timerImage;

@property (nonatomic, strong) NSNumber *currentAppId;

@end
