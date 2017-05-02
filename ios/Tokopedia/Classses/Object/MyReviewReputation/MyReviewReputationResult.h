//
//  MyReviewReputationResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CList @"list"
#define CPaging @"paging"
@class Paging;

@interface MyReviewReputationResult : NSObject
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSString *token;

+ (RKObjectMapping*)mapping;

@end
