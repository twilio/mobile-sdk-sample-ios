//
//  TwilioAuthenticatorSampleUITests.m
//  TwilioAuthenticatorSampleUITests
//
//  Created by Adriana Pineda on 9/12/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import <XCTest/XCTest.h>

#define custom_backend_url_http @"CHANGE_ME"
#define custom_backend_url_https @"CHANGE_ME"
#define create_request_url @"CHANGE_ME"
#define api_key @"CHANGE_ME"

@interface TwilioAuthenticatorSampleUITests : XCTestCase

@property (nonatomic, strong) XCUIApplication *application;
@end

@implementation TwilioAuthenticatorSampleUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

    // Clear iOS Push Notifications alert
    XCUIElement *pushNotificationAlert = self.application.alerts[@"\"U201cTwilioAuthenticator Sample\"U201d Would Like to Send You Notifications"];
    if (pushNotificationAlert.exists) {
        [pushNotificationAlert.buttons[@"Allow"] tap];
    }

    // Logout if needed
    XCUIElement *requestsTab = self.application.tabBars.buttons[@"Requests"];
    if (requestsTab.exists) {
        [requestsTab tap];

        XCUIElement *deviceIdButton = self.application.navigationBars[@"Requests"].buttons[@"ID"];
        [deviceIdButton tap];

        XCUIElement *deviceIdAlert = self.application.alerts[@"Device ID"];
        XCUIElement *logoutButton = deviceIdAlert.buttons[@"Logout"];
        [logoutButton tap];

    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterWithNoAuthyIdAndNoBackendURL {

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Authy ID invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Make sure the value you entered is correct"];
    XCTAssertTrue(alertMessage.exists);

    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithNoAuthyId {

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    [backendUrlField typeText:@"https://invalid.com"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Authy ID invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Make sure the value you entered is correct"];
    XCTAssertTrue(alertMessage.exists);
    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithNoBackendURL {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Backend URL invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Make sure the value you entered is correct"];
    XCTAssertTrue(alertMessage.exists);

    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithInvalidBackendURL_1 {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    [backendUrlField typeText:@"https://invalid.com"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Device Registration Failed"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Request could not be made: An SSL error has occurred and a secure connection to the server cannot be made."];
    XCTAssertTrue(alertMessage.exists);

    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithInvalidBackendURL_2 {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    // HTTP not allowed
    [backendUrlField typeText:custom_backend_url_http];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Device Registration Failed"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Request could not be made: The resource could not be loaded because the App Transport Security policy requires the use of a secure connection."];
    XCTAssertTrue(alertMessage.exists);

    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)registerUser {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    [backendUrlField typeText:custom_backend_url_https];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    sleep(2);
}

- (void)testRegisterWithValidBackendURLAndLogout {

    [self registerUser];

    XCUIElement *deviceIdButton = self.application.navigationBars[@"Requests"].buttons[@"ID"];
    XCTAssertTrue(deviceIdButton.exists);
    [deviceIdButton tap];

    XCUIElement *deviceIdAlert = self.application.alerts[@"Device ID"];
    XCTAssertTrue(deviceIdAlert.exists);

    [deviceIdAlert.buttons[@"OK"] tap];

    XCUIElement *tokensTab = self.application.tabBars.buttons[@"Tokens"];
    XCTAssertTrue(tokensTab);

    [tokensTab tap];

    deviceIdButton = self.application.navigationBars[@"Tokens"].buttons[@"ID"];
    [deviceIdButton tap];

    XCUIElement *logoutButton = deviceIdAlert.buttons[@"Logout"];
    XCTAssertTrue(logoutButton.exists);
    [logoutButton tap];

    XCUIElement *localDataClearedAlert = self.application.alerts[@"Local Data Deleted"];
    XCTAssertTrue(localDataClearedAlert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Enter a new Authy ID and Backend URL"];
    XCTAssertTrue(alertMessage.exists);

    [localDataClearedAlert.buttons[@"OK"] tap];

    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    XCTAssertTrue(userAuthyIdField.exists);

    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    XCTAssertTrue(backendUrlField.exists);

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    XCTAssertTrue(registerButton.exists);

}

- (void)testApproveRequest {

    [self registerUser];

    NSString *urlAsString = [NSString stringWithFormat:@"%@?message=TESTING&api_key=%@&seconds_to_expire=10000&details[key1]=value&details[key2]=value", create_request_url, api_key];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task =[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error != nil) {
            XCTFail();
        }

    }];

    [task resume];

    sleep(2);

    // Refresh requests list
    XCUIElement *requestsBar = self.application.navigationBars[@"Requests"];
    XCUIElement *refreshButton = requestsBar.buttons[@"Refresh"];
    [refreshButton tap];

    // Select first cell of list
    [[self.application.cells elementBoundByIndex:0] tap];

    // Approve request
    [self.application.buttons[@"Approve"] tap];
    sleep(2);
    XCUIElement *alert = self.application.alerts[@"Approved"];
    XCTAssertTrue(alert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Request approved successfully"];
    XCTAssertTrue(alertMessage.exists);

    [alert.buttons[@"OK"] tap];

}

- (void)testApproveExpiredRequest {

    [self registerUser];

    NSString *urlAsString = [NSString stringWithFormat:@"%@?message=TESTING&api_key=%@&seconds_to_expire=10&details[key1]=value&details[key2]=value", create_request_url, api_key];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task =[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error != nil) {
            XCTFail();
        }

    }];

    [task resume];

    sleep(2);

    // Refresh requests list
    XCUIElement *requestsBar = self.application.navigationBars[@"Requests"];
    XCUIElement *refreshButton = requestsBar.buttons[@"Refresh"];
    [refreshButton tap];

    // Select first cell of list
    [[self.application.cells elementBoundByIndex:0] tap];

    // Deny request
    sleep(10);
    [self.application.buttons[@"Approve"] tap];
    sleep(2);
    XCUIElement *alert = self.application.alerts[@"Request cannot be approved"];
    XCTAssertTrue(alert.exists);
    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Approval request has expired"];
    XCTAssertTrue(alertMessage.exists);
    [alert.buttons[@"OK"] tap];
}

- (void)testDenyRequest {

    [self registerUser];

    NSString *urlAsString = [NSString stringWithFormat:@"%@?message=TESTING&api_key=%@&seconds_to_expire=10000&details[key1]=value&details[key2]=value", create_request_url, api_key];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task =[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error != nil) {
            XCTFail();
        }

    }];

    [task resume];

    sleep(2);

    // Refresh requests list
    XCUIElement *requestsBar = self.application.navigationBars[@"Requests"];
    XCUIElement *refreshButton = requestsBar.buttons[@"Refresh"];
    [refreshButton tap];

    // Select first cell of list
    [[self.application.cells elementBoundByIndex:0] tap];

    // Deny request
    [self.application.buttons[@"Deny"] tap];
    sleep(2);
    XCUIElement *alert = self.application.alerts[@"Denied"];
    XCTAssertTrue(alert.exists);

    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Request denied successfully"];
    XCTAssertTrue(alertMessage.exists);

    [alert.buttons[@"OK"] tap];

}

- (void)testDenyExpiredRequest {

    [self registerUser];

    NSString *urlAsString = [NSString stringWithFormat:@"%@?message=TESTING&api_key=%@&seconds_to_expire=10&details[key1]=value&details[key2]=value", create_request_url, api_key];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task =[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error != nil) {
            XCTFail();
        }

    }];

    [task resume];

    sleep(2);

    // Refresh requests list
    XCUIElement *requestsBar = self.application.navigationBars[@"Requests"];
    XCUIElement *refreshButton = requestsBar.buttons[@"Refresh"];
    [refreshButton tap];

    // Select first cell of list
    [[self.application.cells elementBoundByIndex:0] tap];

    // Deny request
    sleep(10);
    [self.application.buttons[@"Deny"] tap];
    sleep(2);
    XCUIElement *alert = self.application.alerts[@"Request cannot be denied"];
    XCTAssertTrue(alert.exists);
    XCUIElement *alertMessage = self.application.alerts.element.staticTexts[@"Approval request has expired"];
    XCTAssertTrue(alertMessage.exists);
    [alert.buttons[@"OK"] tap];
}


@end
