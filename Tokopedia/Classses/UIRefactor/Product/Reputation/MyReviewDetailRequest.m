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

typedef NS_ENUM(NSInteger, MyReviewDetailRequestType) {
    MyReviewDetailRequestGet,
    MyReviewDetailRequestSkip
};

@interface MyReviewDetailRequest()<TokopediaNetworkManagerDelegate>

@end

@implementation MyReviewDetailRequest {
    TokopediaNetworkManager *networkManager;
    
    DetailMyInboxReputation *myInboxReputation;
    DetailReputationReview *reputationReview;
    
    NSString *isAutoRead;
    
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
- (void)requestGetListReputationReviewWithDetail:(DetailMyInboxReputation*)rep autoRead:(NSString*)autoRead {
    myInboxReputation = rep;
    isAutoRead = autoRead;
    networkManager.tagRequest = MyReviewDetailRequestGet;
    [networkManager doRequest];
}

- (void)requestSkipReviewWithDetail:(DetailReputationReview*)rep {
    reputationReview = rep;
    networkManager.tagRequest = MyReviewDetailRequestSkip;
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
    
        return parameter;
    } else if (tag == MyReviewDetailRequestSkip) {
        parameter = @{@"action"              : @"skip_reputation_review",
                      @"reputation_id"       : reputationReview.reputation_id,
                      @"shop_id"             : reputationReview.shop_id,
                      @"product_id"          : reputationReview.product_id
                      };
        
        return parameter;
    }
    
    return nil;
}

- (NSString *)getPath:(int)tag {
    if (tag == MyReviewDetailRequestGet) {
        return @"inbox-reputation.pl";
    } else if (tag == MyReviewDetailRequestSkip) {
        return @"action/reputation.pl";
    }
    
    return nil;
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
        _objectManager = [RKObjectManager sharedClient];
        
        RKObjectMapping *skipReviewMapping = [RKObjectMapping mappingForClass:[SkipReview class]];
        [skipReviewMapping addAttributeMappingsFromArray:@[CStatus,
                                                           CServerProcessTime,
                                                           CMessageError,
                                                           CMessageStatus]];
        
        RKObjectMapping *skipReviewResultMapping = [RKObjectMapping mappingForClass:[SkipReviewResult class]];
        [skipReviewResultMapping addAttributeMappingsFromArray:@[CReputationReviewCounter,
                                                                 CIsSuccess,
                                                                 CShowBookmark]];
        
        
        [skipReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult
                                                                                          toKeyPath:CResult
                                                                                        withMapping:skipReviewResultMapping]];
        
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:skipReviewMapping
                                                                                                      method:RKRequestMethodPOST
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
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id temp = [result objectForKey:@""];
    
    if (tag == MyReviewDetailRequestGet) {
        [_delegate didReceiveReviewListing:((MyReviewReputation*)temp).result];
    } else if (tag == MyReviewDetailRequestSkip) {
        [_delegate didSkipReview:((SkipReview*)temp).result];
    }
}

@end
