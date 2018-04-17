//
//  GroupChatTableView.m
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 23/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

//#import "GroupChatTableView.h"
// import RCTViewManager
#import <React/RCTViewManager.h>
// import RCTBridgeModule.h
#import <React/RCTBridgeModule.h>
#import <React/RCTComponent.h>

// Export a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-swift
@interface RCT_EXTERN_MODULE(GroupChatTableViewManager, RCTViewManager)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXTERN_METHOD(scrollToEnd:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(appendNewMessage:(nonnull NSNumber *)reactTag data:(NSDictionary *)data)
RCT_EXTERN_METHOD(loadMoreMessages:(nonnull NSNumber *)reactTag data:(NSArray *)data)
RCT_EXTERN_METHOD(mergeQueueMessages:(nonnull NSNumber *)reactTag data:(NSArray *)data scrolling:(BOOL)scrolling)

// Map native properties to React Component props
// https://facebook.github.io/react-native/docs/native-components-ios.html#properties
RCT_EXPORT_VIEW_PROPERTY(onScroll, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onScrollBegin, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPressRow, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPressItem, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(initialData, NSArray)

@end
