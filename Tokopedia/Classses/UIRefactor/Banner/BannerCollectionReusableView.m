//
//  BannerCollectionReusableView.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BannerCollectionReusableView.h"
#import "WebViewController.h"

@implementation BannerCollectionReusableView

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBanners:) name:@"TKPDidReceiveBanners" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollTimerBased) userInfo:nil repeats:YES];
    _scrollView.hidden = YES;
}


#pragma mark - Delegate ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _scrollView.bounds.size.width;
    _pageControl.currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (IBAction)changePage:(id)sender {
    UIPageControl *pager = sender;
    NSInteger page = pager.currentPage;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _scrollView.contentOffset = CGPointMake(page * _scrollView.frame.size.width, 0);
    } completion:nil];
}

- (void)scrollTimerBased {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if(_scrollView.contentOffset.x < _scrollView.frame.size.width * (numberOfBanners - 1)) {
            CGFloat nextPositionX = _scrollView.contentOffset.x;
            nextPositionX += _scrollView.frame.size.width;
            _scrollView.contentOffset = CGPointMake(nextPositionX, 0);
        } else {
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    } completion:nil];
    
}

#pragma mark - Notification Observer
- (void)didReceiveBanners:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    _banners = [userInfo objectForKey:@"banners"];
    
    [self setTicker:_banners.result.ticker.img_uri];
    
    numberOfBanners = _banners.result.banner.count;
    _scrollView.hidden = NO;
    
    CGFloat positionX = 0;
    for(int i=0;i<numberOfBanners;i++) {
        BannerList *list = _banners.result.banner[i];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setContentMode:UIViewContentModeCenter];
        
        NSURLRequest* requestImage = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.img_uri]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        [imageView setImageWithURLRequest:requestImage placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [imageView setImage:image];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setAutoresizingMask:( UIViewAutoresizingFlexibleBottomMargin
                                           | UIViewAutoresizingFlexibleHeight
                                           | UIViewAutoresizingFlexibleLeftMargin
                                           | UIViewAutoresizingFlexibleRightMargin
                                           | UIViewAutoresizingFlexibleTopMargin
                                           | UIViewAutoresizingFlexibleWidth )];
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//                NSDictionary *mainColor = [self mainColoursInImage:image detail:1];
//                UIColor *bgColor = [mainColor objectForKey:@"colours"][0];
//                [imageView setBackgroundColor:bgColor];
//            });
            
#pragma clang diagnostic pop
        } failure:nil];
        
        CGRect frame = imageView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        frame.size.height = _scrollView.frame.size.height;
        frame.origin.y = 0;
        frame.origin.x = positionX;
        [imageView setFrame:frame];
        
        positionX += imageView.frame.size.width;
        [_scrollView addSubview:imageView];
        
    }
    
    CGSize scrollSize = CGSizeMake(positionX, _scrollView.frame.size.height);
    
    [_scrollView setDelegate:self];
    [_scrollView setContentSize:scrollSize];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setBounces:NO];
    [_scrollView setCanCancelContentTouches:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner)];
    [_scrollView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapTickerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTicker)];
    [_tickerImage addGestureRecognizer:tapTickerGesture];
    [_tickerImage setUserInteractionEnabled:YES];
    
    [_pageControl setNumberOfPages:numberOfBanners];
    [_pageControl setCurrentPage:0];
    [_scrollView addSubview:_pageControl];
}

- (void)setTicker:(NSString*)imageUrl {
    if([imageUrl isEqualToString:@""]) {
        return;
    }
    [_tickerImage setContentMode:UIViewContentModeCenter];
    
    NSURLRequest* requestImage = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageUrl]
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_tickerImage setImageWithURLRequest:requestImage placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [_tickerImage setImage:image];
        [_tickerImage setContentMode:UIViewContentModeScaleAspectFill];
        [_tickerImage setAutoresizingMask:( UIViewAutoresizingFlexibleBottomMargin
                                        | UIViewAutoresizingFlexibleHeight
                                        | UIViewAutoresizingFlexibleLeftMargin
                                        | UIViewAutoresizingFlexibleRightMargin
                                        | UIViewAutoresizingFlexibleTopMargin
                                        | UIViewAutoresizingFlexibleWidth )];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            NSDictionary *mainColor = [self mainColoursInImage:image detail:1];
//            UIColor *bgColor = [mainColor objectForKey:@"colours"][0];
//            [_tickerImage setBackgroundColor:bgColor];
//        });
#pragma clang diagnostic pop
    } failure:nil];
}

- (void)tapBanner {
    NSInteger page = _pageControl.currentPage;
    BannerList *banner = _banners.result.banner[page];
    
    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Promo";
    webViewController.strURL = banner.url;
    
    if(_delegate != nil) {
        [((UIViewController*)_delegate).navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)tapTicker {
    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Promo";
    webViewController.strURL = _banners.result.ticker.url;
    
    if(_delegate != nil) {
        [((UIViewController*)_delegate).navigationController pushViewController:webViewController animated:YES];
    }
}


@end
