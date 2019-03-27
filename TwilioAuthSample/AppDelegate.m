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
#import <UserNotifications/UserNotifications.h>

#define PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER @"onetouch_approval_request"
#define PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION @"PUSH_NOTIFICATION_ONETOUCH_APPROVE"
#define PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION @"PUSH_NOTIFICATION_ONETOUCH_DENY"
#define PUSH_NOTIFICATION_ONETOUCH_APPROVE_TEXT @"Approve"
#define PUSH_NOTIFICATION_ONETOUCH_DENY_TEXT @"Deny"
#define ONE_TOUCH_PUSH_NOTIFICATION_APPROVAL_REQUEST_UUID @"approval_request_uuid"
#define PUSH_NOTIFICATION_TYPE_KEY @"type"

@implementation AppDelegate

@synthesize nav;
@synthesize window;

- (void)setupTwilioAuthConfiguration {
    TwilioAuthConfiguration *config = [TwilioAuthConfiguration configurationWithUserDefaultsGroup:@"group.twilio.auth.sample.12345"];
    [TwilioAuth setupWithConfiguration:config];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Register for push notifications
    [self registerForPushNotifications:application];

    [self setupTwilioAuthConfiguration];

    // Configure Root View Controller
    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];

    if ([sharedTwilioAuth isDeviceRegistered]) {
        [self configureRootController];
    }

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

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

- (void)configureRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler {

    if (![self isOneTouchPushNotificationRequest:userInfo]) {
        return;
    }

    [self updateOneTouchRequestFromNotificationWithStatus:identifier userInfo:userInfo completionHandler:completionHandler];
}


- (void)updateOneTouchRequestFromNotificationWithStatus:(NSString *)statusOption userInfo:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {

    AUTApprovalRequestStatus status;
    if ([statusOption isEqualToString:PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION]) {
        status = AUTApprovalRequestStatusApproved;
    } else if ([statusOption isEqualToString:PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION]) {
        status = AUTApprovalRequestStatusDenied;
    } else {
        return;
    }

    NSString *approvalRequestUUID = [userInfo objectForKey:ONE_TOUCH_PUSH_NOTIFICATION_APPROVAL_REQUEST_UUID];
    if (approvalRequestUUID == nil || [approvalRequestUUID isEqualToString:@""]) {
        return;
    }

    [self setupTwilioAuthConfiguration];
    TwilioAuth *sharedAuth = [TwilioAuth sharedInstance];
    [sharedAuth getRequestWithUUID:approvalRequestUUID completion:^(AUTApprovalRequest *request, NSError *error) {

        if (status == AUTApprovalRequestStatusApproved) {
            [self approveRequest:request completionHandler:completionHandler];
        } else {
            [self denyRequest:request completionHandler:completionHandler];
        }

    }];

}

- (void)approveRequest:(AUTApprovalRequest *)request completionHandler:(void (^)())completionHandler {

    TwilioAuth *sharedAuth = [TwilioAuth sharedInstance];
    [sharedAuth approveRequest:request completion:^(NSError *error) {

        if (completionHandler) {
            completionHandler();
        }

    }];

}

- (void)denyRequest:(AUTApprovalRequest *)request completionHandler:(void (^)())completionHandler {

    TwilioAuth *sharedAuth = [TwilioAuth sharedInstance];
    [sharedAuth denyRequest:request completion:^(NSError *error) {

        if (completionHandler) {
            completionHandler();
        }

    }];

}

- (BOOL)isOneTouchPushNotificationRequest:(NSDictionary *)userInfo {

    NSString *notificationType = [userInfo objectForKey:PUSH_NOTIFICATION_TYPE_KEY];
    if ([notificationType isEqualToString:PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER]) {
        return YES;
    }

    return NO;
}

#pragma mark - Register for Push Notifications
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *deviceTokenAsString = [[[[deviceToken description]
       stringByReplacingOccurrencesOfString: @"<" withString: @""]
      stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSLog(@"Device token %@", deviceTokenAsString);

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

- (UIMutableUserNotificationAction *)getApproveActionForNotificationsForiOS8AndAbove {

    UIMutableUserNotificationAction *approveAction = [[UIMutableUserNotificationAction alloc] init];
    [approveAction setActivationMode:UIUserNotificationActivationModeBackground];
    [approveAction setTitle:PUSH_NOTIFICATION_ONETOUCH_APPROVE_TEXT];
    [approveAction setIdentifier:PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION];
    [approveAction setDestructive:NO];
    [approveAction setAuthenticationRequired:YES];

    return approveAction;
}

- (UIMutableUserNotificationAction *)getDenyActionForNotificationsForiOS8AndAbove {

    UIMutableUserNotificationAction *denyAction = [[UIMutableUserNotificationAction alloc] init];
    [denyAction setActivationMode:UIUserNotificationActivationModeBackground];
    [denyAction setTitle:PUSH_NOTIFICATION_ONETOUCH_DENY_TEXT];
    [denyAction setIdentifier:PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION];
    [denyAction setDestructive:YES];
    [denyAction setAuthenticationRequired:YES];

    return denyAction;
}

- (UIMutableUserNotificationCategory *)getOneTouchCategoryForiOS8AndAboveWithActions:(NSArray *)actions {

    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER];
    [actionCategory setActions:actions
                    forContext:UIUserNotificationActionContextDefault];

    return actionCategory;
}

- (UIMutableUserNotificationCategory *)getOneTouchCategoryForiOS8AndAbove {

    UIMutableUserNotificationAction *approveAction = [self getApproveActionForNotificationsForiOS8AndAbove];

    UIMutableUserNotificationAction *denyAction = [self getDenyActionForNotificationsForiOS8AndAbove];

    UIMutableUserNotificationCategory *actionCategory = [self getOneTouchCategoryForiOS8AndAboveWithActions:@[approveAction, denyAction]];

    return actionCategory;
}

- (UIUserNotificationSettings *)getNotificationSettingsForiOS8AndAboveWithCategories:(NSSet *)categories {

    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);

    if (categories != nil) {
        return [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    } else {
        return [UIUserNotificationSettings settingsForTypes:types
                                                 categories:nil];
    }

}

- (void)registerForRemoteNotificationsWithActionsForiOS8AndAbove {

    /** Sample code for onetouch push notification payload
     {
     alert = "OneTouch Testing just sent you a new approval request";
     "approval_request_uuid" = "407802b0-3e4e-0135-ee46-06ca50569adc";
     aps =     {
     alert = "OneTouch Testing just sent you a new approval request";
     badge = 1;
     category = "onetouch_approval_request";
     sound = default;
     };
     "serial_id" = 1053915;
     "twi_message_id" = APN54d05980bbf64376a0b402de620f2b96;
     type = "onetouch_approval_request";
     }
     */


    UIMutableUserNotificationCategory *actionCategory = [self getOneTouchCategoryForiOS8AndAbove];
    NSSet *categories = [NSSet setWithObject:actionCategory];

    UIUserNotificationSettings *settings = [self getNotificationSettingsForiOS8AndAboveWithCategories:categories];

    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


- (void)registerForPushNotifications:(UIApplication *)application {

    if (@available(iOS 10, *)) {

        [self registerForRemoteNotificationsWithActionsForApplication:application];

    } else if (@available(iOS 8, *)) {

        [self registerForRemoteNotificationsWithActionsForiOS8AndAbove];

    }

}

- (UNNotificationAction *)getApproveActionForNotificationsForiOS10AndAbove {

    UNNotificationAction *approveAction = [UNNotificationAction actionWithIdentifier:PUSH_NOTIFICATION_ONETOUCH_APPROVE_OPTION title:PUSH_NOTIFICATION_ONETOUCH_APPROVE_TEXT options:UNNotificationActionOptionAuthenticationRequired];

    return approveAction;
}

- (UNNotificationAction *)getDenyActionForNotificationsForiOS10AndAbove {

    UNNotificationAction *denyAction = [UNNotificationAction actionWithIdentifier:PUSH_NOTIFICATION_ONETOUCH_DENY_OPTION title:PUSH_NOTIFICATION_ONETOUCH_DENY_TEXT options:UNNotificationActionOptionDestructive | UNNotificationActionOptionAuthenticationRequired];

    return denyAction;

}

- (UNNotificationCategory *)getOneTouchCategoryForiOS10AndAboveWithActions:(NSArray *)actions {

    UNNotificationCategory *actionCategory = [UNNotificationCategory categoryWithIdentifier:PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER actions:actions intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    return actionCategory;
}

- (UNNotificationCategory *)getOneTouchCategoryForiOS10AndAbove {

    UNNotificationAction *approveAction = [self getApproveActionForNotificationsForiOS10AndAbove];

    UNNotificationAction *denyAction = [self getDenyActionForNotificationsForiOS10AndAbove];

    UNNotificationCategory *actionCategory = [self getOneTouchCategoryForiOS10AndAboveWithActions:@[approveAction, denyAction]];

    return actionCategory;
}

- (void)registerForRemoteNotificationsWithActionsForApplication:(UIApplication *)application {

    /** Sample code for onetouch push notification payload
     {
     alert = "OneTouch Testing just sent you a new approval request";
     "approval_request_uuid" = "407802b0-3e4e-0135-ee46-06ca50569adc";
     aps =     {
     alert = "OneTouch Testing just sent you a new approval request";
     badge = 1;
     category = "onetouch_approval_request";
     sound = default;
     };
     "serial_id" = 1053915;
     "twi_message_id" = APN54d05980bbf64376a0b402de620f2b96;
     type = "onetouch_approval_request";
     }
     */

    UNNotificationCategory *actionCategory = [self getOneTouchCategoryForiOS10AndAbove];
    NSSet *categories = [NSSet setWithObject:actionCategory];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:categories];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    }];

    [application registerForRemoteNotifications];

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

    if ([notificationType isEqualToString:@"remove_push"]) {
        [self removePushNotifications];
        return;
    }

    if (![notificationType isEqualToString:@"onetouch_approval_request"]) {
        return;
    }

    NSString *approvalRequestUUID = [userInfo objectForKey:@"approval_request_uuid"];
    [self setupTwilioAuthConfiguration];
    TwilioAuth *twilioAuth = [TwilioAuth sharedInstance];
    [twilioAuth getRequestWithUUID:approvalRequestUUID completion:^(AUTApprovalRequest *request, NSError *error) {

        if (error != nil) {
            return;
        }

        if ([request.uuid isEqualToString:approvalRequestUUID]) {
            [self presentRequestDetailForApprovalRequest:request];
        }

    }];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handlePushNotificationWithInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    [self handlePushNotificationWithInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);

}

// Example of how to remove push notifications
// Push notification category "remove_push" is not being sent in production
- (void)removePushNotifications {

    /**
     Sample payload of `remove_push` notification
     {"aps":{"content-available":1, "sound":""}, "type":"remove_push"}
     */

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {

        NSMutableArray *identifiersToRemove = [[NSMutableArray alloc] init];

        for (UNNotification *notification in notifications) {
            if ([notification.request.content.categoryIdentifier isEqualToString:PUSH_NOTIFICATION_ONETOUCH_CATEGORY_IDENTIFIER]) {
                [identifiersToRemove addObject:notification.request.identifier];
            }
        }

        [center removeDeliveredNotificationsWithIdentifiers:identifiersToRemove];
    }];
}

@end
