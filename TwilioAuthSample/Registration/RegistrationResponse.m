//
//  RegistrationResponse.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 2/20/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import "RegistrationResponse.h"

@implementation RegistrationResponse

- (id)init {

    self = [super init];

    if (self) {
        _messageError = @"Make sure the data is correct";
    }

    return self;
}

@end
