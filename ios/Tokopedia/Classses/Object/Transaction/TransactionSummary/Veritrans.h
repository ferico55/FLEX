//
//  Veritrans.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Veritrans : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *token_url;
@property (nonatomic, strong) NSString *client_key;

@end
