//
//  ResolutionCenterCreatePOSTData.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreatePOSTFormSolution.h"

@interface ResolutionCenterCreatePOSTData : NSObject
@property (strong, nonatomic) NSArray<ResolutionCenterCreatePOSTFormSolution*>* form_solution;

+(RKObjectMapping*)mapping;
@end
