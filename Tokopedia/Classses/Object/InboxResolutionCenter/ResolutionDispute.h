//
//  ResolutionDispute.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionDispute : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *dispute_update_time;
@property (nonatomic) NSInteger dispute_is_responded;
@property (nonatomic, strong) NSString *dispute_create_time;
@property (nonatomic) NSInteger dispute_is_expired;
@property (nonatomic, strong) NSString *dispute_update_time_short;
@property (nonatomic) NSInteger dispute_is_call_admin;
@property (nonatomic, strong) NSString *dispute_create_time_short;
@property (nonatomic, strong) NSString *dispute_status;
@property (nonatomic, strong) NSString *dispute_deadline;
@property (nonatomic, strong) NSString *dispute_resolution_id;
@property (nonatomic, strong) NSString *dispute_detail_url;
@property (nonatomic) NSInteger dispute_30_days;
@property (nonatomic, strong) NSString *dispute_split_info;

@end
