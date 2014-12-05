//
//  SettingLocationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface SettingLocationResult : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic) BOOL is_allow;

@end
