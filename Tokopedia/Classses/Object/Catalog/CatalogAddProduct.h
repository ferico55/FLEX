//
//  CatalogAddProduct.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogResult.h"

@interface CatalogAddProduct : NSObject  <TKPObjectMapping>

@property (nonatomic, strong) NSArray<NSString*> *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) CatalogResult *data;

@end
