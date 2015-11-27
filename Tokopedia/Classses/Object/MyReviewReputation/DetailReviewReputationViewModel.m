//
//  DetailReviewReputaionViewModel.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailReviewReputationViewModel.h"

@implementation DetailReviewReputationViewModel

- (NSString*)review_message {
    return [self.review_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)product_name {
    return [self.product_name kv_decodeHTMLCharacterEntities];
}

@end
