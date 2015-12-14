//
//  InboxResolutionCenterResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"
#import "InboxResolutionCenterList.h"

@interface InboxResolutionCenterResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic) NSInteger type;
@property (nonatomic, strong) NSString *pending_days;

@end
