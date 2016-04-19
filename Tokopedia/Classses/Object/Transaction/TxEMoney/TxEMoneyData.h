//
//  TxEMoneyData.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxEMoneyData : NSObject <TKPObjectMapping>


@property (nonatomic, strong) NSString *trace_num;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *no_hp;
@property (nonatomic, strong) NSString *trx_id;
@property (nonatomic, strong) NSString *id_emoney;

@end
