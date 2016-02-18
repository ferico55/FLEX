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
    TokopediaNetworkManager *networkManager;
    __weak RKObjectManager *objectManager;
    
    NSString* likeDislikes_reviewId;
    NSString* likeDislikes_shopId;
}

- (id)init{
    self = [super init];
    if(self){
        networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
        networkManager.isParameterNotEncrypted = NO;
        networkManager.isUsingHmac = NO;
    }
    return self;
}

#pragma mark - Public Function
-(void)requestReviewLikeDislikesWithId:(NSString*)reviewId shopId:(NSString*)shopId{
    likeDislikes_reviewId = reviewId;
    likeDislikes_shopId = shopId;
    networkManager.tagRequest = ReviewRequestLikeDislike;
    [networkManager doRequest];
}

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag{
    if(tag == ReviewRequestLikeDislike){
        NSDictionary *param = @{@"action" : @"get_like_dislike_review_shop",
                                @"review_ids" : likeDislikes_reviewId,
                                @"shop_id" : likeDislikes_shopId};
        return param;
    }
    return nil;
}
- (NSString*)getPath:(int)tag{
    if(tag == ReviewRequestLikeDislike){
        return @"shop.pl";
    }
    return nil;
}

- (int)getRequestMethod:(int)tag{
    return RKRequestMethodPOST;
}

- (id)getObjectManager:(int)tag{
    if(tag == ReviewRequestLikeDislike){
        objectManager =  [RKObjectManager sharedClient];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LikeDislike mapping]
                                                                                                method:RKRequestMethodPOST
                                                                                           pathPattern:[self getPath:ReviewRequestLikeDislike]
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptor];
        return objectManager;

    }
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    if(tag == ReviewRequestLikeDislike){
        return ((LikeDislike*)stat).status;
    }
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    if(tag == ReviewRequestLikeDislike){
        LikeDislike *obj = [result objectForKey:@""];
        [_delegate didReceiveReviewLikeDislikes:(TotalLikeDislike *) [obj.result.like_dislike_review firstObject]];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
}
@end
