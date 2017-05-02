//
//  PromoCategory.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromoCategory : NSObject
@property (strong, nonatomic) NSString *category_id;

+(RKObjectMapping*)mapping;
@end
