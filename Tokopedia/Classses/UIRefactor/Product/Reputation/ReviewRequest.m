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
#import "ResponseComment.h"
#import "GeneralAction.h"
#import "Review.h"
#import "NSString+TPBaseUrl.h"

#define ACTION_LIKE_REQUEST 1
#define ACTION_DISLIKE_REQUEST 2
#define ACTION_CANCEL_LIKE_OR_DISLIKE_REQUEST 3

@interface ReviewRequest()

@property (nonatomic, copy) void (^successCompletionBlock)(id completion);
@property (nonatomic, copy) void (^errorCompletionBlock)(id completion);

@end

@implementation ReviewRequest {
    TokopediaNetworkManager *likeDislikeCountNetworkManager;
    TokopediaNetworkManager *actionLikeNetworkManager;
    TokopediaNetworkManager *actionDislikeNetworkManager;
    TokopediaNetworkManager *actionCancelLikeDislikeNetworkManager;
    TokopediaNetworkManager *getInboxReputationNetworkManager;
    TokopediaNetworkManager *getReviewDetailNetworkManager;
    TokopediaNetworkManager *submitReviewNetworkManager;
    TokopediaNetworkManager *uploadReviewImageNetworkManager;
    TokopediaNetworkManager *productReviewSubmitNetworkManager;
    TokopediaNetworkManager *submitReviewWithImageNetworkManager;
    TokopediaNetworkManager *editReviewWithImageNetworkManager;
    TokopediaNetworkManager *skipProductReviewNetworkManager;
    TokopediaNetworkManager *editReputationReviewSubmitNetworkManager;
    TokopediaNetworkManager *insertReputationReviewResponseNetworkManager;
    TokopediaNetworkManager *deleteReputationReviewResponseNetworkManager;
    TokopediaNetworkManager *insertReputationNetworkManager;
    TokopediaNetworkManager *getProductReviewNetworkManager;
    TokopediaNetworkManager *reportReviewNetworkManager;
    
    NSInteger _counter;
    NSDictionary *_imagesToUpload;
    NSString *_postKey;
    NSMutableDictionary *_fileUploaded;
    BOOL _isEdit;
}

- (id)init{
    self = [super init];
    if(self){
        likeDislikeCountNetworkManager = [TokopediaNetworkManager new];
        actionLikeNetworkManager = [TokopediaNetworkManager new];
        actionDislikeNetworkManager = [TokopediaNetworkManager new];
        actionCancelLikeDislikeNetworkManager = [TokopediaNetworkManager new];
        getInboxReputationNetworkManager = [TokopediaNetworkManager new];
        getReviewDetailNetworkManager = [TokopediaNetworkManager new];
        submitReviewNetworkManager = [TokopediaNetworkManager new];
        uploadReviewImageNetworkManager = [TokopediaNetworkManager new];
        productReviewSubmitNetworkManager = [TokopediaNetworkManager new];
        submitReviewWithImageNetworkManager = [TokopediaNetworkManager new];
        editReviewWithImageNetworkManager = [TokopediaNetworkManager new];
        skipProductReviewNetworkManager = [TokopediaNetworkManager new];
        editReputationReviewSubmitNetworkManager = [TokopediaNetworkManager new];
        insertReputationReviewResponseNetworkManager = [TokopediaNetworkManager new];
        deleteReputationReviewResponseNetworkManager = [TokopediaNetworkManager new];
        insertReputationNetworkManager = [TokopediaNetworkManager new];
        getProductReviewNetworkManager = [TokopediaNetworkManager new];
        reportReviewNetworkManager = [TokopediaNetworkManager new];
    }
    return self;
}

#pragma mark - Like Dislike Requests
- (void)requestReviewLikeDislikesWithId:(NSString *)reviewId
                                 shopId:(NSString *)shopId
                              onSuccess:(void (^)(TotalLikeDislike *))successCallback
                              onFailure:(void (^)(NSError *))errorCallback {
    likeDislikeCountNetworkManager.isParameterNotEncrypted = NO;
    likeDislikeCountNetworkManager.isUsingHmac = YES;
    [likeDislikeCountNetworkManager requestWithBaseUrl:[NSString v4Url]
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

- (void)actionLikeWithReviewId:(NSString *)reviewId
                       shopId:(NSString *)shopId
                    productId:(NSString *)productId
                       userId:(NSString *)userId
                    onSuccess:(void (^)(LikeDislikePostResult *))successCallback
                    onFailure:(void (^)(NSError *))errorCallback {
    actionLikeNetworkManager.isParameterNotEncrypted = NO;
    actionLikeNetworkManager.isUsingHmac = YES;
    [actionLikeNetworkManager requestWithBaseUrl:[NSString v4Url]
                                            path:@"/v4/action/review/like_dislike_review.pl"
                                          method:RKRequestMethodPOST
                                       parameter:@{@"product_id"  : productId,
                                                   @"review_id"   : reviewId,
                                                   @"shop_id"     : shopId,
                                                   @"user_id"     : userId,
                                                   @"like_status" : @(ACTION_LIKE_REQUEST)
                                                   }
                                         mapping:[LikeDislikePost mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                           LikeDislikePost *obj = [result objectForKey:@""];
                                           successCallback(obj.data);
                                       } onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
}

- (void)actionDislikeWithReviewId:(NSString *)reviewId
                           shopId:(NSString *)shopId
                        productId:(NSString *)productId
                           userId:(NSString *)userId
                        onSuccess:(void (^)(LikeDislikePostResult *))successCallback
                        onFailure:(void (^)(NSError *))errorCallback{
    
    actionDislikeNetworkManager.isParameterNotEncrypted = NO;
    actionDislikeNetworkManager.isUsingHmac = YES;
    [actionDislikeNetworkManager requestWithBaseUrl:[NSString v4Url]
                                               path:@"/v4/action/review/like_dislike_review.pl"
                                             method:RKRequestMethodPOST
                                          parameter:@{@"product_id"  : productId,
                                                      @"review_id"   : reviewId,
                                                      @"shop_id"     : shopId,
                                                      @"user_id"     : userId,
                                                      @"like_status" : @(ACTION_DISLIKE_REQUEST)
                                                      }
                                            mapping:[LikeDislikePost mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                              LikeDislikePost *obj = [result objectForKey:@""];
                                              successCallback(obj.data);
                                          } onFailure:^(NSError *errorResult) {
                                              errorCallback(errorResult);
                                          }];
}

- (void)actionCancelLikeDislikeWithReviewId:(NSString *)reviewId
                                     shopId:(NSString *)shopId
                                  productId:(NSString *)productId
                                     userId:(NSString *)userId
                                  onSuccess:(void (^)(LikeDislikePostResult *))successCallback
                                  onFailure:(void (^)(NSError *))errorCallback{
    
    actionCancelLikeDislikeNetworkManager.isParameterNotEncrypted = NO;
    actionCancelLikeDislikeNetworkManager.isUsingHmac = YES;
    [actionCancelLikeDislikeNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                         path:@"/v4/action/review/like_dislike_review.pl"
                                                       method:RKRequestMethodPOST
                                                    parameter:@{@"product_id"  : productId,
                                                                @"review_id"   : reviewId,
                                                                @"shop_id"     : shopId,
                                                                @"user_id"     : userId,
                                                                @"like_status" : @(ACTION_CANCEL_LIKE_OR_DISLIKE_REQUEST)
                                                                }
                                                      mapping:[LikeDislikePost mapping]
                                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                        LikeDislikePost *obj = [result objectForKey:@""];
                                                        successCallback(obj.data);
                                                    } onFailure:^(NSError *errorResult) {
                                                        errorCallback(errorResult);
                                                    }];
}

#pragma mark - Inbox Review Requests
- (void)requestGetInboxReputationWithNavigation:(NSString *)navigation
                                           page:(NSNumber *)page
                                         filter:(NSString *)filter
                                        keyword:(NSString *)keyword
                                      onSuccess:(void (^)(InboxReputationResult *))successCallback
                                      onFailure:(void (^)(NSError *))errorCallback {
    getInboxReputationNetworkManager.isParameterNotEncrypted = NO;
    getInboxReputationNetworkManager.isUsingHmac = YES;
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithDictionary:@{@"filter" : filter,
                                                                                       @"nav"    : navigation,
                                                                                       @"page"   : page
                                                                                       }];
    
    if (![keyword isEqualToString:@""]) {
        [parameter setObject:keyword forKey:@"keyword"];
    }
    
    [getInboxReputationNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                    path:@"/v4/inbox-reputation/get_inbox_reputation.pl"
                                                  method:RKRequestMethodGET
                                               parameter:parameter
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
                                     getDataFromMaster:(NSString *)getDataFromMaster
                                                  role:(NSString *)role
                                              autoRead:(NSString *)autoRead
                                             onSuccess:(void (^)(MyReviewReputationResult *))successCallback
                                             onFailure:(void (^)(NSError *))errorCallback {
    
    getReviewDetailNetworkManager.isParameterNotEncrypted = NO;
    getReviewDetailNetworkManager.isUsingHmac = YES;
    
    NSDictionary *parameter = @{@"reputation_id"        : reputationID,
                                @"reputation_inbox_id"  : reputationInboxID,
                                @"n"                    : getDataFromMaster,
                                @"buyer_seller"         : role
                                };
    
    [getReviewDetailNetworkManager requestWithBaseUrl:[NSString v4Url]
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

- (void)requestSubmitReviewWithImageWithReputationID:(NSString *)reputationID
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
    _imagesToUpload = imagesToUpload;
    _counter = 0;
    
    submitReviewWithImageNetworkManager.isParameterNotEncrypted = NO;
    submitReviewWithImageNetworkManager.isUsingHmac = YES;
    
    NSNumber *hasPhoto = hasProductReviewPhoto?@(1):@(0);
    
    NSString *allImageIDs = @"";
    if (photos.count > 0) {
        allImageIDs = [[photos allKeys] componentsJoinedByString:@"~"];
    }
    
    NSString *uploaded = @"";
    
    if (photos) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:photos options:NSJSONWritingPrettyPrinted error:nil];
        uploaded = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        uploaded = [uploaded stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    [submitReviewWithImageNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                       path:@"/v4/action/reputation/insert_reputation_review_validation.pl"
                                                     method:RKRequestMethodPOST
                                                  parameter:@{@"product_id" : productID,
                                                              @"rate_accuracy" : @(accuracyRate),
                                                              @"rate_quality" : @(qualityRate),
                                                              @"reputation_id" : reputationID,
                                                              @"review_message" : reviewMessage,
                                                              @"shop_id" : shopID,
                                                              @"server_id" : serverID,
                                                              @"has_product_review_photo" : hasPhoto,
                                                              @"product_review_photo_all" : allImageIDs?:@"",
                                                              @"product_review_photo_obj" : uploaded?:@""
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
                                                                                   imagesToUpload:[imagesToUpload objectForKey:imageID]
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
                                      data:imagesToUpload
                                   imageID:imageID
                                     token:token
                                 onSuccess:^(ImageResult *result) {
                                     [_fileUploaded setObject:result.pic_obj forKey:imageID];
                                     _counter++;
                                     if (_counter == [[_imagesToUpload allKeys] count]) {
                                         [self requestSubmitReviewWithPostKey:_postKey
                                                                 fileUploaded:_fileUploaded];
                                     }
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     self.errorCompletionBlock(errorResult);
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
    
    RequestObjectUploadImage *requestObject = [RequestObjectUploadImage new];
    requestObject.image_id = imageID;
    requestObject.token = token;
    requestObject.user_id = [[UserAuthentificationManager new] getUserId];
    requestObject.web_service = @"1";
    
    UIImage *image = [imageData objectForKey:@"image"];
    NSString *fileName = [imageData objectForKey:@"name"];
    
    [RequestUploadImage requestUploadImage:image
                            withUploadHost:host
                                      path:@"/upload/attachment"
                                      name:@"fileToUpload"
                                  fileName:fileName
                             requestObject:requestObject
                                 onSuccess:^(ImageResult *imageResult) {
                                     successCallback(imageResult);
                                 }
                                 onFailure:^(NSError *errorResult) {
                                     errorCallback(errorResult);
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
    
    NSString *path = _isEdit?@"/v4/action/reputation/edit_reputation_review_submit.pl":@"/v4/action/reputation/insert_reputation_review_submit.pl";
    
    [productReviewSubmitNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                     path:path
                                                   method:RKRequestMethodPOST
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
    _imagesToUpload = imagesToUpload;
    _counter = 0;
    _isEdit = YES;
    
    editReviewWithImageNetworkManager.isParameterNotEncrypted = NO;
    editReviewWithImageNetworkManager.isUsingHmac = YES;
    
    NSNumber *hasPhoto = hasProductReviewPhoto?@(1):@(0);
    
    NSString *allImageIDs = @"";
    if (photos.count > 0) {
        allImageIDs = [[photos allKeys] componentsJoinedByString:@"~"];
    }
    
    NSString *uploaded = @"";
    if (photos) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:photos options:NSJSONWritingPrettyPrinted error:nil];
        uploaded = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        uploaded = [uploaded stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    [editReviewWithImageNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                     path:@"/v4/action/reputation/edit_reputation_review_validation.pl"
                                                   method:RKRequestMethodPOST
                                                parameter:@{@"product_id" : productID,
                                                            @"rate_accuracy" : @(accuracyRate),
                                                            @"rate_quality" : @(qualityRate),
                                                            @"reputation_id" : reputationID,
                                                            @"review_id" : reviewID,
                                                            @"review_message" : reviewMessage,
                                                            @"shop_id" : shopID,
                                                            @"has_product_review_photo" : hasPhoto,
                                                            @"product_review_photo_all" : allImageIDs?:@"",
                                                            @"product_review_photo_obj" : uploaded?:@"{}"
                                                            }
                                                  mapping:[SubmitReview mapping]
                                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                    SubmitReview *obj = [result objectForKey:@""];
                                                    
                                                    if (obj.data && !obj.message_error) {
                                                        if (hasProductReviewPhoto && ([imagesToUpload count] > 0)) {
                                                            _postKey = obj.data.post_key;
                                                            _fileUploaded = [NSMutableDictionary new];
                                                            for (NSString *imageID in imageIDs) {
                                                                if ([imagesToUpload objectForKey:imageID] != nil) {
                                                                    [self requestUploadImageWithImageID:imageID
                                                                                         imagesToUpload:[imagesToUpload objectForKey:imageID]
                                                                                                  token:token
                                                                                                   host:host];
                                                                    self.successCompletionBlock = successCallback;
                                                                    self.errorCompletionBlock = errorCallback;
                                                                }
                                                            }
                                                        } else if (hasProductReviewPhoto && ([imagesToUpload count] == 0)) {
                                                            [self requestEditReviewSubmitWithPostKey:obj.data.post_key
                                                                                        fileUploaded:@{}];
                                                            self.successCompletionBlock = successCallback;
                                                            self.errorCompletionBlock = errorCallback;
                                                        } else {
                                                            successCallback(obj.data);
                                                        }
                                                    } else {
                                                        [StickyAlertView showErrorMessage:obj.message_error?:@[@"Gagal ubah ulasan."]];
                                                        errorCallback(nil);
                                                    }
                                                    
                                                    
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    errorCallback(errorResult);
                                                }];
}

- (void)requestEditReviewSubmitWithPostKey:(NSString*)postKey
                              fileUploaded:(NSDictionary*)fileUploaded {
    [self requestEditReputationReviewSubmitWithPostKey:postKey
                                          fileUploaded:fileUploaded
                                             onSuccess:^(SubmitReviewResult *result) {
                                                 if ([result.is_success isEqualToString:@"1"]) {
                                                     self.successCompletionBlock(result);
                                                 } else {
                                                     self.errorCompletionBlock(nil);
                                                 }
                                             } onFailure:^(NSError *errorResult) {
                                                 self.errorCompletionBlock(errorResult);
                                             }];
}


- (void)requestEditReputationReviewSubmitWithPostKey:(NSString*)postKey
                                        fileUploaded:(NSDictionary*)fileUploaded
                                           onSuccess:(void (^)(SubmitReviewResult *))successCallback
                                           onFailure:(void (^)(NSError *))errorCallback {
    editReputationReviewSubmitNetworkManager.isParameterNotEncrypted = NO;
    editReputationReviewSubmitNetworkManager.isUsingHmac = YES;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fileUploaded options:NSJSONWritingPrettyPrinted error:nil];
    NSString *uploaded = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    uploaded = [uploaded stringByReplacingOccurrencesOfString:@" " withString:@""];
    uploaded = [uploaded stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [editReputationReviewSubmitNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                            path:@"/v4/action/reputation/edit_reputation_review_submit.pl"
                                                          method:RKRequestMethodPOST
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

- (void)requestSkipProductReviewWithProductID:(NSString *)productID
                                 reputationID:(NSString *)reputationID
                                       shopID:(NSString *)shopID
                                    onSuccess:(void (^)(SkipReviewResult *))successCallback
                                    onFailure:(void (^)(NSError *))errorCallback {
    skipProductReviewNetworkManager.isParameterNotEncrypted = NO;
    skipProductReviewNetworkManager.isUsingHmac = YES;
    
    [skipProductReviewNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                   path:@"/v4/action/reputation/skip_reputation_review.pl"
                                                 method:RKRequestMethodPOST
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

- (void)requestInsertReputationReviewResponseWithReputationID:(NSString *)reputationID
                                              responseMessage:(NSString *)responseMessage
                                                     reviewID:(NSString *)reviewID
                                                       shopID:(NSString *)shopID
                                                    onSuccess:(void (^)(ResponseCommentResult *))successCallback
                                                    onFailure:(void (^)(NSError *))errorCallback {
    insertReputationReviewResponseNetworkManager.isParameterNotEncrypted = NO;
    insertReputationReviewResponseNetworkManager.isUsingHmac = YES;
    
    [insertReputationReviewResponseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                                path:@"/v4/action/reputation/insert_reputation_review_response.pl"
                                                              method:RKRequestMethodPOST
                                                           parameter:@{@"reputation_id" : reputationID,
                                                                       @"response_message" : responseMessage,
                                                                       @"review_id" : reviewID,
                                                                       @"shop_id" : shopID}
                                                             mapping:[ResponseComment mapping]
                                                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                               NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                               ResponseComment *obj = [result objectForKey:@""];
                                                               successCallback(obj.result);
                                                           } onFailure:^(NSError *errorResult) {
                                                               errorCallback(errorResult);
                                                           }];
}

- (void)requestDeleteReputationReviewResponseWithReputationID:(NSString *)reputationID
                                                     reviewID:(NSString *)reviewID
                                                       shopID:(NSString *)shopID
                                                    onSuccess:(void (^)(ResponseCommentResult *))successCallback
                                                    onFailure:(void (^)(NSError *))errorCallback {
    deleteReputationReviewResponseNetworkManager.isParameterNotEncrypted = NO;
    deleteReputationReviewResponseNetworkManager.isUsingHmac = YES;
    
    [deleteReputationReviewResponseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                                path:@"/v4/action/reputation/delete_reputation_review_response.pl"
                                                              method:RKRequestMethodPOST
                                                           parameter:@{@"reputation_id" : reputationID,
                                                                       @"review_id" : reviewID,
                                                                       @"shop_id" : shopID}
                                                             mapping:[ResponseComment mapping]
                                                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                               NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                               ResponseComment *obj = [result objectForKey:@""];
                                                               successCallback(obj.data);
                                                           } onFailure:^(NSError *errorResult) {
                                                               errorCallback(errorResult);
                                                           }];
}

- (void)requestInsertReputationWithReputationID:(NSString *)reputationID
                                           role:(NSString *)role
                                          score:(NSString *)score
                                      onSuccess:(void (^)(GeneralActionResult *))successCallback
                                      onFailure:(void (^)(NSError *))errorCallback {
    insertReputationNetworkManager.isParameterNotEncrypted = NO;
    insertReputationNetworkManager.isUsingHmac = YES;
    
    [insertReputationNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                  path:@"/v4/action/reputation/insert_reputation.pl"
                                                method:RKRequestMethodPOST
                                             parameter:@{@"buyer_seller"     : role,
                                                         @"reputation_id"    : reputationID,
                                                         @"reputation_score" : score}
                                               mapping:[GeneralAction mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 GeneralAction *obj = [result objectForKey:@""];
                                                 successCallback(obj.data);
                                             } onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

- (void)requestReportReviewWithReviewID:(NSString *)reviewID
                                 shopID:(NSString *)shopID
                            textMessage:(NSString *)textMessage
                              onSuccess:(void (^)(GeneralAction *))successCallback
                              onFailure:(void (^)(NSError *))errorCallback {
    reportReviewNetworkManager.isParameterNotEncrypted = NO;
    reportReviewNetworkManager.isUsingHmac = YES;
    
    [reportReviewNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/action/review/report_review.pl"
                                            method:RKRequestMethodPOST
                                         parameter:@{@"review_id" : reviewID,
                                                     @"shop_id" : shopID,
                                                     @"text_message" : textMessage}
                                           mapping:[GeneralAction mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                             GeneralAction *obj = [result objectForKey:@""];
                                             successCallback(obj);
                                             
                                         }
                                         onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
}

#pragma mark - Product Review Requests

- (void)requestGetProductReviewWithProductID:(NSString *)productID
                                  monthRange:(NSNumber *)monthRange
                                        page:(NSNumber *)page
                                shopAccuracy:(NSNumber *)shopAccuracy
                                 shopQuality:(NSNumber *)shopQuality
                                  shopDomain:(NSString *)shopDomain
                                   onSuccess:(void (^)(ReviewResult *))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback {
    getProductReviewNetworkManager.isParameterNotEncrypted = NO;
    getProductReviewNetworkManager.isUsingHmac = YES;
    
    [getProductReviewNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                  path:@"/v4/product/get_product_review.pl"
                                                method:RKRequestMethodGET
                                             parameter:@{@"product_id" : productID,
                                                         @"page" : page,
                                                         @"shop_domain" : shopDomain,
                                                         @"shop_quality" : shopQuality,
                                                         @"shop_accuracy" : shopAccuracy,
                                                         @"month_range" : monthRange}
                                               mapping:[Review mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 Review *obj = [result objectForKey:@""];
                                                 successCallback(obj.data);
                                             } onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

- (int)requestGetProductReviewNextPageFromUri:(NSString*)uri {
    return [[getProductReviewNetworkManager splitUriToPage:uri] intValue];
}

@end
