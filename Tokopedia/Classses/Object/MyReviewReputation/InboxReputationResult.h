//
//  InboxReputationResult.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"

@interface InboxReputationResult : NSObject
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;

+ (RKObjectMapping*)mapping;

@end
