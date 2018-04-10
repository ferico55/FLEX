source 'https://rubygems.org'

gem "fastlane"
gem "danger"
gem "danger-swiftlint"
gem "cocoapods", "1.3.1"
gem "cocoapods-static-frameworks"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
