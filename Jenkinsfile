prepare = 8
uitests = 15
building = 15

master = 'master'
future_release = 'future-release'

body = """FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'. Check console output at "${env.BUILD_URL}"""
subject = "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
emailList = env.APP_TEAM_EMAIL

properties([
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '25')),
  pipelineTriggers([
    upstream(
      threshold: 'SUCCESS',
      upstreamProjects: "TwilioAuth_iOS_SDK/${env.BRANCH_NAME}"
    )
  ])
])
node('appium_ventspils_node') {
  try{
    if (env.BRANCH_NAME == master || env.BRANCH_NAME == future_release || currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) || currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)){
      stage 'Prepare'
        timeout(prepare) {
          checkout scm

          step([$class: 'CopyArtifact',
          fingerprintArtifacts: true,
          flatten: true,
          projectName: 'TwilioAuth_iOS_SDK/future-release',
          stable: true,
          target: './TwilioAuth'])

          withCredentials([[$class: 'StringBinding', credentialsId: 'Keychain_Password', variable: 'My_Key']]) {
              sh 'security -v unlock-keychain -p "${My_Key}" "$HOME/Library/Keychains/login.keychain"'
          }
          sh 'unzip TwilioAuth/TwilioAuthenticator.zip'
          sh 'cp -r build/Debug-universal/TwilioAuthenticator.framework ./'

          /* sh 'sh perl_script.sh'
          sh 'echo "" | calabash-ios setup'
          sh """
          ruby -r "~/Documents/Authy/calabash/iOS/Scripts/shared.rb" -e "recreateUserSchemes('TwilioAuthenticatorSample.xcodeproj')"
          """ */
      }
      stage 'UI tests'
        timeout(uitests) {
          try{
            sh """
            cp -f ~/Documents/ios_sample_app_config/Constants.h ./TwilioAuthenticatorSampleUITests/Constants.h
            sh perl_script.sh
            xcodebuild -scheme "TwilioAuthenticatorSample-Debug" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.1' test
            """
          } catch (e) {
            currentBuild.result = "FAILED"
            throw e
          } finally {
          }
      }
      stage 'Archive and build IPA file'
        timeout(building) {
          sh """
          xcodebuild -target TwilioAuthenticatorSample -scheme TwilioAuthenticatorSample-Debug -configuration Debug -derivedDataPath build CODE_SIGN_IDENTITY="iPhone Developer" clean build
          xcodebuild -scheme TwilioAuthenticatorSample-Debug archive -archivePath ./TwilioAuthenticatorSample.xcarchive
          sh xcodebuild-safe.sh -exportArchive -archivePath ./TwilioAuthenticatorSample.xcarchive -exportPath ./TwilioAuthenticatorSample.ipa -exportOptionsPlist "exportPlist.plist"
          """
      }
    }
    else {
        currentBuild.result = "NOT_BUILT"
    }
  } catch (e) {
    notifyFailed(env.APP_TEAM_EMAIL)
    currentBuild.result = "FAILED"
    throw e
  }
}

def notifyFailed(emailList) {
  if (env.BRANCH_NAME == master || env.BRANCH_NAME == future_release) {
    mail body: body, subject: subject, to: emailList
  }
}
