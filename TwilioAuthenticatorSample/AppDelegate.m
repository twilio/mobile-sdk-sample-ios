//
//  AppDelegate.m
//  TwilioAuthenticatorSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "AppDelegate.h"

#import "ApprovalRequestsViewController.h"
#import "RequestDetailViewController.h"

#define ONE_TOUCH_PUSH_NOTIFICATION_APPROVAL_REQUEST_UUID @"approval_request_uuid"
#define PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER @"onetouch_approval_request"
#define PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION @"PUSH_NOTIFICATION_ONETOUCH_APPROVE"
#define PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION @"PUSH_NOTIFICATION_ONETOUCH_DENY"
#define PUSH_NOTIFICATION_ONETOUCH_APPROVE_TEXT @"Approve"
#define PUSH_NOTIFICATION_ONETOUCH_DENY_TEXT @"Deny"

@implementation AppDelegate

@synthesize nav;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Register for push notifications
    [self registerForPushNotifications:application];

    // Configure Root View Controller
    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];

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

- (void)configureRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITableViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"appsTableViewController"];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}

#pragma mark - Register for Push Notifications
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *deviceTokenAsString = [[[[deviceToken description]
       stringByReplacingOccurrencesOfString: @"<" withString: @""]
      stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"Push token: %@", deviceTokenAsString);

    NSString *currentPushToken = [userDefaults objectForKey:@"PUSH_TOKEN"];

    // First time storing the push token
    if (!currentPushToken || [currentPushToken isEqualToString:@""]) {
        [userDefaults setObject:deviceTokenAsString forKey:@"PUSH_TOKEN"];
        return;
    }

    // Check if device has been registered
    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];
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

- (void)registerForPushNotifications:(UIApplication *)application {

    UIMutableUserNotificationAction *approveAction = [[UIMutableUserNotificationAction alloc] init];
    [approveAction setActivationMode:UIUserNotificationActivationModeBackground];
    [approveAction setTitle:PUSH_NOTIFICATION_ONETOUCH_APPROVE_TEXT];
    [approveAction setIdentifier:PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION];
    [approveAction setDestructive:NO];
    [approveAction setAuthenticationRequired:YES];

    UIMutableUserNotificationAction *denyAction = [[UIMutableUserNotificationAction alloc] init];
    [denyAction setActivationMode:UIUserNotificationActivationModeBackground];
    [denyAction setTitle:PUSH_NOTIFICATION_ONETOUCH_DENY_TEXT];
    [denyAction setIdentifier:PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION];
    [denyAction setDestructive:YES];
    [denyAction setAuthenticationRequired:YES];


    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER];
    [actionCategory setActions:@[approveAction, denyAction]
                    forContext:UIUserNotificationActionContextDefault];

    NSSet *categories = [NSSet setWithObject:actionCategory];

    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];


    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    [self handlePushNotificationSelectedWithIdentifier:identifier andUserInfo:notification.userInfo completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {

    [self handlePushNotificationSelectedWithIdentifier:identifier andUserInfo:notification.userInfo completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [self handlePushNotificationSelectedWithIdentifier:identifier andUserInfo:userInfo completionHandler:completionHandler];
}

- (void)approveRequest:(AUTApprovalRequest *)request completionHandler:(void (^)())completionHandler {

    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];
    [sharedTwilioAuth approveRequest:request completion:^(NSError *error) {

        if (error == nil) {
            NSLog(@"**** Request approved successfully");
        } else {
            NSLog(@"**** Request could not be approved %@", error.localizedDescription);
        }

        completionHandler();
    }];

}

- (void)denyRequest:(AUTApprovalRequest *)request completionHandler:(void (^)())completionHandler {

    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];
    [sharedTwilioAuth denyRequest:request completion:^(NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"**** Request denied successfully");
        } else {
            NSLog(@"**** Request could not be denied %@", error.localizedDescription);
        }

        completionHandler();
    }];

}

- (void)handlePushNotificationSelectedWithIdentifier:(NSString *)identifier andUserInfo:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {

    TwilioAuthenticator *sharedTwilioAuth = [TwilioAuthenticator sharedInstance];

    AUTApprovalRequestStatus status;
    if ([identifier isEqualToString:PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION]) {
        status = AUTApprovalRequestStatusApproved;
    } else if ([identifier isEqualToString:PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION]) {
        status = AUTApprovalRequestStatusDenied;
    } else {
        return;
    }

    NSString *approvalRequestUUID = [userInfo objectForKey:ONE_TOUCH_PUSH_NOTIFICATION_APPROVAL_REQUEST_UUID];
    if (approvalRequestUUID == nil || [approvalRequestUUID isEqualToString:@""]) {
        return;
    }

    [sharedTwilioAuth getRequestWithUUID:approvalRequestUUID completion:^(AUTApprovalRequest *request, NSError *error) {

        if(request == nil) {
            completionHandler();
            return;
        }

        if (status == AUTApprovalRequestStatusApproved) {
            [self approveRequest:request completionHandler:completionHandler];
        } else {
            [self denyRequest:request completionHandler:completionHandler];
        }

    }];

}

#pragma mark - Handle Push Notification
- (UINavigationController *)getCurrentNavigationController {

    UIViewController *currentViewController = self.window.rootViewController;
    UIViewController *presentedViewController = currentViewController.presentedViewController;

    UINavigationController *currentNavigationController;

    if (presentedViewController != nil && [presentedViewController isKindOfClass:[UINavigationController class]]) {

        currentNavigationController = (UINavigationController *)presentedViewController;

    } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {

        currentNavigationController = (UINavigationController *)currentViewController;

    }

    return currentNavigationController;
}

- (RequestDetailViewController *)getRequestDetailForApprovalRequest:(AUTApprovalRequest *)request {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RequestDetailViewController *requestDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"approvalRequestDetail"];
    requestDetailViewController.approvalRequest = request;

    return requestDetailViewController;
}

- (void)presentRequestDetailForApprovalRequest:(AUTApprovalRequest *)request {

    UINavigationController *currentNavigationController = [self getCurrentNavigationController];
    RequestDetailViewController *requestDetailViewController = [self getRequestDetailForApprovalRequest:request];

    dispatch_async(dispatch_get_main_queue(), ^{

        if (currentNavigationController != nil) {
            [currentNavigationController pushViewController:requestDetailViewController animated:YES];
        }

    });

}

- (void)handlePushNotificationWithInfo:(NSDictionary*)userInfo {

    NSString *notificationType = [userInfo objectForKey:@"type"];
    if (![notificationType isEqualToString:@"onetouch_approval_request"]) {
        return;
    }

    NSString *approvalRequestUUID = [userInfo objectForKey:@"approval_request_uuid"];

    TwilioAuthenticator *twilioAuth = [TwilioAuthenticator sharedInstance];
    [twilioAuth getRequestWithUUID:approvalRequestUUID completion:^(AUTApprovalRequest *request, NSError *error) {

        if (error != nil) {
            return;
        }

        if ([request.uuid isEqualToString:approvalRequestUUID]) {
            [self presentRequestDetailForApprovalRequest:request];
        }

    }];

}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {

    [self handlePushNotificationWithInfo:userInfo];
}

@end
