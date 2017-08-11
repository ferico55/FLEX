//
//  ResolutionCenterCreateTroubleList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateSolutionList.h"

@interface ResolutionCenterCreateTroubleList : NSObject
@property (strong, nonatomic) NSString* trouble_text;
@property (strong, nonatomic) NSString* trouble_id;

+(RKObjectMapping*)mapping;
@end
