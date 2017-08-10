//
//  RateResponse.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RateData.h"
#import "ResponseError.h"

@interface RateResponse : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) RateData *data;
@property (nonatomic, strong, nonnull) NSArray *errors;

@end
