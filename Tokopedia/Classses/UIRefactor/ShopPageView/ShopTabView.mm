//
//  ShopTabView.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopTabView.h"

#import <ComponentKit/ComponentKit.h>

@interface ShopTabView() <CKComponentProvider>
@end

@implementation ShopTabView

- (instancetype)init {
    id<CKComponentSizeRangeProviding> sizeRangeProvider =
        [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibilityNone];
    if (self = [super initWithComponentProvider:[self class]
                              sizeRangeProvider:sizeRangeProvider]) {
        
    }
    
    return self;
}

+ (CKComponent *)componentForModel:(id<NSObject>)model
                           context:(id<NSObject>)context {
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = @"Test"
            }
            viewAttributes:{}
            size:{}];
}

@end
