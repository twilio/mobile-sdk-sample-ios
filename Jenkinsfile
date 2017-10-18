prepare = 3
unitTests = 8
archivingArtifacts = 3
building = 8

master = 'master'

body = """FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'. Check console output at "${env.BUILD_URL}"""
subject = "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
emailList = env.APP_TEAM_EMAIL

properties([
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')),
  pipelineTriggers([
    upstream(
      threshold: 'SUCCESS',
      upstreamProjects: "TwilioAuth_iOS_SDK/${env.BRANCH_NAME}"
    )
  ])
])
node('appium_ventspils_node') {
  try{
    if (env.BRANCH_NAME == master || currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause)){
      stage 'Prepare'
        timeout(prepare) {
          checkout scm

          step([$class: 'CopyArtifact',
          fingerprintArtifacts: true,
          flatten: true,
          projectName: 'TwilioAuth_iOS_SDK/future-release',
          stable: true,
          target: './TwilioAuth'])

          sh 'security -v unlock-keychain -p "Andrejs 3rvins." "$HOME/Library/Keychains/login.keychain"'
          sh 'unzip TwilioAuth/TwilioAuthenticator.zip'
          sh 'cp -r build/Debug-universal/TwilioAuthenticator.framework ./'

          /*
          sh 'echo "" | calabash-ios setup'
          sh """
          ruby -r "~/Documents/Authy/calabash/iOS/Scripts/shared.rb" -e "recreateUserSchemes('TwilioAuthenticatorSample.xcodeproj')"
          """ */
      }
      stage 'UI tests'
        timeout(unitTests) {
          try{
            sh """
            cp -f ~/Documents/ios_sample_app_config/Constants.h ./TwilioAuthenticatorSampleUITests/Constants.h
            sh perl_script.sh
            xcodebuild -scheme "TwilioAuthenticatorSample-Debug" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.3' test
            """
          } catch (e) {
            currentBuild.result = "FAILED"
            throw e
          } finally {
          }
      }
      stage 'Archive and build IPA file'
        timeout(unitTests) {
          sh """
          xcodebuild -target TwilioAuthenticatorSample -scheme TwilioAuthenticatorSample-Debug -configuration Debug -derivedDataPath build CODE_SIGN_IDENTITY="iPhone Developer" clean build
          xcodebuild -scheme TwilioAuthenticatorSample-Debug archive -archivePath ./TwilioAuthenticatorSample.xcarchive
          sh xcodebuild-safe.h -exportArchive -archivePath ./TwilioAuthenticatorSample.xcarchive -exportPath ./TwilioAuthenticatorSample.ipa -exportOptionsPlist "exportPlist.plist"
          """
      }
    }
  } catch (e) {
    notifyFailed()
    currentBuild.result = "FAILED"
    throw e
  }
}

def notifyFailed() {
  if (env.BRANCH_NAME == master) {
    mail body: body, subject: subject, to: emailList
  }
}
