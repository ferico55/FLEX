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

-(void)doRequest;

@end
