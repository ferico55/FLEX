//
//  ResolutionCenterCreateData.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateList.h"
#import "ResolutionCenterCreateForm.h"

@interface ResolutionCenterCreateData : NSObject

@property (strong, nonatomic) NSArray<ResolutionCenterCreateList*>* list_ts;
@property (strong, nonatomic) ResolutionCenterCreateForm* form;

+(RKObjectMapping*)mapping;
@end
