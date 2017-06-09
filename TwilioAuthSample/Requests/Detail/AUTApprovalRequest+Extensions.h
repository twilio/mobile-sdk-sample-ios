//
//  AUTApprovalRequest+Extensions.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import <TwilioAuth/TwilioAuth.h>

@interface AUTApprovalRequest (Extensions)

- (BOOL)isExpired;
- (NSString *)expiredDateAsString;
- (NSString *)timeAgoAsString;

@end
