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

@interface ResolutionCenterCreateResult : NSObject
@property (strong, nonatomic) NSMutableArray<ResolutionProductList*>* selectedProduct;
@end
