//
//  ResolutionCenterCreateResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateTroubleList.h"
#import "ResolutionCenterCreateData.h"
#import "ResolutionCenterCreatePOSTRequest.h"
@class EditResolutionForm;
@class ProductTrouble;

@interface ResolutionCenterCreateResult : NSObject

@property (strong, nonatomic) ResolutionCenterCreatePOSTRequest* postObject;

@property (strong, nonatomic) NSMutableArray<ProductTrouble*>* selectedProduct;
@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@property (strong, nonatomic) EditResolutionForm *formEdit;
@property (strong, nonatomic) NSString* remark;
@property (strong, nonatomic) NSString* troubleId;
@property (strong, nonatomic) NSString* trouble_name;

-(NSMutableArray*)generatePossibleTroubleTextListWithCategoryTroubleId:(NSString*)categoryTroubleId;
-(NSMutableArray*)generatePossibleTroubleListWithCategoryTroubleId:(NSString*)categoryTroubleId;
- (ResolutionCenterCreateTroubleList*)selectedTroubleById:(NSString*)troubleId categoryId:(NSString*)categoryId;
@end
