//
//  Note.h
//  Tokopedia
//
//  Created by Tokopedia on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NoteResult;

@interface Note : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) NoteResult *result;
@end