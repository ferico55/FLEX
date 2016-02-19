//
//  ImageDownloader.h
//  Tokopedia
//
//  Created by Johanes Effendi on 12/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

//copypasta from UIImageView+AFNetworking
#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)cancelImageRequestOperation;
@end