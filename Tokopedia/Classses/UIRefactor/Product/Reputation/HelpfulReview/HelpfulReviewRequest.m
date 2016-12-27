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
#import "Paging.h"
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

@interface HelpfulReviewRequest()<TokopediaNetworkManagerDelegate>
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
    networkManager.delegate = self;
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

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    return @{@"product_id":_productId,
             @"action":@"get_product_helpful_review"};
}

- (NSString*)getPath:(int)tag {
    return @"helpful_review.pl";
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[HelpfulReviewResponse class]];
    [responseMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        @"config":@"config"}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HelpfulReviewResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"helpful_reviews_total":@"helpful_reviews_total"}];
    
    RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
    [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{CReviewUpdateTime:CReviewUpdateTime,
                                                                        CReviewRateAccuracyDesc:CReviewRateAccuracyDesc,
                                                                        CReviewUserLabelID:CReviewUserLabelID,
                                                                        CReviewUserName:CReviewUserName,
                                                                        CReviewRateAccuracy:CReviewRateAccuracy,
                                                                        CReviewMessage:CReviewMessage,
                                                                        CReviewRateProductDesc:CReviewRateProductDesc,
                                                                        CReviewRateSpeedDesc:CReviewRateSpeedDesc,
                                                                        CReviewShopID:CShopID,
                                                                        @"review_reputation_id":CReputationID,
                                                                        CReviewUserImage:CReviewUserImage,
                                                                        CReviewUserLabel:CReviewUserLabel,
                                                                        CReviewCreateTime:CReviewCreateTime,
                                                                        CReviewID:CReviewID,
                                                                        CReviewRateServiceDesc:CReviewRateServiceDesc,
                                                                        CReviewRateProduct:CReviewRateProduct,
                                                                        CReviewRateSpeed:CReviewRateSpeed,
                                                                        CReviewRateService:CReviewRateService,
                                                                        CReviewUserID:CReviewUserID
                                                                        }];
    
    RKObjectMapping *reviewReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                             CNoReputation,
                                                             CNegative,
                                                             CNeutral,
                                                             CPositif]];
    
    RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
    [detailTotalLikeMapping addAttributeMappingsFromDictionary:@{CTotalLike:CTotalLike,
                                                                 CTotalDislike:CTotalDislike}];
    
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromArray:@[CResponseCreateTime,
                                                           CResponseMessage]];
    
    RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
    [productOwnerMapping addAttributeMappingsFromDictionary:@{CUserLabelID:CUserLabelID,
                                                              CUserLabel:CUserLabel,
                                                              CuserID:CuserID,
                                                              @"user_shop_name":CShopName,
                                                              @"user_shop_image":CShopImg,
                                                              CUserImage:CUserImg,
                                                              CUserName:CFullName,
                                                              CFullName:CUserName}];
    RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopReputation class]];
    [shopReputationMapping addAttributeMappingsFromArray:@[CToolTip,
                                                           CReputationBadge,
                                                           CReputationScore,
                                                           CScore,
                                                           CMinBadgeScore]];
    
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    
    RKObjectMapping *ratingListMapping = [RKObjectMapping mappingForClass:[RatingList class]];
    [ratingListMapping addAttributeMappingsFromArray:@[CRatingRatingStarPoint,
                                                       CRatingTotalRateAccuracyPersen,
                                                       CRatingRateService,
                                                       CRatingRatingStarDesc,
                                                       CRatingRatingFmt,
                                                       CRatingTotalRatingPersen,
                                                       CRatingUrlFilterRateAccuracy,
                                                       CRatingRating,
                                                       CRatingUrlFilterRating,
                                                       CRatingRateSpeed,
                                                       CRatingRateAccuracy,
                                                       CRatingRateAccuracyFmt,
                                                       CRatingRatingPoint]];
    
    //add relationship mapping
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation" toKeyPath:@"review_user_reputation" withMapping:reviewReputationMapping]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_like_dislike" toKeyPath:@"review_like_dislike" withMapping:detailTotalLikeMapping]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
    //[productOwnerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserShopReputation toKeyPath:CUserShopReputation withMapping:shopReputationMapping]];
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CReputationBadgeObject withMapping:shopBadgeMapping]];
    
    //add relationship mapping
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"helpful_reviews" toKeyPath:@"helpful_reviews" withMapping:detailReputationReviewMapping]];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:tag]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) result).dictionary;
    id stat = [resultDict objectForKey:@""];
    HelpfulReviewResponse *tempReview = stat;
    return tempReview.status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    HelpfulReviewResponse *tempReview = stat;
    reviewResult = tempReview.result;
    
    for(DetailReputationReview *detailReputation in reviewResult.helpful_reviews){
        detailReputation.product_id = _productId;
        detailReputation.review_product_id = _productId;
    }
    
    [_delegate didReceiveHelpfulReview:reviewResult.helpful_reviews];
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
}


@end
