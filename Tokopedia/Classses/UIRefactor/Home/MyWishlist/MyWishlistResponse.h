//
//  MyWishlistResponse.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"
#import "MyWishlistData.h"

@interface MyWishlistResponse : NSObject <TKPObjectMapping>
    @property (nonatomic, strong) NSArray<MyWishlistData *> *data;
    @property (nonatomic, strong) Paging *pagination;
@end
