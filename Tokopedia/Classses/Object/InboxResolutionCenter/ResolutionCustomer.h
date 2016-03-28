//
//  ResolutionCustomer.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReputationDetail.h"

#define CCustomerReputation @"customer_reputation"

@interface ResolutionCustomer : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *customer_image;
@property (nonatomic, strong) NSString *customer_name;
@property (nonatomic, strong) NSString *customer_url;
@property (nonatomic, strong) NSString *customer_id;
//@property (nonatomic, strong) ReputationDetail *customer_reputation;
@property (nonatomic, strong) ReputationDetail *customer_reputation;

@end
