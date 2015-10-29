//
//  BannerCollectionReusableView.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Banner.h"

@protocol BannerDelegate <NSObject>

- (void)didReceiveBanner:(Banner *)banner;

@end

@interface BannerCollectionReusableView : UICollectionReusableView <UIScrollViewDelegate> {
    NSInteger numberOfBanners;
    Banner *_banners;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *tickerImage;

@property (weak, nonatomic) id<BannerDelegate> delegate;


@end
