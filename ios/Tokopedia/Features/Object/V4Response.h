//
//  V4Response.h
//  Tokopedia
//
//  Created by Samuel Edwin on 10/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V4Response<__covariant ObjectType> : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ObjectType data;

+ (RKObjectMapping *)mappingWithData:(RKObjectMapping *)childMapping;

@end
