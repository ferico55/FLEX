//
//  ShopTabView.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopTabView.h"

#import <ComponentKit/ComponentKit.h>

@interface ShopTabComponentModel : NSObject
@property ShopPageTab tab;
@end

@implementation ShopTabComponentModel
@end

@interface ShopTabView() <CKComponentProvider>
@end

@implementation ShopTabView

- (instancetype)initWithTab:(ShopPageTab)tab {
    id<CKComponentSizeRangeProviding> sizeRangeProvider =
        [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibilityNone];
    if (self = [super initWithComponentProvider:[self class]
                              sizeRangeProvider:sizeRangeProvider]) {
        
        ShopTabComponentModel *model = [ShopTabComponentModel new];
        model.tab = tab;
        
        [self updateModel:model mode:CKUpdateModeSynchronous];
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

+ (CKComponent *)tabWithTitle:(NSString *)title marked:(BOOL)marked {
    CKComponent *tabItem = [CKButtonComponent
                            newWithTitles:{
                                {UIControlStateNormal, title}
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
                            accessibilityConfiguration:{}];
    
    if (!marked) return tabItem;
    
    return [CKOverlayLayoutComponent
            newWithComponent:tabItem
            overlay:
            [CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionVertical,
                 .justifyContent = CKStackLayoutJustifyContentEnd,
                 .alignItems = CKStackLayoutAlignItemsStretch
             }
             children:{
                 {
                     [CKComponent
                      newWithView:{
                          [UIView class],
                          {{@selector(setBackgroundColor:), [UIColor colorWithRed:0.071 green:0.780 blue:0.000 alpha:1.00]}}
                      }
                      size:{.height = 3}]
                 }
             }]];
}

+ (CKComponent *)componentForModel:(ShopTabComponentModel *)model
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
                    [self tabWithTitle:@"Home" marked:model.tab == ShopPageTabHome],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Produk" marked:model.tab == ShopPageTabProduct],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Diskusi" marked:model.tab == ShopPageTabDiscussion],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Ulasan" marked:model.tab == ShopPageTabReview],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Catatan" marked:model.tab == ShopPageTabNote],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
            }];
}

@end
