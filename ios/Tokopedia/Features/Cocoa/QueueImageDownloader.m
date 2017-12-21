//
//  QueueImageDownloader.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "QueueImageDownloader.h"

@implementation QueueImageDownloader{
    NSInteger totalSuccess;
    NSInteger totalFail;
}
-(void)downloadImagesWithUrls:(NSArray<NSString *> *)urls onComplete:(void (^)(NSArray<UIImage *> *))successCallback{
    NSMutableArray *result = [NSMutableArray new];
    totalSuccess = 0;
    totalFail = 0;
    
    if(_imageViews == nil){
        _imageViews = [NSMutableArray new];
    }
    for(NSString* url in urls){
        NSURL *nsurl = [NSURL URLWithString:url];
        UIImageView *imageView = [UIImageView new];
        [_imageViews addObject:imageView];
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:nsurl]
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      if (!image) return;
                                      [result addObject:image];
                                      totalSuccess += 1;
                                      
                                      if(totalSuccess + totalFail == [urls count]){
                                          successCallback(result);
                                      }
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      totalFail += 1;
                                  }];
    }
}

-(void)cancelAllOperations{
    for(UIImageView *imageView in _imageViews){
        [imageView cancelImageRequestOperation];
    }
}
@end
