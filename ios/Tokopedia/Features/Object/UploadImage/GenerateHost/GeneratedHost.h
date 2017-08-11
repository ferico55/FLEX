//
//  GeneratedHost.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneratedHost : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *server_id;
@property (nonatomic, strong, nonnull) NSString *upload_host;
@property (nonatomic) NSInteger user_id;

+ (RKObjectMapping* _Nonnull)mapping;

@end
