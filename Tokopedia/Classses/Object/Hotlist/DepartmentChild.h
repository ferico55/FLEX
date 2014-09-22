//
//  DepartmentChild.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepartmentChild2.h"
#import <Foundation/Foundation.h>

@interface DepartmentChild : NSObject

@property (nonatomic, strong) NSString *tree;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *d_id;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSArray *child;

@end
