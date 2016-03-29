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
#define API_UPLOAD_GENERATE_HOST_PATH @"action/generate-host.pl"

#pragma mark - Generate Host Delegate
@protocol GenerateHostDelegate <NSObject>
@required
- (void)successGenerateHost:(GenerateHost*)generateHost;
- (void)failedGenerateHost:(NSArray*)errorMessages;

@end

@interface RequestGenerateHost : NSObject


@property (nonatomic, weak) IBOutlet id<GenerateHostDelegate> delegate;


@property NSString *prodct_id;
@property BOOL isNotUsingNewAdd;

- (void)configureRestkitGenerateHost;
- (void)requestGenerateHost;

+(void)fetchGenerateHostSuccess:(void(^)(GeneratedHost* host))success failure:(void (^)(NSError * error))failure;

@end
