//
//  AUTApprovalRequests.h
//  TwilioAuth
//
//  Created by Adriana Pineda on 11/24/16.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>
#import "AUTApprovalRequest.h"

/**
 This class includes arrays of requests differentiated by status
 ## Version information

 __Version__: 1.0.0
 */
@interface AUTApprovalRequests : NSObject

/**
 Array of pending requests of type <AUTApprovalRequest>
 */
@property (nonatomic, strong, readonly) NSArray<AUTApprovalRequest *> *pending;

/**
 Array of approved requests of type <AUTApprovalRequest>
 */
@property (nonatomic, strong, readonly) NSArray<AUTApprovalRequest *> *approved;

/**
 Array of denied requests of type <AUTApprovalRequest>
 */
@property (nonatomic, strong, readonly) NSArray<AUTApprovalRequest *> *denied;

/**
 Array of expired requests of type <AUTApprovalRequest>
 */
@property (nonatomic, strong, readonly) NSArray<AUTApprovalRequest *> *expired;

@end
