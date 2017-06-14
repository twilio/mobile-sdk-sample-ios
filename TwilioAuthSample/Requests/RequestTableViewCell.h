//
//  RequestTableViewCell.h
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/26/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestTableViewCell : UITableViewCell

- (void)setMessageText:(NSString *)messageText;
- (void)setExpireTimeText:(NSString *)expireTimeText;
- (void)setTimeAgoText:(NSString *)timeAgoText;

@end
