//
//  CategoryDetail.h
//  Tokopedia
//
//  Created by Tokopedia on 2/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryDetail : NSObject

@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *weight;
@property (strong, nonatomic) NSString *parent;
@property (strong, nonatomic) NSString *tree;
@property (strong, nonatomic) NSString *has_catalog;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray *child;

@property BOOL isExpanded;
@property BOOL isLastCategory;
@property BOOL hasChildCategories;

@end
