//
//  Breadcrumb.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKPObjectMapping.h"

@interface Breadcrumb : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *department_name;
@property (nonatomic, strong, nonnull) NSString *department_id;

@end
