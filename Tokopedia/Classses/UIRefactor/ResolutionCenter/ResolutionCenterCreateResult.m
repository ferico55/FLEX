//
//  ResolutionCenterCreateResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateResult.h"

@implementation ResolutionCenterCreateResult
-(instancetype)init{
    self = [super init];
    if(self){
        _selectedProduct = [NSMutableArray new];
    }
    return self;    
}
@end
