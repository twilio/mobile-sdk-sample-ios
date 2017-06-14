//
//  RegisterDeviceViewController.m
//  TwilioAuthSample
//
//  Created by Adriana Pineda on 11/24/16.
//  Copyright © 2016 Authy. All rights reserved.
//

#import "RegisterDeviceViewController.h"
#import "ApprovalRequestsViewController.h"
#import <TwilioAuth/TwilioAuth.h>
#import "RegistrationResponse.h"
#import "RegisterDeviceUseCase.h"

#import "UITextField+Extensions.h"

#define TextfieldOffSetWhenKeyBoardIsShown 5
#define ViewAnimationDurationWhenKeyBoardIsShown 0.25

@interface RegisterDeviceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *authyIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *backendURLTextField;

@property (weak, nonatomic) IBOutlet UIButton *registerDeviceButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *registerDeviceLoadingIndicator;

@property (nonatomic, strong) RegisterDeviceUseCase *registerDeviceUseCase;
@property (nonatomic, strong) TwilioAuth *sharedTwilioAuth;

@end

@implementation RegisterDeviceViewController

- (void)setStatusBarBackgroundColor:(UIColor *)color {

    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];

    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setStatusBarBackgroundColor:[UIColor colorWithRed:(247.0f/255.0f) green:(247.0f/255.0f) blue:(247.0f/255.0f) alpha:1]];

    self.registerDeviceUseCase = [[RegisterDeviceUseCase alloc] init];
    self.sharedTwilioAuth = [TwilioAuth sharedInstance];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];

    [self.navigationController setNavigationBarHidden:YES];

    [self.authyIDTextField configureBottomBorder];
    [self.backendURLTextField configureBottomBorder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyboard {
    [self.authyIDTextField resignFirstResponder];
    [self.backendURLTextField resignFirstResponder];
}

#pragma mark - Move view up when keyboard is shown
- (void)keyboardWillShow:(NSNotification *)notification {

    CGFloat offset = TextfieldOffSetWhenKeyBoardIsShown;
    CGFloat position = self.view.frame.origin.y;

    if ([self.authyIDTextField isEditing]) {

        CGFloat authyIDTextFieldYPosition = self.authyIDTextField.layer.frame.origin.y;
        CGFloat authyIDTextFieldHeight = self.authyIDTextField.layer.frame.size.height;
        position = authyIDTextFieldYPosition - authyIDTextFieldHeight*offset;

    } else if ([self.backendURLTextField isEditing]) {

        CGFloat backendURLTextFieldYPosition = self.backendURLTextField.layer.frame.origin.y;
        CGFloat backendURLTextFieldHeight = self.backendURLTextField.layer.frame.size.height;
        position = backendURLTextFieldYPosition - backendURLTextFieldHeight*offset;
    }

    [UIView animateWithDuration:ViewAnimationDurationWhenKeyBoardIsShown animations:^{

        CGRect newFrame = [self.view frame];
        newFrame.origin.y = -position;
        [self.view setFrame:newFrame];

    }];

}

-(void)keyboardWillHide:(NSNotification *)notification {

    [UIView animateWithDuration:ViewAnimationDurationWhenKeyBoardIsShown animations:^{

        __weak RegisterDeviceViewController *weakSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect newFrame = [weakSelf.view frame];
            newFrame.origin.x = 0;
            newFrame.origin.y = 0;
            [weakSelf.view setFrame:newFrame];
        });

    }];

}

#pragma mark - Register Device
- (void)configureUIElementsWhileRegistering {
    [self.registerDeviceButton setEnabled:NO];
    [self.registerDeviceLoadingIndicator setHidden:NO];
    [self.registerDeviceLoadingIndicator startAnimating];
    [self.authyIDTextField resignFirstResponder];
    [self.backendURLTextField resignFirstResponder];
}

- (void)configureUIElementsWhileNotRegistering {
    [self.registerDeviceButton setEnabled:YES];
    [self.registerDeviceLoadingIndicator setHidden:YES];
    [self.registerDeviceLoadingIndicator stopAnimating];
}

- (BOOL)areInputFieldsValid {

    NSString *authyId = self.authyIDTextField.text;
    NSString *backendURL = self.backendURLTextField.text;

    if ([authyId isEqualToString:@""] || [backendURL isEqualToString:@""]) {
        return NO;
    }

    return YES;
}

- (void)registerDeviceWithAuthyWithRegistrationToken:(NSString *)registrationToken andPushToken:(NSString *)pushToken {

    [self.sharedTwilioAuth registerDeviceWithRegistrationToken:registrationToken pushToken:pushToken completion:^(NSError *error) {

        if (error != nil) {

            __weak RegisterDeviceViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showErrorAlertWithTitle:@"Error registering the device" andMessage:error.localizedDescription];
            });

            return;
        }

        [self goToApprovalRequestsView];

    }];
}

- (NSString *)getCurrentPushToken {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [userDefaults objectForKey:@"PUSH_TOKEN"];
    return pushToken;

}

- (void)getRegistrationTokenForAuthyID:(NSString *)authyID backendURL:(NSString *)backendURL withCompletion:(void(^) (NSString *registrationToken))completion {

    [self.registerDeviceUseCase getRegistrationTokenForAuthyID:authyID andBackendURL:backendURL completion:^(RegistrationResponse *registrationResponse) {

        NSString *registrationToken = registrationResponse.registrationToken;
        if (registrationToken == nil || [registrationToken isEqualToString:@""]) {
            [self showErrorAlertWithTitle:@"Device Registration Failed" andMessage:registrationResponse.messageError];
            return;
        }

        completion(registrationToken);

    }];
}

- (IBAction)registerDevice:(id)sender {

    // Disable elements and animate loading indicator
    [self configureUIElementsWhileRegistering];

    // Validate fields

    NSString *authyId = self.authyIDTextField.text;
    if ([authyId isEqualToString:@""]) {
        [self showErrorAlertWithTitle:@"Authy ID invalid" andMessage:@"Make sure the value you entered is correct"];
        return;
    }

    NSString *backendURL = self.backendURLTextField.text;
    if ([backendURL isEqualToString:@""]) {
        [self showErrorAlertWithTitle:@"Backend URL invalid" andMessage:@"Make sure the value you entered is correct"];
        return;
    }

    // Obtain registration token
    [self getRegistrationTokenForAuthyID:authyId backendURL:backendURL withCompletion:^(NSString *registrationToken) {

        // Register device with Authy
        NSString *pushToken = [self getCurrentPushToken];
        [self registerDeviceWithAuthyWithRegistrationToken:registrationToken andPushToken:pushToken];

    }];
}

#pragma mark - Navigation
- (void)goToApprovalRequestsView {

    UITabBarController *tabBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tabBarViewController];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navigationController animated:YES completion:nil];
    });

}

#pragma mark - Alert
- (void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:^{

        __weak RegisterDeviceViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf configureUIElementsWhileNotRegistering];
        });

    }];

}

@end
