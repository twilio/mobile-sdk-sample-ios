//
//  TwilioAuthenticatorSampleUITests.m
//  TwilioAuthenticatorSampleUITests
//
//  Created by Adriana Pineda on 9/12/17.
//  Copyright © 2017 Authy. All rights reserved.
//

#import <XCTest/XCTest.h>

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

    XCUIElement *pushNotificationAlert = self.application.alerts[@"\"U201cTwilioAuthenticator Sample\"U201d Would Like to Send You Notifications"];
    if (pushNotificationAlert.exists) {
        [pushNotificationAlert.buttons[@"Allow"] tap];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterWithInvalidURL {

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
    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithInvalidAuthyId_1 {

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Authy ID invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);
    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithInvalidAuthyId_2 {

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    [backendUrlField typeText:@"https://invalid.com"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Authy ID invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);
    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithInvalidBackendURL {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    XCUIElement *deviceRegistrationFailedAlert = self.application.alerts[@"Backend URL invalid"];
    XCTAssertTrue(deviceRegistrationFailedAlert.exists);
    [deviceRegistrationFailedAlert.buttons[@"OK"] tap];

}

- (void)testRegisterWithValidURL {

    // Enter Authy ID
    XCUIElement *userAuthyIdField = self.application.textFields[@"12345678"];
    [userAuthyIdField tap];
    [userAuthyIdField typeText:@"74553"];

    // Enter Invalid URL
    XCUIElement *backendUrlField = self.application.textFields[@"https required"];
    [backendUrlField tap];
    [backendUrlField typeText:@"https://a8c54ae8.ngrok.io"];

    XCUIElement *registerButton = self.application.buttons[@"Register Device"];
    [registerButton tap];

    sleep(2);
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
    XCTAssertTrue(logoutButton);
    [logoutButton tap];

    XCUIElement *localDataClearedAlert = self.application.alerts[@"Local Data Deleted"];
    XCTAssertTrue(localDataClearedAlert);
    [localDataClearedAlert.buttons[@"OK"] tap];

    XCTAssertTrue(userAuthyIdField.exists);
    XCTAssertTrue(backendUrlField.exists);
    XCTAssertTrue(registerButton.exists);

}

@end
