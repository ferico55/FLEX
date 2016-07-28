//
//  QueueImageDownloader.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueImageDownloader : NSObject
@property (strong, nonatomic) NSMutableArray<UIImageView*>* imageViews;

-(void)downloadImagesWithUrls:(NSArray<NSString*>*)urls
                  onComplete:(void (^)(NSArray<UIImage*>*images))successCallback;
                                 
-(void)cancelAllOperations;
@end
