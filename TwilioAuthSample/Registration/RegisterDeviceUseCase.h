//
//  RegisterDeviceUseCase.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 2/20/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegistrationResponse.h"

@interface RegisterDeviceUseCase : NSObject

- (void)getRegistrationTokenForAuthyID:(NSString *)authyID andBackendURL:(NSString *)backendURL completion:(void(^) (RegistrationResponse *registrationResponse))completion;

@end
