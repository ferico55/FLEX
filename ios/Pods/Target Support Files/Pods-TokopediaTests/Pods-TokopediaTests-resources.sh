#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/Apollo/scripts/check-and-run-apollo-codegen.sh"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/CFAlertViewController.xib"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/Cells/CFAlertActionTableViewCell.xib"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/Cells/CFAlertTitleSubtitleTableViewCell.xib"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperAssets.xcassets"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/en.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/es.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/it.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/ja.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/ko.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/pt-PT.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/zh-Hant.lproj"
  install_resource "${PODS_ROOT}/DKImagePickerController/DKImagePickerController/DKImagePickerController.bundle"
  install_resource "${PODS_ROOT}/DKImagePickerController/DKCamera/DKCameraResource.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/DownPicker/DownPicker.bundle"
  install_resource "${PODS_ROOT}/Eureka/Source/Resources/Eureka.bundle"
  install_resource "${PODS_ROOT}/FBSDKCoreKit/FacebookSDKStrings.bundle"
  install_resource "${PODS_ROOT}/GoogleAuthUtilities/Frameworks/frameworks/GoogleAuthUtilities.framework/Resources/GTMOAuth2ViewTouch.xib"
  install_resource "${PODS_ROOT}/GoogleMaps/Maps/Frameworks/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle"
  install_resource "${PODS_ROOT}/GooglePlaces/Frameworks/GooglePlaces.framework/Versions/A/Resources/GooglePlaces.bundle"
  install_resource "${PODS_ROOT}/GoogleSignIn/Resources/GoogleSignIn.bundle"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Assets/JSQMessagesAssets.bundle"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Controllers/JSQMessagesViewController.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellIncoming.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellOutgoing.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesLoadEarlierHeaderView.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesToolbarContentView.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesTypingIndicatorFooterView.xib"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey@2x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey@3x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey@2x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey@3x.png"
  install_resource "${PODS_ROOT}/MoEngage-iOS-SDK/MOInbox/MOInbox.storyboard"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/OAStackView/OAStackView.bundle"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Entypo.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/EvilIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/FontAwesome.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Foundation.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/MaterialCommunityIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/MaterialIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Octicons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/SimpleLineIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Zocial.ttf"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bg_color.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bg_color@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bold.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bold@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/clear.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/clear@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h1.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h1@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h2.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h2@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h3.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h3@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h4.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h4@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h5.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h5@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h6.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h6@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/indent.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/indent@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_image.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_image@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_link.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_link@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/italic.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/italic@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_center.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_center@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_left.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_left@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_right.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_right@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/ordered_list.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/ordered_list@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/outdent.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/outdent@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/redo.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/redo@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/strikethrough.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/strikethrough@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/subscript.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/subscript@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/superscript.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/superscript@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/text_color.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/text_color@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/underline.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/underline@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/undo.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/undo@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/unordered_list.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/unordered_list@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/assert.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/normalize.css"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor.html"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor_tests.html"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor_tests.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/style.css"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/VMaskTextField/VMaskTextField.bundle"
  install_resource "${PODS_ROOT}/youtube-ios-player-helper/youtube-ios-player-helper/Assets.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/Apollo/scripts/check-and-run-apollo-codegen.sh"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/CFAlertViewController.xib"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/Cells/CFAlertActionTableViewCell.xib"
  install_resource "${PODS_ROOT}/CFAlertViewController/CFAlertViewController/Cells/CFAlertTitleSubtitleTableViewCell.xib"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperAssets.xcassets"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/en.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/es.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/it.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/ja.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/ko.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/pt-PT.lproj"
  install_resource "${PODS_ROOT}/DBPrivacyHelper/DBPrivacyHelper/DBPrivacyHelperLocalizations/zh-Hant.lproj"
  install_resource "${PODS_ROOT}/DKImagePickerController/DKImagePickerController/DKImagePickerController.bundle"
  install_resource "${PODS_ROOT}/DKImagePickerController/DKCamera/DKCameraResource.bundle"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/DownPicker/DownPicker.bundle"
  install_resource "${PODS_ROOT}/Eureka/Source/Resources/Eureka.bundle"
  install_resource "${PODS_ROOT}/FBSDKCoreKit/FacebookSDKStrings.bundle"
  install_resource "${PODS_ROOT}/GoogleAuthUtilities/Frameworks/frameworks/GoogleAuthUtilities.framework/Resources/GTMOAuth2ViewTouch.xib"
  install_resource "${PODS_ROOT}/GoogleMaps/Maps/Frameworks/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle"
  install_resource "${PODS_ROOT}/GooglePlaces/Frameworks/GooglePlaces.framework/Versions/A/Resources/GooglePlaces.bundle"
  install_resource "${PODS_ROOT}/GoogleSignIn/Resources/GoogleSignIn.bundle"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Assets/JSQMessagesAssets.bundle"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Controllers/JSQMessagesViewController.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellIncoming.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellOutgoing.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesLoadEarlierHeaderView.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesToolbarContentView.xib"
  install_resource "${PODS_ROOT}/JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesTypingIndicatorFooterView.xib"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey@2x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDeleteKey@3x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey@2x.png"
  install_resource "${PODS_ROOT}/MMNumberKeyboard/Images/MMNumberKeyboardDismissKey@3x.png"
  install_resource "${PODS_ROOT}/MoEngage-iOS-SDK/MOInbox/MOInbox.storyboard"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/OAStackView/OAStackView.bundle"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Entypo.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/EvilIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/FontAwesome.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Foundation.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/MaterialCommunityIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/MaterialIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Octicons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/SimpleLineIcons.ttf"
  install_resource "${PODS_ROOT}/../../node_modules/react-native-vector-icons/Fonts/Zocial.ttf"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bg_color.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bg_color@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bold.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/bold@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/clear.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/clear@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h1.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h1@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h2.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h2@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h3.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h3@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h4.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h4@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h5.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h5@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h6.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/h6@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/indent.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/indent@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_image.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_image@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_link.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/insert_link@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/italic.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/italic@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_center.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_center@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_left.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_left@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_right.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/justify_right@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/ordered_list.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/ordered_list@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/outdent.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/outdent@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/redo.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/redo@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/strikethrough.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/strikethrough@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/subscript.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/subscript@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/superscript.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/superscript@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/text_color.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/text_color@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/underline.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/underline@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/undo.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/undo@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/unordered_list.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/icons/unordered_list@2x.png"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/assert.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/normalize.css"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor.html"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor_tests.html"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/rich_editor_tests.js"
  install_resource "${PODS_ROOT}/RichEditorView/RichEditorView/Assets/editor/style.css"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/VMaskTextField/VMaskTextField.bundle"
  install_resource "${PODS_ROOT}/youtube-ios-player-helper/youtube-ios-player-helper/Assets.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
