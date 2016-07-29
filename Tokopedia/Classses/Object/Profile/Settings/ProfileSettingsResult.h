//
//  ProfileSettingsResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileSettingsResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *address_id;

@end
