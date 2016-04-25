//
//  EditShopDataSource.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopInfoResult.h"

@protocol EditShopDelegate <NSObject>

- (void)didTapShopPhoto;
- (void)didTapShopStatus;

@end

@interface EditShopDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ShopInfoResult *shop;
@property (weak, nonatomic) id<EditShopDelegate> delegate;

@end
