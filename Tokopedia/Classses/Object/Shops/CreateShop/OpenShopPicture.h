//
//  OpenShopPicture.h
//  Tokopedia
//
//  Created by Tokopedia on 5/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OpenShopPictureResult;

@interface OpenShopPicture : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) OpenShopPictureResult *result;
@end
