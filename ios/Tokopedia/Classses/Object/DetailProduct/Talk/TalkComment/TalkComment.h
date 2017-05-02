//
//  Talk.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TalkCommentResult.h"

@interface TalkComment : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TalkCommentResult *result;

+ (RKObjectMapping *)mapping;
@end
