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
#import "InboxReputation.h"
#import "MyReviewReputation.h"
#import "SubmitReview.h"
#import "NSMutableURLRequest+TKPDURLRequestUploadImage.h"
#import "RequestUploadImage.h"
#import "RequestObject.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "SkipReview.h"

typedef NS_ENUM(NSInteger, ReviewRequestType){
    ReviewRequestLikeDislike
};

@interface ReviewRequest()

@property (nonatomic, copy) void (^successCompletionBlock)(id completion);
@property (nonatomic, copy) void (^errorCompletionBlock)(id completion);

@end

@implementation ReviewRequest {
    TokopediaNetworkManager *likeDislikeCountNetworkManager;
    TokopediaNetworkManager *getInboxReputationNetworkManager;
    TokopediaNetworkManager *getReviewDetailNetworkManager;
    TokopediaNetworkManager *submitReviewNetworkManager;
    TokopediaNetworkManager *uploadReviewImageNetworkManager;
    TokopediaNetworkManager *productReviewSubmitNetworkManager;
    TokopediaNetworkManager *submitReviewWithImageNetworkManager;
    TokopediaNetworkManager *editReviewWithImageNetworkManager;
    TokopediaNetworkManager *skipProductReviewNetworkManager;
    
    NSInteger _counter;
    NSArray *_imageIDs;
    NSString *_postKey;
    NSMutableDictionary *_fileUploaded;
}

- (id)init{
    self = [super init];
    if(self){
        likeDislikeCountNetworkManager = [TokopediaNetworkManager new];
        getInboxReputationNetworkManager = [TokopediaNetworkManager new];
        getReviewDetailNetworkManager = [TokopediaNetworkManager new];
        submitReviewNetworkManager = [TokopediaNetworkManager new];
        uploadReviewImageNetworkManager = [TokopediaNetworkManager new];
        productReviewSubmitNetworkManager = [TokopediaNetworkManager new];
        submitReviewWithImageNetworkManager = [TokopediaNetworkManager new];
        editReviewWithImageNetworkManager = [TokopediaNetworkManager new];
        skipProductReviewNetworkManager = [TokopediaNetworkManager new];
    }
    return self;
}

#pragma mark - Public Function
- (void)requestReviewLikeDislikesWithId:(NSString *)reviewId
                                 shopId:(NSString *)shopId
                              onSuccess:(void (^)(TotalLikeDislike *))successCallback
                              onFailure:(void (^)(NSError *))errorCallback {
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
                                             }
                                             onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

- (void)requestGetInboxReputationWithNavigation:(NSString *)navigation
                                           page:(NSNumber *)page
                                         filter:(NSString *)filter
                                      onSuccess:(void (^)(InboxReputationResult *))successCallback
                                      onFailure:(void (^)(NSError *))errorCallback {
    getInboxReputationNetworkManager.isParameterNotEncrypted = NO;
    getInboxReputationNetworkManager.isUsingHmac = YES;
    
    [getInboxReputationNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                    path:@"/v4/inbox-reputation/get_inbox_reputation.pl"
                                                  method:RKRequestMethodGET
                                               parameter:@{@"filter" : filter,
                                                           @"nav"    : navigation,
                                                           @"page"   : page
                                                           }
                                                 mapping:[InboxReputation mapping]
                                               onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                   NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                   InboxReputation *obj = [result objectForKey:@""];
                                                   successCallback(obj.data);
                                               }
                                               onFailure:^(NSError *errorResult) {
                                                   errorCallback(errorResult);
                                               }];
    
}

- (int)getNextPageFromUri:(NSString *)uri {
    return [[getInboxReputationNetworkManager splitUriToPage:uri] intValue];
}

- (void)requestGetListReputationReviewWithReputationID:(NSString *)reputationID
                                     reputationInboxID:(NSString *)reputationInboxID
                                          isUsingRedis:(NSString *)isUsingRedis
                                                  role:(NSString *)role
                                              autoRead:(NSString *)autoRead
                                             onSuccess:(void (^)(MyReviewReputationResult *))successCallback
                                             onFailure:(void (^)(NSError *))errorCallback {
    
    getReviewDetailNetworkManager.isParameterNotEncrypted = NO;
    getReviewDetailNetworkManager.isUsingHmac = YES;
    
    NSDictionary *parameter = @{@"reputation_id"        : reputationID,
                                @"reputation_inbox_id"  : reputationInboxID,
                                @"n"                    : isUsingRedis,
                                @"buyer_seller"         : role
                                };
    
    [getReviewDetailNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                 path:@"/v4/inbox-reputation/get_list_reputation_review.pl"
                                               method:RKRequestMethodGET
                                            parameter:parameter
                                              mapping:[MyReviewReputation mapping]
                                            onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                MyReviewReputation *obj = [result objectForKey:@""];
                                                successCallback(obj.data);
                                            }
                                            onFailure:^(NSError *errorResult) {
                                                errorCallback(errorResult);
                                            }];
}

- (void)requestReviewValidationWithReputationID:(NSString *)reputationID
                                      productID:(NSString *)productID
                                   accuracyRate:(int)accuracyRate
                                    qualityRate:(int)qualityRate
                                        message:(NSString *)reviewMessage
                                         shopID:(NSString *)shopID
                                       serverID:(NSString *)serverID
                          hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                 reviewPhotoIDs:(NSArray *)imageIDs
                             reviewPhotoObjects:(NSDictionary *)photos
                                      onSuccess:(void (^)(SubmitReviewResult *))successCallback
                                      onFailure:(void (^)(NSError *))errorCallback {
    
    submitReviewNetworkManager.isParameterNotEncrypted = NO;
    submitReviewNetworkManager.isUsingHmac = YES;
    
    NSNumber *hasPhoto = hasProductReviewPhoto?@(1):@(0);
    NSString *allImageIDs = [imageIDs componentsJoinedByString:@"~"];
    
    [submitReviewNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                              path:@"/v4/action/review/add_product_review_validation.pl"
                                            method:RKRequestMethodGET
                                         parameter:@{@"product_id" : productID,
                                                     @"rate_accuracy" : @(accuracyRate),
                                                     @"rate_product" : @(qualityRate),
                                                     @"reputation_id" : reputationID,
                                                     @"review_message" : reviewMessage,
                                                     @"shop_id" : shopID,
                                                     @"server_id" : serverID,
                                                     @"has_product_review_photo" : hasPhoto,
                                                     @"product_review_photo_all" : allImageIDs?:@"",
                                                     @"product_review_photo_obj" : photos?:@{}
                                                     }
                                           mapping:[SubmitReview mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                             SubmitReview *obj = [result objectForKey:@""];
                                             successCallback(obj.data);
                                         }
                                         onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
    
}

- (void)requestUploadReviewImageWithHost:(NSString*)host
                                    data:(id)imageData
                                 imageID:(NSString *)imageID
                                   token:(NSString *)token
                               onSuccess:(void (^)(ImageResult *))successCallback
                               onFailure:(void (^)(NSError *))errorCallback {
    uploadReviewImageNetworkManager.isParameterNotEncrypted = NO;
    uploadReviewImageNetworkManager.isUsingHmac = YES;
    
    UIImage *image = [imageData objectForKey:@"photo"];
    NSString *fileName = [imageData objectForKey:@"cameraimagename"];
    NSString *name = @"fileToUpload";
    
    RequestObjectUploadReviewImage *requestObject = [RequestObjectUploadReviewImage new];
    requestObject.image_id = imageID;
    requestObject.token = token;
    requestObject.user_id = [[UserAuthentificationManager new] getUserId];
    
    [RequestUploadImage requestUploadImage:image
                            withUploadHost:host
                                      path:@"/upload/attachment"
                                      name:name
                                  fileName:fileName
                             requestObject:requestObject
                                 onSuccess:^(ImageResult *imageResult) {
                                     successCallback(imageResult);
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     errorCallback(errorResult);
                                 }];
}

- (void)requestProductReviewSubmitWithPostKey:(NSString *)postKey
                                 fileUploaded:(NSDictionary *)fileUploaded
                                    onSuccess:(void (^)(SubmitReviewResult *))successCallback
                                    onFailure:(void (^)(NSError *))errorCallback {
    productReviewSubmitNetworkManager.isParameterNotEncrypted = NO;
    productReviewSubmitNetworkManager.isUsingHmac = YES;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fileUploaded options:NSJSONWritingPrettyPrinted error:nil];
    NSString *uploaded = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@" " withString:@""];
    uploaded = [uploaded stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [productReviewSubmitNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                     path:@"/v4/action/review/add_product_review_submit.pl"
                                                   method:RKRequestMethodGET
                                                parameter:@{@"post_key" : postKey?:@"",
                                                            @"file_uploaded" : uploaded?:@""}
                                                  mapping:[SubmitReview mapping]
                                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                    SubmitReview *obj = [result objectForKey:@""];
                                                    
                                                    if ([obj.data.is_success isEqualToString:@"1"]) {
                                                        successCallback(obj.data);
                                                    } else {
                                                        [StickyAlertView showErrorMessage:obj.message_error];
                                                    }
                                                    
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    errorCallback(errorResult);
                                                }];
}

-(void)requestSubmitReviewWithImageWithReputationID:(NSString *)reputationID
                                          productID:(NSString *)productID
                                       accuracyRate:(int)accuracyRate
                                        qualityRate:(int)qualityRate
                                            message:(NSString *)reviewMessage
                                             shopID:(NSString *)shopID
                                           serverID:(NSString *)serverID
                              hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                     reviewPhotoIDs:(NSArray *)imageIDs
                                 reviewPhotoObjects:(NSDictionary *)photos
                                     imagesToUpload:(NSDictionary *)imagesToUpload
                                              token:(NSString*)token
                                               host:(NSString*)host
                                          onSuccess:(void (^)(SubmitReviewResult *))successCallback
                                          onFailure:(void (^)(NSError *))errorCallback {
    _imageIDs = imageIDs;
    _counter = 0;
    
    submitReviewWithImageNetworkManager.isParameterNotEncrypted = NO;
    submitReviewWithImageNetworkManager.isUsingHmac = YES;
    
    NSNumber *hasPhoto = hasProductReviewPhoto?@(1):@(0);
    NSString *allImageIDs = [imageIDs componentsJoinedByString:@"~"];
    
    
    [submitReviewWithImageNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                       path:@"/v4/action/review/add_product_review_validation.pl"
                                                     method:RKRequestMethodGET
                                                  parameter:@{@"product_id" : productID,
                                                              @"rate_accuracy" : @(accuracyRate),
                                                              @"rate_product" : @(qualityRate),
                                                              @"reputation_id" : reputationID,
                                                              @"review_message" : reviewMessage,
                                                              @"shop_id" : shopID,
                                                              @"server_id" : serverID,
                                                              @"has_product_review_photo" : hasPhoto,
                                                              @"product_review_photo_all" : allImageIDs?:@"",
                                                              @"product_review_photo_obj" : photos?:@{}
                                                              }
                                                    mapping:[SubmitReview mapping]
                                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                      NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                      SubmitReview *obj = [result objectForKey:@""];
                                                      
                                                      if (hasProductReviewPhoto) {
                                                          _postKey = obj.data.post_key;
                                                          _fileUploaded = [NSMutableDictionary new];
                                                          for (NSString *imageID in imageIDs) {
                                                              [self requestUploadImageWithImageID:imageID
                                                                                   imagesToUpload:imagesToUpload
                                                                                            token:token
                                                                                             host:host];
                                                              self.successCompletionBlock = successCallback;
                                                              self.errorCompletionBlock = errorCallback;
                                                          }
                                                      } else {
                                                          successCallback(obj.data);
                                                      }
                                                      
                                                  }
                                                  onFailure:^(NSError *errorResult) {
                                                      errorCallback(errorResult);
                                                  }];
}

- (void)requestUploadImageWithImageID:(NSString*)imageID
                       imagesToUpload:(NSDictionary*)imagesToUpload
                                token:(NSString*)token
                                 host:(NSString*)host {
    [self requestUploadReviewImageWithHost:[NSString stringWithFormat:@"https://%@",host]
                                      data:[imagesToUpload objectForKey:imageID]
                                   imageID:imageID
                                     token:token
                                 onSuccess:^(ImageResult *result) {
                                     [_fileUploaded setObject:result.pic_obj forKey:imageID];
                                     _counter++;
                                     if (_counter == [_imageIDs count]) {
                                         [self requestSubmitReviewWithPostKey:_postKey
                                                                 fileUploaded:_fileUploaded];
                                     }
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     self.errorCompletionBlock(errorResult);
                                 }];
    
}

- (void)requestSubmitReviewWithPostKey:(NSString*)postKey
                          fileUploaded:(NSDictionary*)fileUploaded {
    [self requestProductReviewSubmitWithPostKey:postKey
                                   fileUploaded:fileUploaded
                                      onSuccess:^(SubmitReviewResult *result) {
                                          if ([result.is_success isEqualToString:@"1"]) {
                                              self.successCompletionBlock(result);
                                          } else {
                                              self.errorCompletionBlock(nil);
                                          }
                                      }
                                      onFailure:^(NSError *errorResult) {
                                          self.errorCompletionBlock(errorResult);
                                      }];
}

- (void)requestEditReviewWithImageWithReviewID:(NSString *)reviewID
                                     productID:(NSString *)productID
                                  accuracyRate:(int)accuracyRate
                                   qualityRate:(int)qualityRate
                                  reputationID:(NSString *)reputationID
                                       message:(NSString *)reviewMessage
                                        shopID:(NSString *)shopID
                         hasProductReviewPhoto:(BOOL)hasProductReviewPhoto
                                reviewPhotoIDs:(NSArray *)imageIDs
                            reviewPhotoObjects:(NSDictionary *)photos
                                imagesToUpload:(NSDictionary *)imagesToUpload
                                         token:(NSString *)token
                                          host:(NSString *)host
                                     onSuccess:(void (^)(SubmitReviewResult *))successCallback
                                     onFailure:(void (^)(NSError *))errorCallback {
    _imageIDs = imageIDs;
    _counter = 0;
    
    editReviewWithImageNetworkManager.isParameterNotEncrypted = NO;
    editReviewWithImageNetworkManager.isUsingHmac = YES;
    
    NSNumber *hasPhoto = hasProductReviewPhoto?@(1):@(0);
    NSString *allImageIDs = [imageIDs componentsJoinedByString:@"~"];
    
    [editReviewWithImageNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                     path:@"/v4/action/review/edit_product_review_validation.pl"
                                                   method:RKRequestMethodGET
                                                parameter:@{@"product_id" : productID,
                                                            @"rate_accuracy" : @(accuracyRate),
                                                            @"rate_product" : @(qualityRate),
                                                            @"reputation_id" : reputationID,
                                                            @"review_id" : reviewID,
                                                            @"review_message" : reviewMessage,
                                                            @"shop_id" : shopID,
                                                            @"has_product_review_photo" : hasPhoto,
                                                            @"product_review_photo_all" : allImageIDs,
                                                            @"product_review_photo_obj" : photos?:@{}
                                                            }
                                                  mapping:[SubmitReview mapping]
                                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                    SubmitReview *obj = [result objectForKey:@""];
                                                    
                                                    if (hasProductReviewPhoto) {
                                                        _postKey = obj.data.post_key;
                                                        _fileUploaded = [NSMutableDictionary new];
                                                        for (NSString *imageID in imageIDs) {
                                                            [self requestUploadImageWithImageID:imageID
                                                                                 imagesToUpload:imagesToUpload
                                                                                          token:token
                                                                                           host:host];
                                                            self.successCompletionBlock = successCallback;
                                                            self.errorCompletionBlock = errorCallback;
                                                        }
                                                    } else {
                                                        successCallback(obj.data);
                                                    }
                                                    
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    errorCallback(errorResult);
                                                }];
}

- (void)requestSkipProductReviewWithProductID:(NSString *)productID
                                 reputationID:(NSString *)reputationID
                                       shopID:(NSString *)shopID
                                    onSuccess:(void (^)(SkipReviewResult *))successCallback
                                    onFailure:(void (^)(NSError *))errorCallback {
    skipProductReviewNetworkManager.isParameterNotEncrypted = NO;
    skipProductReviewNetworkManager.isUsingHmac = YES;
    
    [skipProductReviewNetworkManager requestWithBaseUrl:@"https://ws-alpha.tokopedia.com"
                                                   path:@"/v4/action/review/skip_product_review.pl"
                                                 method:RKRequestMethodGET
                                              parameter:@{@"product_id" : productID,
                                                          @"reputation_id" : reputationID,
                                                          @"shop_id" : shopID}
                                                mapping:[SkipReview mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                  NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                  SkipReview *obj = [result objectForKey:@""];
                                                  successCallback(obj.data);
                                              }
                                              onFailure:^(NSError *errorResult) {
                                                  errorCallback(errorResult);
                                              }];
}

@end
