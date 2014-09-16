//
//  HotlistResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HotlistList.h"
#import "Paging.h"

@interface HotlistResult : NSObject

@property (nonatomic, strong) HotlistList *list;
@property (nonatomic, strong) Paging *paging;

@end
