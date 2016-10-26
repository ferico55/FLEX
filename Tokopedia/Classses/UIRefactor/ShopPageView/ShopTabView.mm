//
//  ShopTabView.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopTabView.h"

#import <ComponentKit/ComponentKit.h>

#import <vector>

@interface ShopTabComponentModel : NSObject
@property ShopPageTab tab;
@property BOOL showHomeTab;
@end

@implementation ShopTabComponentModel
@end

@interface ShopTabView() <CKComponentProvider>
@end

@implementation ShopTabView {
    ShopTabComponentModel *_model;
}

- (instancetype)initWithTab:(ShopPageTab)tab {
    id<CKComponentSizeRangeProviding> sizeRangeProvider =
        [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibilityNone];
    if (self = [super initWithComponentProvider:[self class]
                              sizeRangeProvider:sizeRangeProvider]) {
        
        _model = [ShopTabComponentModel new];
        _model.tab = tab;
        _model.showHomeTab = NO;
        
        [self updateModel:_model mode:CKUpdateModeSynchronous];
    }
    
    return self;
}

- (void)setShowHomeTab:(BOOL)showHomeTab {
    _showHomeTab = showHomeTab;
    _model.showHomeTab = showHomeTab;
    
    [self updateModel:_model mode:CKUpdateModeSynchronous];
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
    UIColor *highlightColor = model.tab == tab? [UIColor colorWithRed:0.071 green:0.780 blue:0.000 alpha:1.00]: [UIColor clearColor];
    
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
                    [CKComponent
                     newWithView:{
                         [UIView class],
                         {{@selector(setBackgroundColor:), highlightColor}}
                     }
                     size:{.height = 3}]
                }
            }];
}

+ (CKComponent *)componentForModel:(ShopTabComponentModel *)model
                           context:(id<NSObject>)context {
    std::vector<CKComponent *> tabItems = {
        (model.showHomeTab?[self tabWithTitle:@"Home" forSection:ShopPageTabHome withModel:model]:nil),
        [self tabWithTitle:@"Produk" forSection:ShopPageTabProduct withModel:model],
        [self tabWithTitle:@"Diskusi" forSection:ShopPageTabDiscussion withModel:model],
        [self tabWithTitle:@"Ulasan" forSection:ShopPageTabReview withModel:model],
        [self tabWithTitle:@"Catatan" forSection:ShopPageTabNote withModel:model]
    };
    
    tabItems = CK::filter(tabItems, [](CKComponent *component) {
        return component != nil;
    });
    
    std::vector<CKStackLayoutComponentChild> stackLayoutChildren;
    
    CKRelativeDimension flexBasis = CKRelativeDimension::Percent(1.0 / tabItems.size());
    
    for (int index = 0; index < tabItems.size(); index++) {
        stackLayoutChildren.push_back({
            tabItems[index],
            .flexShrink = YES,
            .flexBasis = flexBasis
        });
        
        if (index != tabItems.size() - 1) {
            stackLayoutChildren.push_back({[self verticalSeparator]});
        }
    }
    
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
            children:stackLayoutChildren];
}

@end
