//
//  TwilioAuth.h
//  TwilioAuth
//
//  Created by Adriana Pineda on 11/4/16.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>
#import "AUTApprovalRequest.h"
#import "AUTTimeInterval.h"
#import "AUTApprovalRequests.h"
#import "AUTTwilioError.h"

/**
 Interface for the Authy api.
 This class provides methods needed to interact with the Authy API and to approve and deny requests.
 ## Version information

 __Version__: 1.0.0
 */

@interface TwilioAuth : NSObject

/**
 Provides a thread-safe singleton instance of TwilioAuth, this way several calls to this method will return the same instance.
 Setups the TwilioAuth instance with production.
 @return TwilioAuth instance
 */
+ (id _Nonnull)sharedInstance;

/**
 * Asynchronously registers the device with the remote Authy server and associates it with the provided registrationToken.
 * @param registrationToken The registration token generated from the backend. It will be used as a proof that the device being registered is who claims to be.
 * @param pushToken         [Optional] This is the token used by APNS to send push notifications to the device.
 * @param completion        Callback when the Authy server responds the request. If the registration was successful, returns an empty NSError. If the registration wasn't successful, returns a non-empty NSError.
 */
- (void)registerDeviceWithRegistrationToken:(NSString * _Nonnull)registrationToken pushToken:(NSString * _Nullable)pushToken completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;

/**
 * Checks if the device is registered.
 * @return true if the device is registered, false if not.
 */
- (BOOL)isDeviceRegistered;

/**
 * Returns the current device id
 * @return the current device id
 */
- (NSString *_Nullable)getDeviceId;

/**
 * Sets the push token
 * @param pushToken        This is the token used by APNS to send push notifications to the device.
 * @param completion       Callback when the Authy server responds the request. If the push token was configured successfully, returns an empty NSError. If it wasn't, returns a non-empty NSError.
 */
- (void)setPushToken:(NSString * _Nonnull)pushToken completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;

/**
 Asynchronously gets the approval requests.
 @param statuses        Statuses to fetch
 @param timeInterval    [Optional] Time interval to fetch requests for, if null all approval requests are fetched.
 @param completion      Callback when the approval requests are received. If the call was successfull, returns an AUTApprovalRequests object containing the specified requests. If the call wasn't successful, returns a non-empty NSError.
 */
- (void)getApprovalRequestsWithStatuses:(AUTApprovalRequestStatus)statuses timeInterval:(AUTTimeInterval * _Nullable)timeInterval completion:(void (^ _Nonnull)(AUTApprovalRequests * _Nullable approvalRequests, NSError * _Nullable error))completion;

/**
 Asynchronously approves the provided request.
 @param approvalRequest The request to be approved.
 @param completion      Callback when the approval request is updated. Returns an empty error NSError if the opration was successful or a non-empty NSError if it wasn't.
 */
- (void)approveRequest:(AUTApprovalRequest * _Nonnull)approvalRequest completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;

/**
 Asynchronously denies the provided request.
 @param approvalRequest The request to be denied.
 @param completion      Callback when the approval request is updated. Returns an empty error NSError if the opration was successful or a non-empty NSError if it wasn't.
 */
- (void)denyRequest:(AUTApprovalRequest * _Nonnull)approvalRequest completion:(void (^ _Nonnull)(NSError * _Nullable error))completion;

#pragma mark - TOTP

/**
 Obtains the TOTP of the current app
 @returns the TOTP of the current app
 */
- (NSString * _Nullable)getTOTPWithError:(NSError  * _Nonnull * _Nonnull)error;

/**
 Asynchronously obtains the TOTP of the current app
 @param completion Callback when the TOTP is returned. Returns an empty error NSError if the opration was successful or a non-empty NSError if it wasn't.
 */
- (void)getSyncedTOTP:(void (^ _Nonnull)(NSString * _Nullable totp, NSError * _Nullable error))completion;

@end
