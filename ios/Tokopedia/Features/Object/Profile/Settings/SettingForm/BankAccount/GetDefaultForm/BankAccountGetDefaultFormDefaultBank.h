//
//  BankAccountGetDefaultFormDefaultBank.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankAccountGetDefaultFormDefaultBank : NSObject

@property (nonatomic) NSInteger bank_account_id;
@property (nonatomic, strong) NSString *bank_name;
@property (nonatomic, strong) NSString *bank_account_name;
@property (nonatomic, strong) NSString *bank_owner_id;
@property (nonatomic, strong) NSString *token;

+ (RKObjectMapping *)mapping;

@end
