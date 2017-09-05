//
//  DeviceResetManager.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 12/1/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "DeviceResetManager.h"
#import "RegisterDeviceViewController.h"

@implementation DeviceResetManager

+ (void)resetDeviceAndGetRegistrationViewForCurrentView:(UIViewController *)viewController withCustomTitle:(NSString *)title {

    NSString *alertTitle = @"";
    if (title == nil) {
        alertTitle = @"Device deleted";
    } else {
        alertTitle = title;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:@"Enter a new Authy ID and Backend URL" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        RegisterDeviceViewController *registerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"registerDeviceView"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:registerViewController];

        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:navigationController animated:YES completion:nil];
        });

    }];

    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:nil];

}
@end
