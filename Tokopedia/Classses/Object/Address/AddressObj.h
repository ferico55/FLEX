//
//  AddressObj.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressResult.h"

@interface AddressObj : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) AddressResult *result;
@property (nonatomic, strong) AddressResult *data;

+(NSDictionary *)attributeMappingDictionary;
+(RKObjectMapping *) mapping;

@end
