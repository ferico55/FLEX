xcodebuild -alltargets clean


rm -rf "./JenkinsBuild"


xcodebuild -workspace Tokopedia.xcworkspace -configuration Debug -scheme Tokopedia PROVISIONING_PROFILE="79601cb1-2eee-4406-8573-8a0a96071f6d" CONFIGURATION_BUILD_DIR=JenkinsBuild

rm -rf "./JenkinsArchive"

xcodebuild -workspace Tokopedia.xcworkspace -configuration Debug -scheme Tokopedia archive PROVISIONING_PROFILE="79601cb1-2eee-4406-8573-8a0a96071f6d" CODE_SIGN_IDENTITY="iPhone Developer: Melissa Juminto (TT6A3N9KTC)" -archivePath ./JenkinsArchive/Tokopedia.xcarchive -destination generic/platform=iOS

rm -rf "./JenkinsIPAExport"

mkdir "./JenkinsIPAExport"

xcodebuild -exportArchive -exportFormat IPA -exportProvisioningProfile AdHoc\ Distribution\ New -archivePath ./JenkinsArchive/Tokopedia.xcarchive -exportPath ./JenkinsIPAExport/Tokopedia.ipa


#Write Release Notes to Crashlytics
echo "$(git log --pretty="%h - %s" --since=5.days --no-merges)" > ReleaseNotes.txt

./Crashlytics.framework/submit "d02324f74e70ffcd2dc00ab722d32baecf1884b4" "86d3efd816cabb133f016f397c41c066a22980ee54ed0805f7f73897d4cfc61e" -emails tonito@tokopedia.com -notesPath  ReleaseNotes.txt -groupAliases ﻿qa -ipaPath ./JenkinsIPAExport/Tokopedia.ipa