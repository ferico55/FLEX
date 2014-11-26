//
//  EtalaseResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EtalaseList.h"
#import "Paging.h"

@interface EtalaseResult : NSObject

@property (strong, nonatomic) NSArray *list;
@property (nonatomic, strong) Paging *paging;

@end
