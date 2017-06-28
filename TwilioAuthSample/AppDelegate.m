//
//  AppDelegate.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "AppDelegate.h"
#import <TwilioAuth/TwilioAuth.h>

#import "ApprovalRequestsViewController.h"
#import "RequestDetailViewController.h"

@implementation AppDelegate

@synthesize nav;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Register for push notifications
    [self registerForPushNotifications:application];

    // Configure Root View Controller
    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];

    if ([sharedTwilioAuth isDeviceRegistered]) {
        [self configureRootController];
    }

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    NSDictionary *notificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (notificationInfo) {
        [self handlePushNotificationWithInfo:notificationInfo];
    }

    return YES;
}

- (void)configureRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"application will resign active");
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"application will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSLog(@"application did become active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"application did enter background");
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

    if (notificationSettings != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

#pragma mark - Push Notifications
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *deviceTokenAsString = [[[[deviceToken description]
       stringByReplacingOccurrencesOfString: @"<" withString: @""]
      stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSString *currentPushToken = [userDefaults objectForKey:@"PUSH_TOKEN"];

    // First time storing the push token
    if (!currentPushToken || [currentPushToken isEqualToString:@""]) {
        [userDefaults setObject:deviceTokenAsString forKey:@"PUSH_TOKEN"];
        return;
    }

    // Check if device has been registered
    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];
    if (![sharedTwilioAuth isDeviceRegistered]) {
        return;
    }

    // Check if push token has changed
    BOOL hasPushTokenChanged = ![deviceTokenAsString isEqualToString:currentPushToken];
    if (!hasPushTokenChanged) {
        return;
    }

    // Configure push token
    [sharedTwilioAuth setPushToken:deviceTokenAsString completion:^(NSError * _Nullable error) {

        if (error) {
            NSLog(@"Error configuring push token");
        } else {
            NSLog(@"Configure push token successfully");
            [userDefaults setObject:deviceTokenAsString forKey:@"PUSH_TOKEN"];
        }

    }];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register notification: %@", [error localizedDescription]);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {

    [self handlePushNotificationWithInfo:userInfo];

}

- (void)registerForPushNotifications:(UIApplication *)application {

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];

    [application registerUserNotificationSettings:settings];
}

- (void)handlePushNotificationWithInfo:(NSDictionary*)userInfo {

    NSString *notificationType = [userInfo objectForKey:@"type"];
    if (![notificationType isEqualToString:@"onetouch_approval_request"]) {
        return;
    }

    NSString *approvalRequestUUID = [userInfo objectForKey:@"approval_request_uuid"];
    TwilioAuth *twilioAuth = [TwilioAuth sharedInstance];
    [twilioAuth getApprovalRequestsWithStatuses:AUTApprovalRequestStatusPending timeInterval:nil completion:^(AUTApprovalRequests * _Nullable approvalRequests, NSError * _Nullable error) {

        if (error != nil) {
            return;
        }

        for (AUTApprovalRequest *pendingRequest in approvalRequests.pending) {

            if ([pendingRequest.uuid isEqualToString:approvalRequestUUID]) {


                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                RequestDetailViewController *requestDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"approvalRequestDetail"];
                requestDetailViewController.approvalRequest = pendingRequest;

                UIViewController *currentViewController = self.window.rootViewController;
                UIViewController *presentedViewController = currentViewController.presentedViewController;

                UINavigationController *currentNavigationController;

                if (presentedViewController != nil && [presentedViewController isKindOfClass:[UINavigationController class]]) {

                    currentNavigationController = (UINavigationController *)presentedViewController;

                } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {

                    currentNavigationController = (UINavigationController *)currentViewController;

                }

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (currentNavigationController != nil) {
                        [currentNavigationController pushViewController:requestDetailViewController animated:YES];
                    }

                });

                return;
            }
        }
    }];

}

@end
