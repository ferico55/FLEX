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

@interface HotlistData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;

- (void) encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;


@end
