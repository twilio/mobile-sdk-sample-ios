//
//  AUTTwilioError.h
//
//  Created by Juan Pablo Montenegro on 3/26/15.
//  Copyright 2011-2017 Twilio, Inc.
//
//  All rights reserved. Use of this software is subject to the terms and conditions of the
//  Twilio Terms of Service located at http://www.twilio.com/legal/tos
//

#import <Foundation/Foundation.h>

/** These constants indicate the type of the current AUTTwilioError that resulted in an operation's failure.
 ## Version information

 __Version__: 1.0.0
 */

extern NSString *TwilioAuthErrorDomain;

typedef NS_ENUM(NSInteger, AUTTwilioError) {

    /** Indicates that there was an error with the public/private key pair
     */
    AUTKeyPairError = -1,

    /** Indicates the arguments are not in the correct format or are missing
     */
    AUTInvalidArgumentError = -2,

    /** Indicates there was an error with the device
     */
    AUTDeviceNotValidError = -3,

    /** Indicates the device was deleted
     */
    AUTDeviceDeletedError = -4,

    /** Indicates there was an error with the request
     */
    AUTRequestError = -5,

    /** Indicates there was an error with the approval request
     */
    AUTApprovalRequestError = -6,

    /** Indicates there was an error storing information
     */
    AUTStorageError = -7,

    /** Indicates there was a cryptographic error
     */
    AUTCryptoError = -8,

    /** Indicates there was an unknown error
     */
    AUTUnknownError = -9
    
};
