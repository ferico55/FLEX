//
//  ResolutionDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionLast.h"
#import "ResolutionOrder.h"
#import "ResolutionBy.h"
#import "ResolutionShop.h"
#import "ResolutionCustomer.h"
#import "ResolutionDispute.h"

@interface ResolutionDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) ResolutionLast *resolution_last;
@property (nonatomic, strong) ResolutionOrder *resolution_order;
@property (nonatomic, strong) ResolutionBy *resolution_by;
@property (nonatomic, strong) ResolutionShop *resolution_shop;
@property (nonatomic, strong) ResolutionCustomer *resolution_customer;
@property (nonatomic, strong) ResolutionDispute *resolution_dispute;

@end
