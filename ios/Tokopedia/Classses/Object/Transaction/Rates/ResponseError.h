//
//  ResponseError.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseError : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *errorID;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *title;

@end
