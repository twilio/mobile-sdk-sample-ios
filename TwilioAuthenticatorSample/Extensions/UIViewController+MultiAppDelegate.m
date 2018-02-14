//
//  UIViewController+MultiAppDelegate.m
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 2/14/18.
//  Copyright © 2018 Authy. All rights reserved.
//

#import "UIViewController+MultiAppDelegate.h"

#import "DeviceResetManager.h"
#import "AppsListNavigationManager.h"

@interface UIViewController()

@property (nonatomic, strong) AUTApp *currentApp;

@end

@implementation UIViewController (MultiAppDelegate)

#pragma mark - App Delegate

- (void)didReceiveCodes:(NSArray<AUTApp *> *)apps {

}

- (void)didFail:(NSError *)error {

    if (error.code == AUTDeviceDeletedError) {
        [DeviceResetManager resetDeviceAndGetRegistrationViewForCurrentView:self withCustomTitle:nil];
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];

    // OK Action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [okAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
    [alert addAction:okAction];

    // Present Alert
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });

}


- (void)didUpdateApps:(NSArray<AUTApp*> *)apps {

    // Useful if we are displaying the name of the app
}

- (void)didAddApps:(NSArray<AUTApp *> *)apps {

    // Not needed for totp view only
}

- (void)didDeleteApps:(NSArray<NSNumber *> *)appsId {

    if (self.currentApp == nil) {
        return;
    }
    for (NSNumber *appId in appsId) {
        if (self.currentApp.appId == appId) {
            [AppsListNavigationManager presentAppsViewForCurrentView:self withCustomTitle:@"App Deleted" andMessage:@"App was deleted, go back to list view"];
        }
    }
}

@end
