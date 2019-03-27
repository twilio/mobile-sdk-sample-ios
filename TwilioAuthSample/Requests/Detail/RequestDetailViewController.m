//
//  RequestDetailViewController.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/26/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "RequestDetailViewController.h"
#import "UIColor+Extensions.h"
#import "AUTApprovalRequest+Extensions.h"
#import "DeviceResetManager.h"
#import "Constants.h"

@interface RequestDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *requestLogo;
@property (weak, nonatomic) IBOutlet UILabel *requestMessage;
@property (weak, nonatomic) IBOutlet UILabel *requestDetails;
@property (weak, nonatomic) IBOutlet UIButton *approveButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *approveLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *denyLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *notPendingMessage;


@end

@implementation RequestDetailViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {

    [self setupNavigationBar];
    [self setupRequestMessage];
    [self setupRequestDetails];

    if (self.approvalRequest.status == AUTApprovalRequestStatusPending && ![self.approvalRequest isExpired]) {

        [self setupButtons];
        self.notPendingMessage.hidden = YES;

    } else {

        [self setupNoPendingMessage];
        self.approveButton.hidden = YES;
        self.denyButton.hidden = YES;
        self.notPendingMessage.hidden = NO;
    }

}

- (void)setupNavigationBar {

    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:defaultColor];

}

- (void)setupRequestMessage {

    if (self.approvalRequest == nil) {
        return;
    }

    self.requestMessage.text = self.approvalRequest.message;
}

- (void)setupRequestDetails {

    if (self.approvalRequest == nil) {
        return;
    }

    NSMutableString *details = [[NSMutableString alloc] init];

    for (NSString *detailKey in self.approvalRequest.details) {

        NSString *line = [NSString stringWithFormat:@"%@: %@\n", detailKey, self.approvalRequest.details[detailKey]];
        [details appendString:line];
    }

    self.requestDetails.text = details;
}

- (void)setupButtons {

    self.approveButton.hidden = NO;
    self.denyButton.hidden = NO;

    [self.approveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.denyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.approveButton setTitle:@"Approve" forState:UIControlStateNormal];
    [self.denyButton setTitle:@"Deny" forState:UIControlStateNormal];

    [self.approveButton setBackgroundColor:[UIColor colorWithHexString:@"#1b89cf"]];
    [self.denyButton setBackgroundColor:[UIColor colorWithHexString:@"#d73131"]];

    [self.approveButton.layer setCornerRadius:3.0];
    [self.denyButton.layer setCornerRadius:3.0];

}

- (void)setupNoPendingMessage {

    NSMutableString *firstLineMessage = [[NSMutableString alloc] init];

    if (self.approvalRequest.status == AUTApprovalRequestStatusApproved) {
        [firstLineMessage setString:@"Request approved"];
    } else if (self.approvalRequest.status == AUTApprovalRequestStatusDenied) {
        [firstLineMessage setString:@"Request denied"];
    } else if ([self.approvalRequest isExpired]) {
        [firstLineMessage setString:[self.approvalRequest expiredDateAsString]];
    }

    NSString *requestStatusMessageWithoutFormat = [NSString stringWithFormat:@"%@\nYou can no longer approve or deny", firstLineMessage];
    NSMutableAttributedString *requestStatusMessage = [[NSMutableAttributedString alloc] initWithString:requestStatusMessageWithoutFormat];
    [requestStatusMessage addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9a9a9a"] range:NSMakeRange(0, firstLineMessage.length)];

    self.notPendingMessage.attributedText = requestStatusMessage;
}

- (IBAction)approveRequest:(id)sender {

    if (self.approvalRequest == nil) {
        return;
    }

    self.approveLoadingIndicator.hidden = NO;
    [self.approveLoadingIndicator startAnimating];

    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];
    [sharedTwilioAuth approveRequest:self.approvalRequest completion:^(NSError *error) {

        if (error.code == AUTDeviceDeletedError) {

            [self configureRegistrationTokenViewAsRootController];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.approveLoadingIndicator stopAnimating];
        });

        if (error != nil) {
            [self showAlertWithTitle:@"Request cannot be approved" message:error.localizedDescription callbackBlock:^{
                [self setupUI];
            }];
            return;
        }

        [self showAlertWithTitle:@"Approved" message:@"Request approved successfully" callbackBlock:^{

            // Go back to previous screen
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];

    }];

}

- (IBAction)denyRequest:(id)sender {

    if (self.approvalRequest == nil) {
        return;
    }

    self.denyLoadingIndicator.hidden = NO;
    [self.denyLoadingIndicator startAnimating];

    TwilioAuth *sharedTwilioAuth = [TwilioAuth sharedInstance];
    [sharedTwilioAuth denyRequest:self.approvalRequest completion:^(NSError *error) {

        if (error.code == AUTDeviceDeletedError) {

            [self configureRegistrationTokenViewAsRootController];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.denyLoadingIndicator stopAnimating];
        });

        if (error != nil) {
            [self showAlertWithTitle:@"Request cannot be denied" message:error.localizedDescription callbackBlock:^{
                [self setupUI];
            }];
            return;
        }

        [self showAlertWithTitle:@"Denied" message:@"Request denied successfully" callbackBlock:^{

            // Go back to previous screen
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }];

}

- (void)configureRegistrationTokenViewAsRootController {

    [DeviceResetManager resetDeviceAndGetRegistrationViewForCurrentView:self withCustomTitle:nil];

}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message callbackBlock:(void (^)(void))callbackBlock {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        if (callbackBlock != nil) {
            callbackBlock();
        }

    }];
    if (@available(iOS 10, *)) {
        [action setValue:[UIColor colorWithHexString:defaultColor] forKey:@"titleTextColor"];
    }

    [alertController addAction:action];

    [self presentViewController:alertController animated:NO completion:nil];

}

@end
