//
//  AUTApprovalRequest+Extensions.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "AUTApprovalRequest+Extensions.h"
#import "NSDate+Extensions.h"

@implementation AUTApprovalRequest (Extensions)

- (BOOL)isExpired {

    long todaysTimestamp = [[NSDate date] timeIntervalSince1970];
    long expiredTimestamp = self.expirationTimestamp;
    if (self.status == AUTApprovalRequestStatusExpired || (todaysTimestamp > expiredTimestamp)) {
        return YES;
    }

    return NO;
}

- (NSString *)expiredDateAsString {

    if(self.expirationTimestamp <= 0){
        return @"";
    }

    if (self.status == AUTApprovalRequestStatusApproved) {
        return @"Approved";
    }

    if (self.status == AUTApprovalRequestStatusDenied) {
        return @"Denied";
    }

    if (self.status == AUTApprovalRequestStatusExpired || self.status == AUTApprovalRequestStatusPending) {

        NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:self.expirationTimestamp];
        return [expirationDate expirationTimeAsString];
    }

    return @"";

}

- (NSString *)timeAgoAsString {

    if (self.creationTimestamp <= 0) {
        return @"";
    }

    NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:self.creationTimestamp];
    return [creationDate timeAgoAsString];
}
@end
