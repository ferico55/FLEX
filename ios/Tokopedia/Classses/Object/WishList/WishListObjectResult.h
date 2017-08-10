//
//  WishListObjectResult.h
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
#import "WishListObjectList.h"

@interface WishListObjectResult : NSObject

@property (nonatomic, strong, nonnull) Paging *paging;
@property (nonatomic, strong, nonnull) NSArray *list;
@property (nonatomic, strong, nonnull) NSString *is_success;

@end
