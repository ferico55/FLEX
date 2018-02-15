//
//  ChooseVariantManagerBridge.m
//  Tokopedia
//
//  Created by Digital Khrisna on 07/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VariantManager, NSObject)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXTERN_METHOD(chooseVariant:(nonnull NSNumber *)reactTag
                  productSelected:(NSDictionary *)productSelected)

RCT_EXTERN_METHOD(buyVariant:(nonnull NSNumber *)reactTag
                  productSelected:(NSDictionary *)productSelected)

@end

