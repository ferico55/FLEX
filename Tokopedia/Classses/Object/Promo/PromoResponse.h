//
//  PromoResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoResult.h"

@interface PromoResponse : NSObject

/*
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) PromoResult *result;
*/

@property (nonatomic, strong) NSArray<PromoResult*>* data;
+ (RKObjectMapping *)mapping;

@end
