//
//  NoteDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NoteDetailResult.h"

@interface NoteDetail : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) NoteDetailResult *result;

@end
