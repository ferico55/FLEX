# Uncomment this line to define a global platform for your project
# platform :ios, "6.0"

use_frameworks!

def common_pods
    # Tweaks is installed manually, the use_frameworks! makes the Tweaks options not showing.
    
    pod 'RestKit',  '~> 0.27.0'
    pod 'NJKWebViewProgress'
    pod 'TTTAttributedLabel'
    pod 'GoogleAppIndexing'
    pod 'GoogleTagManager'
    pod 'GoogleMaps'
    pod 'Rollout.io', '~> 1.10.0'
    pod 'AppsFlyerFramework'
    pod 'BlocksKit', '~> 2.2.5'
    pod 'UITableView+FDTemplateLayoutCell', '~> 1.4'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'ComponentKit', '~> 0.14'
    pod 'EAIntroView', '~> 2.8.0'
    pod 'JLPermissions/Notification'
    pod "JLPermissions/Contacts"
    pod 'GoogleSignIn', '~> 2.4.0'
    pod 'SPTPersistentCache', '~> 1.0'
    pod 'FBSDKLoginKit'
    pod 'DownPicker'
    pod 'APAddressBook/Swift'
    pod 'Masonry'
    pod 'TPKeyboardAvoiding'
    pod 'OAStackView', '~> 1.0.1'
    pod 'Appsee'
    pod 'JSQMessagesViewController'
    pod 'MMNumberKeyboard'
    pod 'Localytics'
    pod 'JLRoutes', '~> 1.6.2'
    pod 'youtube-ios-player-helper', '~> 0.1.6'
    pod 'RxSwift', '~> 2.6.1'
    
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch =>'swift2.3'
    pod 'VMaskTextField'
    
    # This is used only to support UIImageView+AFNetworking.
    # If we can replace this with SDWebImage for example, this library won't be needed anymore.
    pod 'AFNetworking', '~> 3.1.0'
end

target "Tokopedia" do
    common_pods
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target "TokopediaTests" do
    common_pods
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end   
        
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end

    # prevent automatic c++ headers inclusion in Objective-C files which causes compile errors
    clear_component_kit_umbrella_header
end

def clear_component_kit_umbrella_header
    file = File.open('./Pods/Target Support Files/ComponentKit/ComponentKit-umbrella.h', 'w')
    file.close
end
