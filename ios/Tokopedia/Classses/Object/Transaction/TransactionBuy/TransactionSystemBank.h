//
//  TransactionSystemBank.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface TransactionSystemBank : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *sb_bank_cabang;
@property (nonatomic, strong, nonnull) NSString *sb_picture;
@property (nonatomic, strong, nonnull) NSString *sb_info;
@property (nonatomic, strong, nonnull) NSString *sb_bank_name;
@property (nonatomic, strong, nonnull) NSString *sb_account_no;
@property (nonatomic, strong, nonnull) NSString *sb_account_name;

@end
