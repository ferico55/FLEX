//
//  LoginResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogoutResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *is_delete_device;
@property (nonatomic, strong, nonnull) NSString *is_logout;

@end
