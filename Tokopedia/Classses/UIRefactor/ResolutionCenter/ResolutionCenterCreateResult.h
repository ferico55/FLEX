//
//  ResolutionCenterCreateResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateTroubleList.h"
#import "ResolutionProductList.h"
#import "ResolutionCenterCreateData.h"
#import "ResolutionCenterCreatePOSTRequest.h"

@interface ResolutionCenterCreateResult : NSObject

@property (strong, nonatomic) ResolutionCenterCreatePOSTRequest* postObject;

@property (strong, nonatomic) NSMutableArray<ResolutionProductList*>* selectedProduct;
@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@property (strong, nonatomic) NSString* remark;
@property (strong, nonatomic) NSString* troubleId;

-(NSMutableArray*)generatePossibleTroubleTextListWithCategoryTroubleId:(NSString*)categoryTroubleId;
-(NSMutableArray*)generatePossibleTroubleListWithCategoryTroubleId:(NSString*)categoryTroubleId;
@end
