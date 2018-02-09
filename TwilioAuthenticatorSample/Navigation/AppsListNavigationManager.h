//
//  AppsListNavigationManager.h
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 2/9/18.
//  Copyright © 2018 Authy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppsListNavigationManager : NSObject

+ (void)presentAppsViewForCurrentView:(UIViewController *)viewController withCustomTitle:(NSString *)title andMessage:(NSString *)message;

@end
