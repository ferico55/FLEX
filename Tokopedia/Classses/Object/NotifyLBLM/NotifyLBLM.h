//
//  NotifyLBLM.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NotifyData.h"

#import "TKPObjectMapping.h"

@interface NotifyLBLM : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NotifyData *data;

@end
