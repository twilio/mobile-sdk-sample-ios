//
//  AUTApprovalRequestLogo.h
//  TwilioAuth
//
//  Created by Adriana Pineda on 2/6/17.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>

/**
 Represents a logo of the approval request
 ## Version information

 __Version__: 1.0.0
 */

@interface AUTApprovalRequestLogo : NSObject

/**
 URL of the logo
 */
@property (nonatomic, strong, readonly, nonnull) NSString *url;

/**
 Resolution of the logo
 */
@property (nonatomic, strong, readonly, nonnull) NSString *resolution;


@end
