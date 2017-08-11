//
//  AddProductSubmitResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddProductSubmitResult : NSObject

@property (nonatomic, strong) NSString *product_primary_pic;
@property (nonatomic, strong) NSString *product_desc;
@property (nonatomic, strong) NSString *product_etalase;
@property (nonatomic) NSInteger is_success;
@property (nonatomic) NSInteger product_id;
@property (nonatomic, strong) NSString *product_dest;
@property (nonatomic, strong) NSString *product_url;
@property (nonatomic, strong) NSString *product_name;

@end
