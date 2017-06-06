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
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSString *is_success;
@end
