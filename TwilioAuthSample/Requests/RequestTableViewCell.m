//
//  RequestTableViewCell.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/26/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "RequestTableViewCell.h"
#import "UIColor+Extensions.h"

@interface RequestTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *expireTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dynamicExpireTextConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dynamicTimeAgoConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dynamicMessageToExpireConstraint;

@end

@implementation RequestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureUI];
}

- (void)configureUI {

    [self configureMessageLabel];
    [self configureExpireTimeLabel];
    [self configureTimeAgoLabel];

}

- (void)configureMessageLabel {

    self.message.numberOfLines = 0;
    [self.message setLineBreakMode:NSLineBreakByWordWrapping];
    [self.message setFont:[UIFont systemFontOfSize:15]];
    [self.message setTextColor:[UIColor colorWithHexString:@"#000000"]];
    [self.message sizeToFit];
}

- (void)configureExpireTimeLabel {

    [self.expireTime setUserInteractionEnabled:NO];
    [self.expireTime setTextAlignment:NSTextAlignmentLeft];
    self.expireTime.numberOfLines = 1;
    [self.expireTime setFont:[UIFont systemFontOfSize:14]];
    [self.expireTime setTextColor:[UIColor colorWithHexString:@"#a2a2a2"]];
    [self.expireTime sizeToFit];

    [self.expireTime setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.expireTime setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

}

- (void)configureTimeAgoLabel {

    [self.timeAgoLabel setTextAlignment:NSTextAlignmentRight];
    self.timeAgoLabel.numberOfLines = 0;
    [self.timeAgoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.timeAgoLabel setTextColor:[UIColor colorWithHexString:@"#a2a2a2"]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setMessageText:(NSString *)messageText {
    self.message.text = messageText;
}

- (void)setExpireTimeText:(NSString *)expireTimeText {
    self.expireTime.text = expireTimeText;

    if ([expireTimeText isEqualToString:@""]) {

        [self.expireTime setHidden:YES];
        [self.dynamicExpireTextConstraint setPriority:999];
        [self.dynamicMessageToExpireConstraint setConstant:0];

    } else {

        [self.expireTime setHidden:NO];
        [self.dynamicExpireTextConstraint setPriority:250];
        [self.dynamicMessageToExpireConstraint setConstant:8];
    }
}

- (void)setTimeAgoText:(NSString *)timeAgoText {
    self.timeAgoLabel.text = timeAgoText;
    [self setupTimeAgoWidthConstraint];
}

- (void)setupTimeAgoWidthConstraint {

    if (self.dynamicTimeAgoConstraint == nil) {
        NSLog(@"***** Autolayout: something went wrong with timeAgo width constraint at AORequestTableVieCell");
        return;
    }

    CGSize size = [self.timeAgoLabel sizeThatFits:CGSizeMake(CGRectGetWidth([self.contentView bounds]), CGFLOAT_MAX)];

    CGFloat width = size.width;

    if (width < 50) {
        [self.dynamicTimeAgoConstraint setConstant:50];
        return;
    }

    [self.dynamicTimeAgoConstraint setConstant:width];

}

@end
