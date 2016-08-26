//
//  ResolutionCenterCreatePOSTRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreatePOSTProduct.h"

@interface ResolutionCenterCreatePOSTRequest : NSObject
@property (strong, nonatomic) NSString* category_trouble_id;
@property (strong, nonatomic) NSString* order_id;
@property (strong, nonatomic) NSMutableArray<ResolutionCenterCreatePOSTProduct*>* product_list;

+(RKObjectMapping*)mapping;
@end
