//
//  ReviewList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewList.h"
#import "detail.h"

@implementation ReviewList

- (NSString*)review_message {
    return [_review_message kv_decodeHTMLCharacterEntities];
}

- (NSString*)review_product_name {
    return [_review_product_name kv_decodeHTMLCharacterEntities];
}


- (DetailReviewReputationViewModel *)viewModel {
    if(_viewModel == nil) {
        DetailReviewReputationViewModel *viewModel = [[DetailReviewReputationViewModel alloc] init];
        [viewModel setReview_message:_review_message];
        [viewModel setReview_message:_review_user_name];
        [viewModel setReview_user_image:_review_user_image];
        [viewModel setReview_rate_quality:_review_rate_quality];
        [viewModel setReview_rate_accuracy:_review_rate_accuracy];
        [viewModel setReview_create_time:_review_create_time];
       
        _viewModel = viewModel;
    }
    return _viewModel;
}

+ (RKObjectMapping *)mapping{
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ReviewList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIREVIEWSHOPIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWCREATETIMEKEY,
                                                 kTKPDREVIEW_APIREVIEWIDKEY,
                                                 CReviewReputationID,
                                                 @"review_shop_name",
                                                 kTKPDREVIEW_APIREVIEWUSERNAMEKEY,
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEQUALITY,
                                                 kTKPDREVIEW_APIREVIEWRATESPEEDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIPRODUCTNAMEKEY,
                                                 kTKPDREVIEW_APIPRODUCTIDKEY,
                                                 kTKPDREVIEW_APIPRODUCTIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWISOWNERKEY,
                                                 kTKPDREVIEW_APIPRODUCTSTATUSKEY,
                                                 KTKPDREVIEW_APIREVIEWUSERLABELKEY
                                                 ]];
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:[ReputationDetail mapping]]];
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response"
                                                                                toKeyPath:@"review_response"
                                                                              withMapping:[ReviewResponse mapping]]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_product_owner"
                                                                                toKeyPath:@"review_product_owner"
                                                                              withMapping:[ProductOwner mapping]]];
    
    return listMapping;
}

@end
