# Uncomment this line to define a global platform for your project
# platform :ios, "6.0"

use_frameworks!

def jasonette_pods
    pod 'UICKeyChainStore'
    pod 'TWMessageBarManager'
    pod 'SWTableViewCell', :git => "https://github.com/gliechtenstein/SWTableViewCell.git"
    pod 'TTTAttributedLabel'
    pod 'BBBadgeBarButtonItem'
    pod 'IQAudioRecorderController', :git => 'https://github.com/hackiftekhar/IQAudioRecorderController.git'
    pod 'REMenu'
    pod 'JDStatusBarNotification'
    pod "SWFrameButton"
    pod 'libPhoneNumber-iOS'
    pod "NSGIF", "~> 1.0"
    pod 'INTULocationManager'
    pod "AHKActionSheet"
    pod 'TDOAuth'
    pod "AFOAuth2Manager"
    pod "CYRTextView"
    pod 'FreeStreamer', :git => "https://github.com/muhku/FreeStreamer.git"
    pod 'SDWebImage', :git => "https://github.com/rs/SDWebImage.git"
    pod 'SZTextView'
    pod 'SBJson', '~> 4.0.4'
    pod 'DHSmartScreenshot'
    pod 'NSHash'
    pod 'JSCoreBom', '~> 1.1.1'
    pod "RMDateSelectionViewController"
    pod 'DTCoreText'
    pod 'PBJVision'
    pod 'PHFComposeBarView'
    pod 'DAKeyboardControl'
    pod 'SVPullToRefresh', :git => 'https://github.com/samvermette/SVPullToRefresh.git', :branch => 'master'
end

def common_pods
    # Tweaks is installed manually, the use_frameworks! makes the Tweaks options not showing.
    
    pod 'RestKit',  '~> 0.27.0'
    pod 'NJKWebViewProgress'
    pod 'TTTAttributedLabel'
    pod 'GoogleAppIndexing'
    pod 'GoogleTagManager'
    pod 'GoogleMaps'
    pod 'AppsFlyerFramework'
    pod 'BlocksKit', '~> 2.2.5'
    pod 'UITableView+FDTemplateLayoutCell', '~> 1.4'
    pod 'FLEX', '~> 2.0', :configurations => ['Debug']
    pod 'ComponentKit', '~> 0.14'
    pod 'EAIntroView', '~> 2.8.0'
    pod 'JLPermissions/Notification'
    pod "JLPermissions/Contacts"
    pod 'GoogleSignIn', '~> 2.4.0'
    pod 'SPTPersistentCache', :git => 'https://github.com/spotify/SPTPersistentCache.git', :branch => 'master'
    pod 'FBSDKCoreKit', '~>4.19.0'
    pod 'FBSDKLoginKit', '~>4.19.0'
    pod 'DownPicker'
    pod 'APAddressBook/Swift'
    pod 'Masonry'
    pod 'TPKeyboardAvoiding'
    pod 'OAStackView', '~> 1.0.1'
    pod 'Appsee'
    pod 'JSQMessagesViewController'
    pod 'MXSegmentedPager', '~> 3.2.0'    
    pod 'MMNumberKeyboard'
    pod 'Localytics'
    pod 'JLRoutes', '~> 1.6.2'
    pod 'youtube-ios-player-helper', '~> 0.1.6'
    pod 'HMSegmentedControl', :git => 'https://github.com/billionssg/HMSegmentedControl'
    pod 'BEMCheckBox' , '~>1.2.0'
    pod 'VMaskTextField'
    pod 'FBSDKShareKit', '~>4.19.0'
#    pod 'AHKActionSheet', '~>0.5.4'
    pod 'NSAttributedString-DDHTML', '1.2.0'
    pod 'UIAlertController+Blocks', '~> 0.9'
    pod 'RichEditorView', :git => 'https://github.com/cjwirth/RichEditorView.git', :commit => '2cc2633d2e711b3af45912b2718b4df1c360b8f5'

    #Swift 3.0 pods
    pod 'RSKGrowingTextView'
    pod 'RSKPlaceholderTextView'
    pod 'SwiftOverlays' 
    pod 'Eureka' , '~>2.0.0-beta.1'
    pod 'RxSwift', '~> 3.3.1'
    pod 'RxCocoa', '~> 3.3.1'
    pod 'NSObject+Rx', '~>2.0.0'
    pod 'DKImagePickerController', '~> 3.5.0'
    pod 'RestKit/Testing', '~> 0.27.0'
    pod 'SnapKit', '~> 3.2.0'
    pod 'KeychainAccess', '~> 3.0'
    pod 'MoEngage-iOS-SDK', '~> 3.3.0'
    
    # This is used only to support UIImageView+AFNetworking.
    # If we can replace this with SDWebImage for example, this library won't be needed anymore.
    pod 'AFNetworking', '~> 3.1.0'
end

target "Tokopedia" do
    common_pods
    jasonette_pods
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target "TokopediaTests" do
    common_pods
    jasonette_pods
end

target "ServiceExtension" do
    pod 'MORichNotification', '~> 1.1.1'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end   
        
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            if target.name == "MoEngage-iOS-SDK"
                config.build_settings["OTHER_LDFLAGS"] = '$(inherited) "-ObjC"'
            end
        end
    end

    # prevent automatic c++ headers inclusion in Objective-C files which causes compile errors
    clear_component_kit_umbrella_header
end

def clear_component_kit_umbrella_header
    file = File.open('./Pods/Target Support Files/ComponentKit/ComponentKit-umbrella.h', 'w')
    file.close
end
