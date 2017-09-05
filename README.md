# TwilioAuthenticator SDK - iOS Sample app

Welcome to the Twilio Authenticator iOS SDK Sample application. This application demonstrates how to use the mobile SDK inside an iOS app.

## How to Run

* **Step 1:** Clone the repository to your local machine

* **Step 2 (option 1 - CocoaPods):** Run `pod install` at your terminal, from inside the cloned repository's working directory. Then open the Xcode Workspace created by CocoaPods (`TwilioAuthenticatorSample.xcworkspace`).

* **Step 2 (option 2 - Carthage):** Run `carthage update` at your terminal, from inside the cloned repository's working directory. Navigate to your Xcode project's General settings page. Drag and drop the framework onto the Embedded Binaries section. Ensure that "Copy items if needed" is checked and press Finish. This will add the framework to both the Embedded Binaries and Linked Frameworks and Libraries sections.

* **Step 2 (option 3 - manual):** Open the Xcode project (`TwilioAuthenticatorSample.xcodeproj`) from the cloned repository's working directory. [Download](https://media.twiliocdn.com/sdk/ios/authenticator/releases/2.0.0/twilio-authenticator-ios-2.0.0.tar.bz2) the TwilioAuthenticator iOS framework. Navigate to your Xcode project's General settings page. Drag and drop the framework onto the Embedded Binaries section. Ensure that "Copy items if needed" is checked and press Finish. This will add the framework to both the Embedded Binaries and Linked Frameworks and Libraries sections.

* **Step 3:** [A backend application to handle the device registration](https://www.twilio.com/docs/quickstart/twilioauth-sdk-quickstart-tutorials/running-sample-app)

### Learn more
- Check out the full documentation at https://www.twilio.com/docs/quickstart/twilioauth-sdk-quickstart-tutorials
- Contact the Twilio support team at help@twilio.com
