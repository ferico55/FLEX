//
//  HelpfulReviewRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "HelpfulReviewRequest.h"
#import "TokopediaNetworkManager.h"
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailReputationReview.h"
#import "LoadingView.h"
#import "LikeDislike.h"
#import "LoginViewController.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "NoResultView.h"
#import "ProductReputationCell.h"
#import "ProductOwner.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationViewController.h"
@class Paging;
#import "ReportViewController.h"
#import "RatingList.h"
#import "ReviewResponse.h"
#import "Review.h"
#import "ShopReputation.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "String_Reputation.h"
#import "TotalLikeDislikePost.h"
#import "TotalLikeDislike.h"
#import "TokopediaNetworkManager.h"
#import "ProductReputationSimpleCell.h"
#import "HelpfulReviewResponse.h"
#import "HelpfulReviewResult.h"

@interface HelpfulReviewRequest()
@end

@implementation HelpfulReviewRequest{
    TokopediaNetworkManager *networkManager;
    NSString *_productId;
    HelpfulReviewResult *reviewResult;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)requestHelpfulReview:(NSString*) productId{
    networkManager = [TokopediaNetworkManager new];
    networkManager.tagRequest = 1;
    networkManager.isParameterNotEncrypted = NO;
    networkManager.isUsingHmac = YES;
    
    _productId = productId;
//    [networkManager doRequest];
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/product/get_helpful_review.pl"
                                method:RKRequestMethodGET
                             parameter:@{@"product_id" : _productId}
                               mapping:[HelpfulReviewResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
                                 id stat = [resultDict objectForKey:@""];
                                 HelpfulReviewResponse *tempReview = stat;
                                 reviewResult = tempReview.data;
                                 
                                 for(DetailReputationReview *detailReputation in reviewResult.list){
                                     detailReputation.product_id = _productId;
                                     detailReputation.review_product_id = _productId;
                                     detailReputation.review_is_helpful = YES;
                                 }
                                 
                                 [_delegate didReceiveHelpfulReview:reviewResult.list];
                             }
                             onFailure:^(NSError *errorResult) {
                                 
                                 
                             }];
    
}


@end
