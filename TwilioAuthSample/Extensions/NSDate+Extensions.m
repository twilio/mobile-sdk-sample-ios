//
//  NSDate+Extensions.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/28/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

- (NSString *)expirationTimeAsString {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy 'at' hh:mm a"];

    NSString *dateFormat = [formatter stringFromDate:self];
    NSTimeInterval difference = [self timeIntervalSinceDate:[NSDate date]];

    if (difference < 0) {
        return [NSString stringWithFormat:@"Expired on %@", dateFormat];
    } else {
        return [NSString stringWithFormat:@"Expires on %@", dateFormat];
    }
}

- (NSString *)timeAgoAsString {

    NSTimeInterval differenceInSeconds = [self timeIntervalSinceDate:[NSDate date]];

    int seconds = abs((int)differenceInSeconds);
    int minutes = abs(seconds/60);
    int hours = abs(minutes/60);
    int days = abs(hours/24);
    int weeks = abs(days/7);

    if (seconds < 60) {
        return [NSString stringWithFormat:@"%ld sec", (long)seconds];
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld min", (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld hr", (long)hours];
    } else if (days < 7) {
        return [NSString stringWithFormat:@"%ld day", (long)days];
    } else {
        return [NSString stringWithFormat:@"%ld wk", (long)weeks];
    }
}

@end
