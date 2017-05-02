//
//  InstallmentBank.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InstallmentTerm.h"

@interface InstallmentBank : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *percentage;
@property (nonatomic, strong) NSString *bank_id;
@property (nonatomic, strong) NSString *bank_name;
@property (nonatomic, strong) NSArray *installment_term;

@end
