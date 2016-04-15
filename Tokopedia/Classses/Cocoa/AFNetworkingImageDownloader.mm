//
//  AFNetworkingImageDownloader.m
//  Tokopedia
//
//  Created by Johanes Effendi on 12/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "AFNetworkingImageDownloader.h"
#import <ComponentKit/ComponentKit.h>
#import "ImageDownloader.h"

@interface AFNetworkingImageDownloader() <CKNetworkImageDownloading>

@end

@implementation AFNetworkingImageDownloader
- (id)downloadImageWithURL:(NSURL *)URL
                 scenePath:(id)scenePath
                    caller:(id)caller
             callbackQueue:(dispatch_queue_t)callbackQueue
     downloadProgressBlock:(void (^)(CGFloat progress))downloadProgressBlock
                completion:(void (^)(CGImageRef image, NSError *error))completion {
    
    ImageDownloader* downloader = [ImageDownloader new];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [downloader setImageWithURLRequest:request
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   completion(image.CGImage, nil);
                               } failure:nil];
    
    return downloader;
}

- (void)cancelImageDownload:(ImageDownloader*)downloader {
    [downloader cancelImageRequestOperation];
}
@end