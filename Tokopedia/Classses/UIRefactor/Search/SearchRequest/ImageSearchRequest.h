//
//  ImageSearchRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageSearchResponse.h"

@protocol ImageSearchRequestDelegate <NSObject>
//-(void)didReceiveImageSearchResult:(ImageSearchResponse*)imageSearchResponse;
-(void)didReceiveUploadedImageURL:(NSString*) imageURL;

@optional
-(void)failToReceiveImageSearchResult:(NSString*)errorMessage;

@end

@interface ImageSearchRequest : NSObject

@property (weak, nonatomic) id<ImageSearchRequestDelegate> delegate;
@property (weak, nonatomic) UIView *view;

- (void)requestSearchbyImage:(NSDictionary*)imageInfo;
@end
