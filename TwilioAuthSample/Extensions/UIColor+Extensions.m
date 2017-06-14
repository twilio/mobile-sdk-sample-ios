//
//  UIColor+Extensions.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/26/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+(UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    if(!hexString){
        return [UIColor whiteColor];
    }
    if(hexString.length == 0 ){
        return [UIColor whiteColor];
    }

    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

@end
