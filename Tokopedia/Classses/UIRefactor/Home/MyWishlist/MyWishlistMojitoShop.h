//
//  MyWhishlistMojitoShop.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWishlistMojitoShopReputation.h"

@interface MyWishlistMojitoShop : NSObject <TKPObjectMapping>
    @property (nonatomic, strong) NSString *id;
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *url;
    @property (nonatomic, strong) MyWishlistMojitoShopReputation *reputation;
    @property (nonatomic) BOOL gold_merchant;
    @property (nonatomic, strong) NSString *lucky_merchant;
    @property (nonatomic, strong) NSString *location;
    @property (nonatomic, strong) NSString *status;
@end
