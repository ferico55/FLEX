//
//  BannerCollectionReusableView.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerCollectionReusableView : UICollectionReusableView <UIScrollViewDelegate> {
    int numberOfBanners;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
