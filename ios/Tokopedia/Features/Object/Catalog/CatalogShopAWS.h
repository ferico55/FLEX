//
//  CatalogShopAWS.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogShopAWSResult.h"

@interface CatalogShopAWS : NSObject

@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *message_error;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) CatalogShopAWSResult *result;

+ (RKObjectMapping *_Nonnull)objectMapping;

@end
