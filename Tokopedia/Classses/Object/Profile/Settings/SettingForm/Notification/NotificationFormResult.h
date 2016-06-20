//
//  NotificationFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationFormNotif.h"

@interface NotificationFormResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NotificationFormNotif *notification;

@end
