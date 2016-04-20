//
//  ATCPushLocalytics.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductDetail.h"

@interface ATCPushLocalytics : NSObject

+ (void)pushLocalyticsATCProduct:(ProductDetail*)product;

@end
