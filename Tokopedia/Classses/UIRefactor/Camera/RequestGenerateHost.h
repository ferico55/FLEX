//
//  requestGenerateHost.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenerateHost.h"

#pragma mark -- GENERATED HOST
#define API_ACTION_KEY @"action"
#define API_GENERATED_HOST_KEY @"generated_host"
#define API_SERVER_ID_KEY @"server_id"
#define API_UPLOAD_HOST_KEY @"upload_host"
#define API_USER_ID_KEY @"user_id"
#define API_ACTION_GENERATE_HOST @"generate_host"
#define API_UPLOAD_IMAGE_PATH @"action/upload-image.pl"

#pragma mark - Generate Host Delegate
@protocol GenerateHostDelegate <NSObject>
@required
- (void)successGenerateHost:(GenerateHost*)generateHost;

@end

@interface RequestGenerateHost : NSObject

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GenerateHostDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GenerateHostDelegate> delegate;
#endif

- (void)configureRestkitGenerateHost;
- (void)requestGenerateHost;

@end
