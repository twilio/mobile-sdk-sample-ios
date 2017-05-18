//
//  AppDelegate.m
//  AuthySDKSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "AppDelegate.h"
#import <TwilioAuth/TwilioAuth.h>

#import "ApprovalRequestsViewController.h"

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
}

- (void)registerForPushNotifications:(UIApplication *)application {

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];

    [application registerUserNotificationSettings:settings];
}

- (void)configureRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UITabBarController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}
@end
