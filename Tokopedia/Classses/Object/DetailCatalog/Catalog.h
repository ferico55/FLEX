//
//  Catalog.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DetailCatalogResult.h"
#define CMessageError @"message_error"
#define CStatus @"status"
#define CServerProcessTime @"server_process_time"

@interface Catalog : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) DetailCatalogResult *result;

@end
