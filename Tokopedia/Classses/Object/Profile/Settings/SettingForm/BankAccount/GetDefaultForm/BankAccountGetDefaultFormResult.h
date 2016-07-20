//
//  BankAccountGetDefaultFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankAccountGetDefaultFormDefaultBank.h"

@interface BankAccountGetDefaultFormResult : NSObject

@property (nonatomic, strong) BankAccountGetDefaultFormDefaultBank *default_bank;

+ (RKObjectMapping *)mapping;

@end
