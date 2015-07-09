//
//  DetailReviewReputaionViewModel.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReviewResponse.h"

@interface DetailReviewReputaionViewModel : NSObject
@property (nonatomic, strong) NSString *product_rating_point, *product_name, *review_create_time, *review_is_skipable, *product_uri, *product_service_point, *product_accuracy_point, *review_message, *readStat, *read_status;
@property (nonatomic, strong) ReviewResponse *review_response;
@end
