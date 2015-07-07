//
//  RatingResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 6/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RatingResult.h"

@interface RatingResponse : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) NSString *server_process_time;
@property (nonatomic, strong) NSArray *message_error;
@property (strong, nonatomic) RatingResult *result;

@end
