//
//  HotlistDetailResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "Hashtags.h"
#import "DepartmentTree.h"
#import "List.h"

@interface HotlistDetailResult : NSObject

@property (nonatomic, strong) NSString *cover_image;
@property (nonatomic, strong) NSString *desc_key;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *hashtags;
@property (nonatomic, strong) NSArray *department_tree;
@property (nonatomic, strong) NSArray *list;

@end
