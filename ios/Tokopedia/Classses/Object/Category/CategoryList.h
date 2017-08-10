//
//  CategoryList.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryList : NSObject

@property (nonatomic, strong, nonnull) NSString *department_name;
@property (nonatomic, strong, nonnull) NSString *department_identifier;
@property (nonatomic, strong, nonnull) NSString *department_dir_view;
@property (nonatomic, strong, nonnull) NSString *department_id;
@property (nonatomic, strong, nonnull) NSString *department_tree;

@end
