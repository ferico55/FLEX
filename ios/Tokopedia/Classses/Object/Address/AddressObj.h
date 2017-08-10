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

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) AddressResult *data;

+(NSDictionary *_Nonnull)attributeMappingDictionary;
+(RKObjectMapping *_Nonnull) mapping;

@end
