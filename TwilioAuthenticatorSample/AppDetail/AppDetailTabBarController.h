//
//  AppDetailTabBarController.h
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 2/14/18.
//  Copyright © 2018 Authy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwilioAuthenticator/TwilioAuthenticator.h>

@interface AppDetailTabBarController : UITabBarController <AUTMultiAppDelegate>

@property (nonatomic, strong) AUTApp *currentApp;

- (void)triggerAppCodeGeneration;

@end
