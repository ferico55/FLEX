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

@interface HotlistDetailResult : NSObject

@property (nonatomic, strong) NSString *cover_image;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) Hashtags *hashtags;
@property (nonatomic, strong) DepartmentTree *department_tree;

@end
