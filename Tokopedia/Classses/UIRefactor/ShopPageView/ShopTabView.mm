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

- (void)didSelectTab:(CKComponent *)component {
    ShopPageTab tab = (ShopPageTab)component.viewContext.view.tag;
    
    if (self.onTabSelected) {
        self.onTabSelected(tab);
    }
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

+ (CKComponent *)tabWithTitle:(NSString *)title forSection:(ShopPageTab)tab withModel:(ShopTabComponentModel *)model {
    return [CKStackLayoutComponent
            newWithView:{}
            size:{}
            style:{
                .direction = CKStackLayoutDirectionVertical,
                .alignItems = CKStackLayoutAlignItemsStretch
            }
            children:{
                {
                    [CKButtonComponent
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
                     action:CKComponentAction(@selector(didSelectTab:))
                     size:{}
                     attributes:{
                         //associate button with tab using tag
                         {@selector(setTag:), tab}
                     }
                     accessibilityConfiguration:{}],
                    .flexGrow = YES
                },
                {
                    (!(model.tab == tab)?nil:
                    [CKComponent
                     newWithView:{
                         [UIView class],
                         {{@selector(setBackgroundColor:), [UIColor colorWithRed:0.071 green:0.780 blue:0.000 alpha:1.00]}}
                     }
                     size:{.height = 3}])
                }
            }];
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
                    [self tabWithTitle:@"Home" forSection:ShopPageTabHome withModel:model],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Produk" forSection:ShopPageTabProduct withModel:model],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Diskusi" forSection:ShopPageTabDiscussion withModel:model],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Ulasan" forSection:ShopPageTabReview withModel:model],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
                {
                    [self verticalSeparator]
                },
                {
                    [self tabWithTitle:@"Catatan" forSection:ShopPageTabNote withModel:model],
                    .flexBasis = CKRelativeDimension::Percent(0.2),
                    .flexShrink = YES
                },
            }];
}

@end
