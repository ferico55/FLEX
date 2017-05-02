//
//  ResponseError.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseError : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *errorID;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *title;

@end
