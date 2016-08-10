//
//  ResolutionCenterCreateResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateResult.h"
#import <BlocksKit/BlocksKit.h>

@implementation ResolutionCenterCreateResult
-(instancetype)init{
    self = [super init];
    if(self){
        _selectedProduct = [NSMutableArray new];
    }
    return self;    
}

-(NSMutableArray*)generatePossibleTroubleTextListWithCategoryTroubleId:(NSString*)categoryTroubleId{
    NSMutableArray *result = [NSMutableArray new];
    [_formData.list_ts bk_each:^(id obj) {
        ResolutionCenterCreateList* currentList = (ResolutionCenterCreateList*)obj;
        if([currentList.category_trouble_id isEqualToString:categoryTroubleId]){
            [currentList.trouble_list bk_each:^(id obj) {
                ResolutionCenterCreateTroubleList* currentList = (ResolutionCenterCreateTroubleList*)obj;
                [result addObject:currentList.trouble_text];
            }];
        }
    }];
    return result;
}
@end
