//
//  ClosedScheduleDetail.h
//  Tokopedia
//
//  Created by Johanes Effendi on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLOSE_STATUS_OPEN 1
#define CLOSE_STATUS_CLOSED 2
#define CLOSE_STATUS_CLOSE_SCHEDULED 3

@interface ClosedScheduleDetail : NSObject
@property (nonatomic, strong) NSString* close_end;
@property (nonatomic, strong) NSString* close_start;
@property NSInteger close_status;

@end
