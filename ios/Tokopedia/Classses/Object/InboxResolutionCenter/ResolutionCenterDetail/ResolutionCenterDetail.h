//
//  ResolutionCenterDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResolutionCenterDetailResult.h"

@interface ResolutionCenterDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ResolutionCenterDetailResult *result;
@property (nonatomic, strong) ResolutionCenterDetailResult *data;

@end
