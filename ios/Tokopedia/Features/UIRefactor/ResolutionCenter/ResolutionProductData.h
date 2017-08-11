//
//  ResolutionProductData.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductTrouble;

@interface ResolutionProductData : NSObject
@property (strong, nonatomic) NSArray<ProductTrouble*>* list;

+(RKObjectMapping*)mapping;
@end
