//
//  DeviceResetManager.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 12/1/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceResetManager : NSObject

+ (void)resetDeviceAndGetRegistrationViewForCurrentView:(UIViewController *)viewController withCustomTitle:(NSString *)title;

@end
