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
#import "SearchAWSShop.h"

@interface SearchResult : NSObject

@property (nonatomic, strong) NSString *redirect_url;
@property (nonatomic, strong) NSString *department_id;

//@property (nonatomic, strong) SearchRedirect *redirect_url;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSArray *shops;
@property (nonatomic, strong) NSArray *listshop;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *departmenttree;
@property (nonatomic, strong) NSString *has_catalog;
@property (nonatomic, strong) NSString *search_url;

@end
