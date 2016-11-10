//
//  ShopTabView.h
//  Tokopedia
//
//  Created by Samuel Edwin on 10/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ComponentKit/CKComponentHostingView.h>
#import "ShopPageHeader.h"

@interface ShopTabView : CKComponentHostingView

@property(nonatomic, copy) void(^onTabSelected)(ShopPageTab);
@property(nonatomic) BOOL showHomeTab;

- (instancetype)initWithTab:(ShopPageTab)tab;

@end
