//
//  TransactionCartGateway.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionCartGateway : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *gateway_image;
@property (nonatomic, strong) NSNumber *gateway;
@property (nonatomic, strong) NSString *gateway_name;
@property (nonatomic, strong) NSString *toppay_flag;
@property (nonatomic, strong) NSString *gateway_desc;

@end
