//
//  ProductBadge.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductBadge : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *image_url;

+(RKObjectMapping*)mapping;
@end
