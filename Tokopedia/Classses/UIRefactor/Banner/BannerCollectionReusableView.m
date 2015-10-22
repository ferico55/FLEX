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
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSDictionary *mainColor = [self mainColoursInImage:image detail:1];
                UIColor *bgColor = [mainColor objectForKey:@"colours"][0];
                [imageView setBackgroundColor:bgColor];
            });
            
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
        [_tickerImage setContentMode:UIViewContentModeScaleAspectFit];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *mainColor = [self mainColoursInImage:image detail:1];
            UIColor *bgColor = [mainColor objectForKey:@"colours"][0];
            [_tickerImage setBackgroundColor:bgColor];
        });
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


-(NSDictionary*)mainColoursInImage:(UIImage *)image detail:(int)detail {
    
    //1. determine detail vars (0==low,1==default,2==high)
    //default detail
    float dimension = 10;
    float flexibility = 2;
    float range = 60;
    
    //low detail
    if (detail==0){
        dimension = 4;
        flexibility = 1;
        range = 100;
        
        //high detail (patience!)
    } else if (detail==2){
        dimension = 100;
        flexibility = 10;
        range = 20;
    }
    
    //2. determine the colours in the image
    NSMutableArray * colours = [NSMutableArray new];
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimension;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
    CGContextRelease(context);
    
    float x = 0;
    float y = 0;
    for (int n = 0; n<(dimension*dimension); n++){
        
        int index = (bytesPerRow * y) + x * bytesPerPixel;
        int red   = rawData[index];
        int green = rawData[index + 1];
        int blue  = rawData[index + 2];
        int alpha = rawData[index + 3];
        NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
        [colours addObject:a];
        
        y++;
        if (y==dimension){
            y=0;
            x++;
        }
    }
    free(rawData);
    
    //3. add some colour flexibility (adds more colours either side of the colours in the image)
    NSArray * copyColours = [NSArray arrayWithArray:colours];
    NSMutableArray * flexibleColours = [NSMutableArray new];
    
    float flexFactor = flexibility * 2 + 1;
    float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
    for (int n = 0; n<(dimension * dimension); n++){
        
        NSArray * pixelColours = copyColours[n];
        NSMutableArray * reds = [NSMutableArray new];
        NSMutableArray * greens = [NSMutableArray new];
        NSMutableArray * blues = [NSMutableArray new];
        
        for (int p = 0; p<3; p++){
            
            NSString * rgbStr = pixelColours[p];
            int rgb = [rgbStr intValue];
            
            for (int f = -flexibility; f<flexibility+1; f++){
                int newRGB = rgb+f;
                if (newRGB<0){
                    newRGB = 0;
                }
                if (p==0){
                    [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==1){
                    [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==2){
                    [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
                }
            }
        }
        
        int r = 0;
        int g = 0;
        int b = 0;
        for (int k = 0; k<factor; k++){
            
            int red = [reds[r] intValue];
            int green = [greens[g] intValue];
            int blue = [blues[b] intValue];
            
            NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
            [flexibleColours addObject:rgbString];
            
            b++;
            if (b==flexFactor){ b=0; g++; }
            if (g==flexFactor){ g=0; r++; }
        }
    }
    
    //4. distinguish the colours
    //orders the flexible colours by their occurrence
    //then keeps them if they are sufficiently disimilar
    
    NSMutableDictionary * colourCounter = [NSMutableDictionary new];
    
    //count the occurences in the array
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
    for (NSString *item in countedSet) {
        NSUInteger count = [countedSet countForObject:item];
        [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
    }
    
    //sort keys highest occurrence to lowest
    NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    //checks if the colour is similar to another one already included
    NSMutableArray * ranges = [NSMutableArray new];
    for (NSString * key in orderedKeys){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        int r = [rgb[0] intValue];
        int g = [rgb[1] intValue];
        int b = [rgb[2] intValue];
        bool exclude = false;
        for (NSString * ranged_key in ranges){
            NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","];
            
            int ranged_r = [ranged_rgb[0] intValue];
            int ranged_g = [ranged_rgb[1] intValue];
            int ranged_b = [ranged_rgb[2] intValue];
            
            if (r>= ranged_r-range && r<= ranged_r+range){
                if (g>= ranged_g-range && g<= ranged_g+range){
                    if (b>= ranged_b-range && b<= ranged_b+range){
                        exclude = true;
                    }
                }
            }
        }
        
        if (!exclude){ [ranges addObject:key]; }
    }
    
    //return ranges array here if you just want the ordered colours high to low
    NSMutableArray * colourArray = [NSMutableArray new];
    for (NSString * key in ranges){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        [colourArray addObject:colour];
    }
    
    //if you just want an array of images of most common to least, return here
    return [NSDictionary dictionaryWithObject:colourArray forKey:@"colours"];
    
    
    //if you want percentages to colours continue below
    NSMutableDictionary * temp = [NSMutableDictionary new];
    float totalCount = 0.0f;
    for (NSString * rangeKey in ranges){
        NSNumber * count = colourCounter[rangeKey];
        totalCount += [count intValue];
        temp[rangeKey]=count;
    }
    
    //set percentages
    NSMutableDictionary * colourDictionary = [NSMutableDictionary new];
    for (NSString * key in temp){
        float count = [temp[key] floatValue];
        float percentage = count/totalCount;
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        colourDictionary[colour]=[NSNumber numberWithFloat:percentage];
    }
    
    return colourDictionary;
}


@end
