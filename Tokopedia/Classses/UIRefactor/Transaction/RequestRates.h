//
//  RequestRates.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateResponse.h"

@protocol RequestRatesDelegate <NSObject>

-(void)successRequestRates:(RateData*)data;

@end


@interface RequestRates : NSObject <TokopediaNetworkManagerDelegate>

@property (strong, nonatomic) id<RequestRatesDelegate> delegate;

-(void)doRequestWithNames:(NSArray *)names origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight;

@end
