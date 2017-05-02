//
//  ShopHeaderView.h
//  Tokopedia
//
//  Created by Samuel Edwin on 12/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/CKComponentHostingView.h>

@class DetailShopResult;

@interface ShopHeaderViewModel : NSObject

@property (nonatomic) DetailShopResult *shop;
@property (nonatomic) BOOL ownShop;
@property (nonatomic) BOOL favoriteRequestInProgress;

@end

@interface ShopHeaderView : CKComponentHostingView

@property (nonatomic) ShopHeaderViewModel *viewModel;
@property (nonatomic, copy) void (^onTapMessageButton)();
@property (nonatomic, copy) void (^onTapSettingsButton)();
@property (nonatomic, copy) void (^onTapAddProductButton)();
@property (nonatomic, copy) void (^onTapFavoriteButton)();

- (instancetype)initWithShop:(DetailShopResult *)shop;

@end
