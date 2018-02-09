//
//  AppsListNavigationManager.m
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 2/9/18.
//  Copyright © 2018 Authy. All rights reserved.
//

#import "AppsListNavigationManager.h"
#import "AppsTableViewController.h"

@implementation AppsListNavigationManager

+ (void)presentAppsViewForCurrentView:(UIViewController *)viewController withCustomTitle:(NSString *)title andMessage:(NSString *)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // OK Action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AppsTableViewController *appsController = [mainStoryboard instantiateViewControllerWithIdentifier:@"appsTableViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:appsController];

        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:navigationController animated:YES completion:nil];
        });

    }];

    [okAction setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];

    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:nil];

}
@end
