//
//  SearchResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "List.h"
#import "Paging.h"
#import "DepartmentTree.h"
#import "SearchRedirect.h"

@interface SearchResult : NSObject

@property (nonatomic, strong) SearchRedirect *redirect_url;
@property (nonatomic, strong) List*list;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) DepartmentTree *departmenttree;

@property (nonatomic, strong) NSString *cover_image;
@property (nonatomic, strong) NSString *description1;

@end
