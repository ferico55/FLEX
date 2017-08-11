//
//  EtalaseResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EtalaseList.h"
#import "EtalaseListOther.h"
@class Paging;
//#import "Tokopedia-Swift.h"

@interface EtalaseResult : NSObject

@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) NSMutableArray *list_other;
@property (strong, nonatomic) Paging *paging;

+(RKObjectMapping*)mapping;

@end
