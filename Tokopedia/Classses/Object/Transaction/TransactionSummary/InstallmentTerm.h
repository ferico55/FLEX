//
//  InstallmentTerm.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstallmentTerm : NSObject

@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *monthly_price;
@property (nonatomic, strong) NSString *monthly_price_idr;

@end
