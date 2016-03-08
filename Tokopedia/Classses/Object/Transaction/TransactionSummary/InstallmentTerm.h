//
//  InstallmentTerm.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstallmentTerm : NSObject

@property (nonatomic, strong) NSString *total_price;
@property (nonatomic, strong) NSString *monthly_price;
@property (nonatomic, strong) NSString *total_price_idr;
@property (nonatomic, strong) NSString *admin_price_idr;
@property (nonatomic, strong) NSString *monthly_price_idr;
@property (nonatomic, strong) NSString *bunga;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *is_zero;
@property (nonatomic, strong) NSString *interest_price_idr;
@property (nonatomic, strong) NSString *interest_price;
@property (nonatomic, strong) NSString *admin_price;

@end
