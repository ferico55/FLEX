//
//  OrderBooking.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderBooking : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *api_url;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *ut;

@end
