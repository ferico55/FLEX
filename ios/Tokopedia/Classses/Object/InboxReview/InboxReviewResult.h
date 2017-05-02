//
//  InboxReviewResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "InboxReviewList.h"

@interface InboxReviewResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;

@end
