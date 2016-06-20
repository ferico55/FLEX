//
//  TrackOrderResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackOrder.h"

@interface TrackOrderResult : NSObject <TKPObjectMapping>

@property (strong, nonatomic) TrackOrder *track_order;

@end
