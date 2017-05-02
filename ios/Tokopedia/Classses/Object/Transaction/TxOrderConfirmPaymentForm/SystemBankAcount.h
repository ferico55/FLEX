//
//  SystemBankAcount.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemBankAcount : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *sysbank_account_number;
@property (nonatomic, strong) NSString *sysbank_account_name;
@property (nonatomic, strong) NSString *sysbank_name;
@property (nonatomic, strong) NSString *sysbank_note;
@property (nonatomic, strong) NSString *sysbank_id;

@end
