//
//  ListEtalase.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListEtalase : NSObject

@property (nonatomic) NSInteger etalase_id;
@property (nonatomic, strong) NSString *etalase_name;
@property (nonatomic, strong) NSString *etalase_total_product;

@end
