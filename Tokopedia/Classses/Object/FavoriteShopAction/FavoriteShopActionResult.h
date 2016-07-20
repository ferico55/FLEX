//
//  FavoriteShopResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface FavoriteShopActionResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *is_success;

+ (NSDictionary *)attributeMappingDictionary;
+ (RKObjectMapping *)mapping;

@end
