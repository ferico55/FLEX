//
//  InboxResolutionCenterResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxResolutionCenterList.h"
#import "InboxResolutionPendingAmount.h"
@class Paging;

@interface InboxResolutionCenterResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic) NSInteger type;
@property (nonatomic, strong) NSString *pending_days;
@property (nonatomic, strong) NSString *counter_days;
@property (nonatomic, strong) InboxResolutionPendingAmount *pending_amt;

@end
