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

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) CatalogShopAWSResult *result;
@end
