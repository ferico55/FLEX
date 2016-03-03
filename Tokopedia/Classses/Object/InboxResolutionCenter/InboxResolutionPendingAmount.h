//
//  InboxResolutionPendingAmount.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"

@interface InboxResolutionPendingAmount : NSObject <TKPObjectMapping>
@property (nonatomic, strong) NSString *total_amt_idr;
@property (nonatomic, strong) NSString *total_amt;

@end
