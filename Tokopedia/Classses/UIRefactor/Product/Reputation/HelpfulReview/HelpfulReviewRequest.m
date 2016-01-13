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



@interface HelpfulReviewRequest()<TokopediaNetworkManagerDelegate>
@end

@implementation HelpfulReviewRequest{
    TokopediaNetworkManager *networkManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
    }
    return self;
}

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    return @{@"product_id":@"123123"};
}

- (NSString*)getPath:(int)tag {
    return @"helpful_review.pl";
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromArray:@[CUriNext,
                                                   CUriPrevious]];
    
    
    RKObjectMapping *advreviewMapping = [RKObjectMapping mappingForClass:[AdvanceReview class]];
    [advreviewMapping addAttributeMappingsFromDictionary:@{CProductRatingPoint:CProductRatingPoint,
                                                           CProductRateAccuracyPoint:CProductRateAccuracyPoint,
                                                           CProductPositiveReviewRating:CProductPositiveReviewRating,
                                                           CProductNetralReviewRating:CProductNetralReviewRating,
                                                           CProductRatingStarPoint:CProductRatingStarPoint,
                                                           CProductRatingStarDesc:CProductRatingStarDesc,
                                                           CProductNegativeReviewRating:CProductNegativeReviewRating,
                                                           CProductReview:CProductReview,
                                                           CProductRateAccuracy:CProductRateAccuracy,
                                                           CProductAccuracyStarDesc:CProductAccuracyStarDesc,
                                                           CProductRating:CProductRating,
                                                           CProductNetralReviewRateAccuray:CProductNetralReviewRateAccuray,
                                                           CProductAccuacyStarRate:CProductAccuacyStarRate,
                                                           CProductPositiveReviewRateAccuracy:CProductPositiveReviewRateAccuracy,
                                                           CProductNegativeReviewRateAccuracy:CProductNegativeReviewRateAccuracy
                                                           }];
    
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
    [productOwnerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserShopReputation toKeyPath:CUserShopReputation withMapping:shopReputationMapping]];
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CReputationBadgeObject withMapping:shopBadgeMapping]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CAdvanceReview toKeyPath:CAdvanceReview withMapping:advreviewMapping]];
    
    [advreviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductRatingList toKeyPath:CRating_List withMapping:ratingListMapping]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewReputationMapping]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationReviewMapping]];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
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
    Review *tempReview = stat;
    return tempReview.status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    /*
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    review = stat;
    
    if(page==0 && review.result.list!=nil) {
        arrList = [[NSMutableArray alloc] initWithArray:review.result.list];
        
        segmentedControl.enabled = YES;
        btnFilter6Month.enabled = btnFilterAllTime.enabled = YES;
        [self setRateStar:(int)segmentedControl.selectedSegmentIndex withAnimate:YES];
    }else if(review.result.list != nil) {
        [arrList addObjectsFromArray:review.result.list];
    }
    */
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
