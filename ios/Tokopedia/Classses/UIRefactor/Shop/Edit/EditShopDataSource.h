//
//  EditShopDataSource.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopInfoResult.h"

#import "EditShopTypeViewCell.h"
#import "EditShopImageViewCell.h"
#import "EditShopDescriptionViewCell.h"

@protocol EditShopDelegate <NSObject>

- (void)didTapShopPhoto;
- (void)didTapShopStatus;
- (void)didTapMerchantInfo;

@end

@interface EditShopDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, EditShopTypeViewCellDelegate>

@property (strong, nonatomic) ShopInfoResult *shop;
@property (weak, nonatomic) id<EditShopDelegate> delegate;

@end
