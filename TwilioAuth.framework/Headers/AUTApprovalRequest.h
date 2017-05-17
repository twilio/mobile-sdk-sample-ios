//
//  AUTApprovalRequest.h
//  TwilioAuth
//
//  Created by Juan Montenegro on 4/17/14.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>
#import "AUTApprovalRequestLogo.h"

/** 
 These constants represent the status of an <AUTApprovalRequest>
 ## Version information
 
 __Version__: 1.0.0
 */
typedef NS_OPTIONS(NSUInteger, AUTApprovalRequestStatus) {
    
    /** This is used to represent the approve status
     */
    AUTApprovalRequestStatusApproved    = 1 << 0,
    
    /** This is used to represent the deny status
     */
    AUTApprovalRequestStatusDenied      = 1 << 1,
    
    /** This is used to represent the pending status
     */
    AUTApprovalRequestStatusPending     = 1 << 2,
    
    /** This is used to represent the expired status
     */
    AUTApprovalRequestStatusExpired     = 1 << 3
};


/**
 Represents an action that is pending a user's approval. It contains information about the request that will help the user decide if the request is to be approved or denied.
 ## Version information
 
 __Version__: 1.0.0
 */
@interface AUTApprovalRequest : NSObject

/**
 Array of all logos (of type <AUTApprovalRequestLogo>) associated to the approval request
 */
@property (nonatomic, strong, readonly) NSArray<AUTApprovalRequestLogo *> *logos;

/**
 * A message is an arbitrary string that gives additional information about the approval request.
 * It is intended to be displayed to the user so he can quickly identify the approval request i.e.
 * a message could be 'You requested to send USD20 to Bank Account #12908347'. If the user sees
 * this message he can quickly determine if the approval request is a valid one.
 *
 * Note that this field can be empty but it is guaranteed to be non-null.
 */
@property (nonatomic, strong, readonly) NSString *message;

/**
 A dictionary (keys and values of type NSString) containing additional information of the approval request.
 */
@property (nonatomic, strong, readonly) NSDictionary *details;

/**
 A dictionary (keys and values of type NSString) with private information of the approval request, meant not to be visible by the end user.
 */
@property (nonatomic, strong, readonly) NSDictionary *hiddenDetails;

/**
 A dictionary (keys and values of type NSString) with information of the requester.
 */
@property (nonatomic, strong, readonly) NSDictionary *requesterDetails;

/**
 A dictionary (keys and values of type NSString) with information of information of the device from which the approval request was issued.
 */
@property (nonatomic, strong) NSDictionary *deviceDetails;

/**
 The approval request unique identifier.
 */
@property (nonatomic, strong, readonly) NSString *uuid;

/**
 Timestamp of the creation date.
 */
@property (nonatomic, assign, readonly) long creationTimestamp;

/**
 Timestamp of the expiration date, if the request doesn't have an expiration time this value will be 0.
 */
@property (nonatomic, assign, readonly) long expirationTimestamp;

/**
 The approval request status of type <AUTApprovalRequestStatus>
 */
@property (nonatomic, assign) AUTApprovalRequestStatus status;

/**
 The device geolocation
 */
@property (nonatomic, strong) NSString *deviceGeoLocation;

/**
 Reason for denial
 */
@property (nonatomic, strong) NSString *denialReason;

@end
