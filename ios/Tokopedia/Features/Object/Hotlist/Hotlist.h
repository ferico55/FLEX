//
//  Hotlist.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HotlistData.h"

@interface Hotlist : NSObject <NSCoding, TKPObjectMapping>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) HotlistData *data;

- (void) encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

+ (RKObjectMapping*)mapping;

@end
