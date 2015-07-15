//
//  RequestCategory.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CategoryObj.h"

@interface RequestCategory : NSObject

@property (strong, nonatomic) NSNumber *department_id;
@property UIViewController *viewController;
@property NSArray *listDepartment;

@end
