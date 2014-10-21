//
//  FavoritedResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ListFavorited.h"

@interface FavoritedResult : NSObject

@property (nonatomic) NSInteger total_page;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSArray *list;

@end
