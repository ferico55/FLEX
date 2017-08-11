//
//  NoResult.h
//  Tokopedia
//
//  Created by Tokopedia on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewDelegate <NSObject>
- (void)pressRetryButton;
@end

@interface LoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIButton *buttonRetry;

@property (weak, nonatomic) id<LoadingViewDelegate> delegate;


- (void)setNoResultText:(NSString*)string;

@end
