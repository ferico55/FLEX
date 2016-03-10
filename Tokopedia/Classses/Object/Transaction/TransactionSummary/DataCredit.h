//
//  DataCredit.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCredit : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *user_email;
@property (nonatomic, strong) NSString *payment_id;
@property (nonatomic, strong) NSString *cc_agent;
@property (nonatomic, strong) NSString *cc_type;
@property (nonatomic, strong) NSString *cc_card_bank_type;

@end
