//
//  MyWhishlistMojitoShopReputation.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWishlistShopReputation : NSObject <TKPObjectMapping>

    @property (nonatomic) CGFloat score;
    @property (nonatomic, strong) NSString *set;
    @property (nonatomic) CGFloat level;
    @property (nonatomic, strong) NSString *image;

@end
