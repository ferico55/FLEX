//
//  ReviewRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewRequest.h"
#import "TokopediaNetworkManager.h"
#import "LikeDislike.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "TotalLikeDislikePost.h"
#import "TotalLikeDislike.h"

typedef NS_ENUM(NSInteger, ReviewRequestType){
    ReviewRequestLikeDislike
};

@interface ReviewRequest()<TokopediaNetworkManagerDelegate>
@end

@implementation ReviewRequest{
    TokopediaNetworkManager *likeDislikeCountNetworkManager;
    TokopediaNetworkManager *actionLikeDislikeNetworkManager;
}

- (id)init{
    self = [super init];
    if(self){
        likeDislikeCountNetworkManager = [TokopediaNetworkManager new];
        actionLikeDislikeNetworkManager = [TokopediaNetworkManager new];
    }
    return self;
}

#pragma mark - Public Function
-(void)requestReviewLikeDislikesWithId:(NSString *)reviewId shopId:(NSString *)shopId onSuccess:(void (^)(TotalLikeDislike *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    likeDislikeCountNetworkManager.isParameterNotEncrypted = NO;
    likeDislikeCountNetworkManager.isUsingHmac = YES;
    [likeDislikeCountNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                                  path:@"/v4/product/get_like_dislike_review.pl"
                                                method:RKRequestMethodGET
                                             parameter:@{@"review_ids" : reviewId,
                                                         @"shop_id" : shopId}
                                               mapping:[LikeDislike mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 LikeDislike *obj = [result objectForKey:@""];
                                                 successCallback((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]);
                                             } onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

-(void)actionLikeWithReviewId:(NSString *)reviewId shopId:(NSString *)shopId productId:(NSString *)productId userId:(NSString *)userId onSuccess:(void (^)(TotalLikeDislikePost *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    actionLikeDislikeNetworkManager.isParameterNotEncrypted = NO;
    actionLikeDislikeNetworkManager.isUsingHmac = YES;
    [actionLikeDislikeNetworkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                                  path:@"/v4/action/review/like_dislike_review.pl"
                                                method:RKRequestMethodGET
                                             parameter:@{@"product_id"  : productId,
                                                         @"review_id"   : reviewId,
                                                         @"shop_id"     : shopId,
                                                         @"user_id"     : userId,
                                                         @"like_status" : @(1)
                                                         }
                                               mapping:[LikeDislikePost mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 LikeDislikePost *obj = [result objectForKey:@""];
                                                 successCallback(obj.result.content);
                                             } onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}


@end
