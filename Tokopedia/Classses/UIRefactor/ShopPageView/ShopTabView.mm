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

+ (CKComponent *)verticalSeparator {
    return [CKInsetComponent
            newWithInsets:UIEdgeInsetsMake(10, 0, 10, 0)
            component:
            [CKComponent
             newWithView:{
                 [UIView class],
                 {{@selector(setBackgroundColor:), [UIColor colorWithWhite:0.937 alpha:1.00]}}
             }
             size:{.width = 1}]];

}

+ (CKComponent *)componentForModel:(id<NSObject>)model
                           context:(id<NSObject>)context {
    return [CKStackLayoutComponent
            newWithView:{
                [UIView class],
                {{@selector(setBackgroundColor:), [UIColor whiteColor]}}
            }
            size:{}
            style:{
                .direction = CKStackLayoutDirectionHorizontal,
                .alignItems = CKStackLayoutAlignItemsStretch
            }
            children:{
                {
                    [CKButtonComponent
                     newWithTitles:{
                         {UIControlStateNormal, @"Home"}
                     }
                     titleColors:{
                         {UIControlStateNormal, [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.00]}
                     }
                     images:{}
                     backgroundImages:{}
                     titleFont:[UIFont largeTheme]
                     selected:{}
                     enabled:YES
                     action:{}
                     size:{}
                     attributes:{}
                     accessibilityConfiguration:{}],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [CKButtonComponent
                     newWithTitles:{
                         {UIControlStateNormal, @"Produk"}
                     }
                     titleColors:{
                         {UIControlStateNormal, [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.00]}
                     }
                     images:{}
                     backgroundImages:{}
                     titleFont:[UIFont largeTheme]
                     selected:{}
                     enabled:YES
                     action:{}
                     size:{}
                     attributes:{}
                     accessibilityConfiguration:{}],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [CKButtonComponent
                     newWithTitles:{
                         {UIControlStateNormal, @"Diskusi"}
                     }
                     titleColors:{
                         {UIControlStateNormal, [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.00]}
                     }
                     images:{}
                     backgroundImages:{}
                     titleFont:[UIFont largeTheme]
                     selected:{}
                     enabled:YES
                     action:{}
                     size:{}
                     attributes:{}
                     accessibilityConfiguration:{}],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [CKButtonComponent
                     newWithTitles:{
                         {UIControlStateNormal, @"Ulasan"}
                     }
                     titleColors:{
                         {UIControlStateNormal, [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.00]}
                     }
                     images:{}
                     backgroundImages:{}
                     titleFont:[UIFont largeTheme]
                     selected:{}
                     enabled:YES
                     action:{}
                     size:{}
                     attributes:{}
                     accessibilityConfiguration:{}],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [CKButtonComponent
                     newWithTitles:{
                         {UIControlStateNormal, @"Catatan"}
                     }
                     titleColors:{
                         {UIControlStateNormal, [UIColor colorWithRed:0.259 green:0.259 blue:0.259 alpha:1.00]}
                     }
                     images:{}
                     backgroundImages:{}
                     titleFont:[UIFont largeTheme]
                     selected:{}
                     enabled:YES
                     action:{}
                     size:{}
                     attributes:{}
                     accessibilityConfiguration:{}],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
            }];
}

@end
