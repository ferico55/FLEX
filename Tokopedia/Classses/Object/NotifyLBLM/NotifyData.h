//
//  NotifyData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NotifyAttributes.h"

#import "TKPObjectMapping.h"

@interface NotifyData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *notify_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NotifyAttributes *attributes;

@end
