xcodebuild -alltargets clean


rm -rf "./JenkinsBuild/*"


xcodebuild -workspace Tokopedia.xcworkspace -configuration Release -scheme Tokopedia PROVISIONING_PROFILE="c177d300-9039-4d88-9dfe-5ae0433db037" CONFIGURATION_BUILD_DIR=JenkinsBuild

rm -rf "./JenkinsArchive/*"

xcodebuild -workspace Tokopedia.xcworkspace -configuration Release -scheme Tokopedia archive PROVISIONING_PROFILE="c177d300-9039-4d88-9dfe-5ae0433db037" CODE_SIGN_IDENTITY="iPhone Distribution: Tokopedia App (YQP4A2M94J)" -archivePath ./JenkinsArchive/Tokopedia.xcarchive -destination generic/platform=iOS

rm -rf "./JenkinsIPAExport/*"

mkdir "./JenkinsIPAExport"

xcodebuild -exportArchive -exportFormat IPA -exportProvisioningProfile Ad\ Hoc\ Distribution -archivePath ./JenkinsArchive/Tokopedia.xcarchive -exportPath ./JenkinsIPAExport/Tokopedia.ipa


#Write Release Notes to Crashlytics
echo "$(git log --pretty="%h - %s" --since=5.days --no-merges)" > ReleaseNotes.txt

./Crashlytics.framework/submit "d02324f74e70ffcd2dc00ab722d32baecf1884b4" "86d3efd816cabb133f016f397c41c066a22980ee54ed0805f7f73897d4cfc61e" -emails tonito@tokopedia.com -notesPath  ReleaseNotes.txt -groupAliases ﻿qa -ipaPath ./JenkinsIPAExport/Tokopedia.ipa