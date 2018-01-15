# Tokopedia App for iOS

[![CircleCI](https://circleci.com/gh/tokopedia/ios-tokopedia/tree/release.svg?style=svg)](https://circleci.com/gh/tokopedia/ios-tokopedia/tree/release)

Welcome to Tokopedia!
https://itunes.apple.com/id/app/tokopedia/id1001394201?mt=8

This readme was made, hopefully to improve overall view even for new comers.

# Building the project
## Native devs/QA
Open `Tokopedia.xcworkspace` and build using Xcode

## React Native devs
Write JS codes in the [submodule repo](https://github.com/tokopedia/reactnative-apps)

#Third Party Library :
- Restkit + AFNetworking (https://github.com/RestKit/RestKit)
A framework for consuming and modelling web resource
- BlocksKit (https://github.com/zwaldowski/BlocksKit)
Utilites to make coding easier and straightforward
- Tweaks (https://github.com/facebook/Tweaks)
Adjust parameters and configuration with tweaks
- Rollout.io
Patch bugs, add new analytics, announce something, instantly! Without waiting for AppStore Review
- Reveal (http://revealapp.com/)
Inspect, modifying, debugging in runtime

Other Library :
- NJKWebViewProgress
- TTTAttributedLabel
- UITableView+FDTemplateLayoutCell
- FLEX
- ComponentKit
- EAIntroView
- JLPermissions/Notification
- GoogleAppIndexing
- GoogleTagManager
- GoogleMaps
- Google/SignIn
- FBSDKLoginKit
- AppsFlyer
- Localytics
- Google/Analytics

Important Tools to download :
- Xcode 7.3
- SourceTree
- Charles
- FileMerge


Inspiration : https://github.com/vsouza/awesome-ios

#Code Guideline 
What will be reviewed when you submit your code to be merged : 
- It’s not adviced to use secureStorage directly
- Initialization dictionary should be clean, it must not contain nil value
- If using method `objectAtIndex`, please be sure to check if array is not nil

#API Docs 
https://wiki.tokopedia.net/Tokopedia_Web_Service_v4_Documentation


