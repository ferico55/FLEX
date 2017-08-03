//
//  EtalaseList.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EtalaseList : NSObject

@property (nonatomic, strong) NSString *etalase_id;
@property (nonatomic, strong) NSString *etalase_num_product;
@property (nonatomic, strong) NSString *etalase_name;
@property (nonatomic, strong) NSString *etalase_total_product;
@property (nonatomic, strong) NSString *etalase_url;
@property (nonatomic, strong) NSString *useAce;

@property (nonatomic) BOOL isGetListProductFromAce;


+(RKObjectMapping*)mapping;

@end
