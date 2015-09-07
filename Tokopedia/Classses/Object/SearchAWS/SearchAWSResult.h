//
//  SearchAWSResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
@class SearchAWSProduct;

@interface SearchAWSResult : NSObject

@property (nonatomic, strong) NSString *search_url;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSString *st;
@property (nonatomic, strong) NSString *has_catalog;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *catalogs;
@property (nonatomic, strong) NSString *redirect_url;
@property (nonatomic, strong) NSString *department_id;


@end
