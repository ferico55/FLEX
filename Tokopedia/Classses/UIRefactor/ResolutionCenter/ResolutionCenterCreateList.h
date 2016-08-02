//
//  ResolutionCenterCreateList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateTroubleList.h"

@interface ResolutionCenterCreateList : NSObject
@property (strong, nonatomic) NSString* category_trouble_id;
@property (strong, nonatomic) NSString* category_trouble_text;
@property (strong, nonatomic) ResolutionCenterCreateTroubleList* trouble_list;

+(RKObjectMapping*)mapping;
@end
