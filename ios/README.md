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

# Code Review
We use SwiftLint to enforce consistent coding style, and you'll get errors when your code does not conform to the rules.

Some rules are automatically fixable by running this command in your terminal:
```bash
ios/Pods/SwiftLint/swiftlint autocorrect --path /path/to/filename
```

If have any suggestions about the rules, you can contact `@samuel.edwin` or `@renny.runiawati` on Slack.

#API Docs 
https://wiki.tokopedia.net/Tokopedia_Web_Service_v4_Documentation


