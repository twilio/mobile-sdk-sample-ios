//
//  NSDate+Extensions.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

- (NSString *)expirationTimeAsString;
- (NSString *)timeAgoAsString;

@end
