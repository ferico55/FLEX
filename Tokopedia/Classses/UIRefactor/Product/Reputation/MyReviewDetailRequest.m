//
//  MyReviewDetailRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailRequest.h"
#import "MyReviewReputation.h"
#import "MyReviewReputationResult.h"
#import "ShopBadgeLevel.h"
#import "Paging.h"
#import "ReputationDetail.h"
#import "ProductOwner.h"
#import "ReviewResponse.h"
#import "SkipReview.h"
#import "ResponseComment.h"
#import "ResponseCommentResult.h"
#import "GeneralAction.h"
#import "GeneralActionResult.h"
#import "LuckyDeal.h"

typedef NS_ENUM(NSInteger, MyReviewDetailRequestType) {
    MyReviewDetailRequestGet,
    MyReviewDetailRequestSkip,
    DeleteReputationReviewResponse,
    InsertReputation
};

@interface MyReviewDetailRequest()<TokopediaNetworkManagerDelegate>

@end

@implementation MyReviewDetailRequest {
    TokopediaNetworkManager *networkManager;
    
    DetailMyInboxReputation *myInboxReputation;
    DetailReputationReview *reputationReview;
    
    NSString *isAutoRead;
    NSString *reputationScore;
    NSString *getDataFromMasterInServer;
    
    __weak RKObjectManager *_objectManager;
}

- (id)init {
    self = [super init];
    if (self) {
        networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
    }
    return self;
}

#pragma mark - Public Functions
- (void)requestGetListReputationReviewWithDetail:(DetailMyInboxReputation*)rep autoRead:(NSString*)autoRead getDataFromMasterInServer:(NSString *)val {
    myInboxReputation = rep;
    isAutoRead = autoRead;
    getDataFromMasterInServer = val;
    networkManager.tagRequest = MyReviewDetailRequestGet;
    [networkManager doRequest];
}

- (void)requestSkipReviewWithDetail:(DetailReputationReview*)rep {
    reputationReview = rep;
    networkManager.tagRequest = MyReviewDetailRequestSkip;
    networkManager.isUsingHmac = YES;
    [networkManager doRequest];
}

- (void)requestDeleteReputationReviewResponse:(DetailReputationReview*)review {
    reputationReview = review;
    networkManager.tagRequest = DeleteReputationReviewResponse;
    networkManager.isUsingHmac = YES;
    [networkManager doRequest];
}

- (void)requestInsertReputation:(DetailMyInboxReputation *)inbox withScore:(NSString *)score {
    myInboxReputation = inbox;
    reputationScore = score;
    networkManager.isUsingHmac = YES;
    networkManager.tagRequest = InsertReputation;
    [networkManager doRequest];
}

- (void)cancelAllOperations {
    [_objectManager.operationQueue cancelAllOperations];
}

#pragma mark - Tokopedia Network Manager Delegate
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary* parameter;
    if (tag == MyReviewDetailRequestGet) {
        parameter = @{@"action"              : @"get_list_reputation_review",
                      @"reputation_inbox_id" : myInboxReputation.reputation_inbox_id,
                      @"reputation_id"       : myInboxReputation.reputation_id,
                      @"auto_read"           : isAutoRead
                      };
        
        if ([getDataFromMasterInServer isEqualToString:@"1"]) {
            parameter = @{@"action"              : @"get_list_reputation_review",
                          @"reputation_inbox_id" : myInboxReputation.reputation_inbox_id,
                          @"reputation_id"       : myInboxReputation.reputation_id,
                          @"auto_read"           : isAutoRead,
                          @"n"                   : @(1)
                          };
        }
        
        return parameter;
    } else if (tag == MyReviewDetailRequestSkip) {
        parameter = @{@"reputation_id"       : reputationReview.reputation_id,
                      @"shop_id"             : reputationReview.shop_id,
                      @"product_id"          : reputationReview.product_id
                      };
        
        return parameter;
    } else if (tag == DeleteReputationReviewResponse) {
        parameter = @{@"reputation_id"       : reputationReview.reputation_id,
                      @"shop_id"             : reputationReview.shop_id,
                      @"review_id"           : reputationReview.review_id
                      };
        
        return parameter;
    } else if (tag == InsertReputation) {
        parameter = @{@"buyer_seller"        : myInboxReputation.role,
                      @"reputation_id"       : myInboxReputation.reputation_id,
                      @"reputation_score"    : reputationScore,
                      };
        
        return parameter;
    }
    
    return nil;
}

- (NSString *)getPath:(int)tag {
    if (tag == MyReviewDetailRequestGet) {
        return @"inbox-reputation.pl";
    } else if (tag == MyReviewDetailRequestSkip) {
        return @"/v4/action/reputation/skip_reputation_review.pl";
    } else if (tag == DeleteReputationReviewResponse) {
        return @"/v4/action/reputation/delete_reputation_review_response.pl";
    } else if (tag == InsertReputation) {
        return @"/v4/action/reputation/insert_reputation.pl";
    }
    
    return nil;
}

- (int)getRequestMethod:(int)tag {
    if (tag == MyReviewDetailRequestGet) {
        return RKRequestMethodPOST;
    } else if (tag == MyReviewDetailRequestSkip) {
        return RKRequestMethodGET;
    } else if (tag == DeleteReputationReviewResponse) {
        return RKRequestMethodPOST;
    } else if (tag == InsertReputation) {
        return RKRequestMethodGET;
    }
    
    return 0;
}

- (id)getObjectManager:(int)tag {
    if (tag == MyReviewDetailRequestGet) {
        _objectManager = [RKObjectManager sharedClient];
        
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[MyReviewReputation class]];
        [statusMapping addAttributeMappingsFromArray:@[CStatus,
                                                       CMessageError,
                                                       CMessageStatus,
                                                       CServerProcessTime
                                                       ]];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
        
        RKObjectMapping *detailReputationMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
        [detailReputationMapping addAttributeMappingsFromArray:@[CShopID,
                                                                 CProductRatingPoint,
                                                                 CReviewIsSkipable,
                                                                 CReviewIsSkiped,
                                                                 CProductStatus,
                                                                 CReviewFullName,
                                                                 CReviewMessage,
                                                                 CProductSpeedDesc,
                                                                 CReviewReadStatus,
                                                                 CProductUri,
                                                                 CReviewUserID,
                                                                 CReviewUserLabel,
                                                                 CProductServiceDesc,
                                                                 CProductSpeedPoint,
                                                                 CReviewStatus,
                                                                 CReviewUpdateTime,
                                                                 CProductServicePoint,
                                                                 CProductAccuracyPoint,
                                                                 CReputationID,
                                                                 CProductID,
                                                                 CProductRatingDesc,
                                                                 CProductImage,
                                                                 CProductAccuracyDesc,
                                                                 CUserImage,
                                                                 CReputationInboxID,
                                                                 CReviewCreateTime,
                                                                 CUserURL,
                                                                 CShopName,
                                                                 CReviewMessageEdit,
                                                                 CReviewID,
                                                                 CReviewPostTime,
                                                                 CReviewIsAllowEdit,
                                                                 CProductName,
                                                                 CShopDomain
                                                                 ]];
        
        RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel,
                                                          CSet]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromArray:@[CUriNext,
                                                       CUriPrevious]];
        
        RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                     CNoReputation,
                                                                     CNegative,
                                                                     CNeutral,
                                                                     CPositif]];
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromArray:@[CShopID,
                                                             CUserLabelID,
                                                             CUserURL,
                                                             CShopImg,
                                                             CShopUrl,
                                                             CShopName,
                                                             CFullName,
                                                             CShopReputation,
                                                             CUserImg,
                                                             CUserLabel,
                                                             CuserID
                                                             ]];
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewResponseMapping addAttributeMappingsFromArray:@[CResponseMessage,
                                                               CResponseCreateTime,
                                                               CResponseTimeFmt]];
        
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopBadgeLevel
                                                                                                toKeyPath:CShopBadgeLevel
                                                                                              withMapping:shopBadgeMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation
                                                                                                toKeyPath:CReviewUserReputation
                                                                                              withMapping:reviewUserReputationMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductOwner
                                                                                                toKeyPath:CProductOwner
                                                                                              withMapping:productOwnerMapping]];
        [detailReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse
                                                                                                toKeyPath:CReviewResponse
                                                                                              withMapping:reviewResponseMapping]];
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList
                                                                                      toKeyPath:CList
                                                                                    withMapping:detailReputationMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging
                                                                                      toKeyPath:CPaging
                                                                                    withMapping:pagingMapping]];
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [_objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectManager;
        
    } else if (tag == MyReviewDetailRequestSkip) {
        _objectManager = [RKObjectManager sharedClientHttps];
        
        RKObjectMapping *skipReviewMapping = [RKObjectMapping mappingForClass:[SkipReview class]];
        [skipReviewMapping addAttributeMappingsFromArray:@[@"status",
                                                           @"server_process_time",
                                                           @"message_error",
                                                           @"message_status"]];
        
        RKObjectMapping *skipReviewDataMapping = [RKObjectMapping mappingForClass:[SkipReviewResult class]];
        [skipReviewDataMapping addAttributeMappingsFromArray:@[@"reputation_review_counter",
                                                               @"is_success",
                                                               @"show_bookmark"]];
        
        
        [skipReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                          toKeyPath:@"data"
                                                                                        withMapping:skipReviewDataMapping]];
        
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:skipReviewMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [_objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectManager;
    } else if (tag == DeleteReputationReviewResponse) {
        _objectManager = [RKObjectManager sharedClientHttps];
        
        RKObjectMapping *responseCommentMapping = [RKObjectMapping mappingForClass:[ResponseComment class]];
        [responseCommentMapping addAttributeMappingsFromArray:@[@"status",
                                                                @"server_process_time"]];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResponseCommentResult class]];
        [resultMapping addAttributeMappingsFromArray:@[@"is_owner",
                                                       @"reputation_review_counter",
                                                       @"is_success",
                                                       @"show_bookmark",
                                                       @"review_id"]];
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromArray:@[@"shop_id",
                                                             @"user_label_id",
                                                             @"user_url",
                                                             @"shop_img",
                                                             @"shop_url",
                                                             @"shop_name",
                                                             @"full_name",
                                                             @"user_img",
                                                             @"user_label",
                                                             @"user_id",
                                                             @"shop_reputation_badge",
                                                             @"shop_reputation_score"]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_owner"
                                                                                      toKeyPath:@"product_owner"
                                                                                    withMapping:productOwnerMapping]];
        
        [responseCommentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                               toKeyPath:@"data"
                                                                                             withMapping:resultMapping]];
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:responseCommentMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectManager;
    } else if (tag == InsertReputation) {
        _objectManager = [RKObjectManager sharedClientHttps];
        
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromArray:@[@"status",
                                                       @"message_error",
                                                       @"server_process_time"]];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromArray:@[@"is_success"]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ld"
                                                                                      toKeyPath:@"ld"
                                                                                    withMapping:[LuckyDeal mapping]]];
        
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                      toKeyPath:@"data"
                                                                                    withMapping:resultMapping]];
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodGET
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectManager;
    }
    
    return nil;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == MyReviewDetailRequestGet) {
        return ((MyReviewReputation*)stat).status;
    } else if (tag == MyReviewDetailRequestSkip) {
        return ((SkipReview*)stat).status;
    } else if (tag == DeleteReputationReviewResponse) {
        return ((ResponseComment*)stat).status;
    } else if (tag == InsertReputation) {
        return ((GeneralAction*)stat).status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id temp = [result objectForKey:@""];
    
    if (tag == MyReviewDetailRequestGet) {
        [_delegate didReceiveReviewListing:((MyReviewReputation*)temp).result];
    } else if (tag == MyReviewDetailRequestSkip) {
        [_delegate didSkipReview:((SkipReview*)temp).data];
    } else if (tag == DeleteReputationReviewResponse) {
        [_delegate didDeleteReputationReviewResponse:((ResponseComment*)temp).data];
    } else if (tag == InsertReputation) {
        [_delegate didInsertReputation:(GeneralAction*)temp];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if (tag == MyReviewDetailRequestSkip) {
        NSDictionary *result = ((RKMappingResult*)errorResult).dictionary;
        id temp = [result objectForKey:@""];
        
        [_delegate didFailSkipReview:(SkipReview*)temp];
    }
}

@end
