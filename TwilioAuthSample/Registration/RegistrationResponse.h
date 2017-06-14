//
//  RegistrationResponse.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 2/20/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegistrationResponse : NSObject

@property (nonatomic, strong) NSString *registrationToken;
@property (nonatomic, strong) NSString *messageError;

@end
