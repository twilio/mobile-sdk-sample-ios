//
//  AUTTimeInterval.h
//  TwilioAuth
//
//  Created by Adriana Pineda on 11/16/16.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>

/**
 This class represents a time interval
 ## Version information

 __Version__: 1.0.0
 */
@interface AUTTimeInterval : NSObject

/**
 Since timestamp of the time interval.
 */
@property (nonatomic) long sinceTimestamp;

/**
 Until timestamp of the time interval.
 */
@property (nonatomic) long untilTimestamp;

@end
