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
    if (self)
    {
        
    }
    return self;
}

- (void)requestHelpfulReview:(NSString*) productId{
    networkManager = [TokopediaNetworkManager new];
    networkManager.delegate = self;
    networkManager.tagRequest = 1;
    networkManager.isParameterNotEncrypted = NO;
    
    _productId = productId;
    [networkManager doRequest];
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
