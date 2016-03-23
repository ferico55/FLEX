//
//  MyReviewDetailHeader.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailHeader.h"
#import "AFNetworkingImageDownloader.h"
#import "MyReviewDetailHeaderComponent.h"
#import <ComponentKit/ComponentKit.h>


@implementation MyReviewDetailContext

@end

@implementation MyReviewDetailHeader {
    __weak id<MyReviewDetailHeaderDelegate> _delegate;
    DetailMyInboxReputation *_inbox;
}

- (instancetype)initWithInboxDetail:(DetailMyInboxReputation *)inbox imageCache:(ImageStorage*)imageCache delegate:(id<MyReviewDetailHeaderDelegate>)delegate smileyDelegate:(id<MyReviewDetailHeaderSmileyDelegate>)smileyDelegate {
    CKComponentFlexibleSizeRangeProvider* provider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    if (self = [super initWithComponentProvider:[MyReviewDetailHeader class] sizeRangeProvider:provider]) {
        
        MyReviewDetailContext* context = [MyReviewDetailContext new];
        context.imageDownloader = [AFNetworkingImageDownloader new];
        context.delegate = delegate;
        context.smileyDelegate = smileyDelegate;
        context.imageCache = imageCache;
        
        [self updateModel:inbox mode:CKUpdateModeSynchronous];
        [self updateContext:context mode:CKUpdateModeSynchronous];
    }
    
    return self;
}

+ (CKComponent*)componentForModel:(DetailMyInboxReputation*)model context:(MyReviewDetailContext*)context {
    return [MyReviewDetailHeaderComponent newWithInbox:model context:context];
}


@end
