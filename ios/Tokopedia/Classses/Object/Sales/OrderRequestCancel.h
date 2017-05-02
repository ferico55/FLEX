//
//  OrderRequestCancel.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderRequestCancel : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *cancel_request;
@property (strong, nonatomic) NSString *reason_time;
@property (strong, nonatomic) NSString *reason;

@property (strong, nonatomic) NSAttributedString *reasonFormattedString;

@end
