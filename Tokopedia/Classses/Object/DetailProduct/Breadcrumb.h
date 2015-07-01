//
//  Breadcrumb.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CDepartmentID @"department_id"
#define CDepartmentName @"department_name"

@interface Breadcrumb : NSObject

@property (nonatomic, strong) NSString *department_name;
@property (nonatomic, strong) NSString *department_id;

@end
