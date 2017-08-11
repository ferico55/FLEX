//
//  MethodList.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *method_id;
@property (nonatomic, strong) NSString *method_name;

@end
