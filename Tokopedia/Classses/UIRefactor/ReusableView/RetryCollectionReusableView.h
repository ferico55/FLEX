//
//  RetryCollectionReusableView.h
//  Tokopedia
//
//  Created by Tonito Acen on 5/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewDelegate <NSObject>
- (void)pressRetryButton;
@end

@interface RetryCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) id<LoadingViewDelegate> delegate;

@end
