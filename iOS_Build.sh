xcodebuild -alltargets clean


rm -rf "./JenkinsBuild/*"


xcodebuild -workspace Tokopedia.xcworkspace -scheme Tokopedia PROVISIONING_PROFILE="c177d300-9039-4d88-9dfe-5ae0433db037" CONFIGURATION_BUILD_DIR=JenkinsBuild

rm -rf "./JenkinsArchive/*"

xcodebuild -workspace Tokopedia.xcworkspace -scheme Tokopedia archive PROVISIONING_PROFILE="c177d300-9039-4d88-9dfe-5ae0433db037" CODE_SIGN_IDENTITY="iPhone Distribution: Tokopedia App (YQP4A2M94J)" -archivePath ./JenkinsArchive/Tokopedia.xcarchive -destination generic/platform=iOS

rm -rf "./JenkinsIPAExport/*"

mkdir "./JenkinsIPAExport"

xcodebuild -exportArchive -exportFormat IPA -exportProvisioningProfile Ad\ Hoc\ Distribution -archivePath ./JenkinsArchive/Tokopedia.xcarchive -exportPath ./JenkinsIPAExport/Tokopedia.ipa
