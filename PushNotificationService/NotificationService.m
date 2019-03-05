//
//  NotificationService.m
//  PushNotificationService
//
//  Created by Adriana Pineda on 1/21/19.
//  Copyright © 2019 Authy. All rights reserved.
//

#import "NotificationService.h"
#import <TwilioAuth/TwilioAuth.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    TwilioAuthConfiguration *config = [TwilioAuthConfiguration configurationWithUserDefaultsGroup:@"group.twilio.auth.sample.12345"];
    [TwilioAuth setupWithConfiguration:config];
    TwilioAuth *sharedAuth = [TwilioAuth sharedInstance];
    NSString *uuid = [request.content.userInfo objectForKey:@"approval_request_uuid"];
    [sharedAuth getRequestWithUUID:uuid completion:^(AUTApprovalRequest *request, NSError *error) {
        self.bestAttemptContent.title = request.message;
        self.bestAttemptContent.body = @"This is a custom push";
        self.contentHandler(self.bestAttemptContent);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
