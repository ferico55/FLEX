//
//  ReviewList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewList.h"

@implementation ReviewList

- (NSString*)review_message {
    return [_review_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)review_product_name {
    return [_review_product_name kv_decodeHTMLCharacterEntities];
}


- (ProductReputationViewModel *)viewModel {
    if(_viewModel == nil) {
        ProductReputationViewModel *viewModel = [[ProductReputationViewModel alloc] init];
        [viewModel setReviewMessage:self.review_message];
        [viewModel setReviewUserName:self.review_user_name];
        [viewModel setReviewUserThumbUrl:self.review_user_image];
        [viewModel setProductQuality:self.review_rate_quality];
        [viewModel setProductAccuracy:self.review_rate_accuracy];
        [viewModel setReviewDate:self.review_create_time];
       
        _viewModel = viewModel;
    }
    return _viewModel;
}


@end
