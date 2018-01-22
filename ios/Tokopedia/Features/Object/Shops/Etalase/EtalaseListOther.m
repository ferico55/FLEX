//
//  EtalaseListOther.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseListOther.h"

@implementation EtalaseListOther
+(RKObjectMapping *)mapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[EtalaseListOther class]];
    [mapping addAttributeMappingsFromArray:@[@"etalase_id", @"etalase_url", @"etalase_name", @"etalase_badge"]];
    return mapping;
}
@end
