//
//  ResolutionBy.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionBy : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger by_customer;
@property (nonatomic) NSInteger by_seller;
@property (nonatomic, strong) NSString *user_label;
@property (nonatomic, strong) NSString *user_label_id;

@end
