//
//  ImageDownloader.m
//  Tokopedia
//
//  Created by Johanes Effendi on 12/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ImageDownloader.h"
#import <objc/runtime.h>

@interface ImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

static char kAFImageRequestOperationObjectKey;



@interface ImageDownloader (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
@end

@implementation ImageDownloader (_AFNetworking)
@dynamic af_imageRequestOperation;
@end

@implementation ImageDownloader

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_imageRequestOperationQueue;
}

+ (ImageCache *)af_sharedImageCache {
    static ImageCache *_af_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_imageCache = [[ImageCache alloc] init];
    });
    
    return _af_imageCache;
}

#pragma mark -

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        self.af_imageRequestOperation = nil;
        
        if (success) {
            success(nil, nil, cachedImage);
        }
    } else {
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        
#ifdef _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
        requestOperation.allowsInvalidSSLCertificate = YES;
#endif
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (self.af_imageRequestOperation == operation) {
                    self.af_imageRequestOperation = nil;
                }
                
                if (success) {
                    success(operation.request, operation.response, responseObject);
                }
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (self.af_imageRequestOperation == operation) {
                    self.af_imageRequestOperation = nil;
                }
                
                if (failure) {
                    failure(operation.request, operation.response, error);
                }
            }
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * ImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation ImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [self objectForKey:ImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:ImageCacheKeyFromURLRequest(request)];
    }
}

@end