//
//  TKPDTabHomeViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabHomeViewController.h"
#import "HotlistViewController.h"
#import "TKPDSecureStorage.h"
#import "ProductFeedViewController.h"
#import "HistoryProductViewController.h"
#import "FavoritedShopViewController.h"

#import "Notification.h"
#import "NotificationViewController.h"
#import "NotificationBarButton.h"
#import "NotificationRequest.h"

@interface TKPDTabHomeViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, NotificationDelegate> {
    NSDictionary *_auth;
    UIView *_view;
    UIView *_tabView;
    NSInteger _viewControllerIndex;
    CGFloat _totalOffset;
    UIPageViewControllerNavigationDirection _direction;

    BOOL _tabBarCanScrolling;

    Notification *_notification;

}

@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) UIScrollView *tabScrollView;
@property (strong, nonatomic) UIScrollView *pageScrollView;

@property (strong, nonatomic) HotlistViewController *hotListViewController;
@property (strong, nonatomic) ProductFeedViewController *productFeedViewController;
@property (strong, nonatomic) HistoryProductViewController *historyProductViewController;
@property (strong, nonatomic) FavoritedShopViewController *favoritedShopViewController;

@property (strong, nonatomic) UIView *notificationView;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationViewController *notificationController;

@end

@implementation TKPDTabHomeViewController

- (void)viewDidLoad
{
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    
    CGRect pageControllerFrame = [[self view] bounds];
    pageControllerFrame.origin.y = 108;
    pageControllerFrame.size.height -= 108;
    [[self.pageController view] setFrame:pageControllerFrame];

    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
	NSDictionary* auth = [secureStorage keychainDictionary];
	_auth = [auth mutableCopy];
    
    _hotListViewController = [HotlistViewController new];
    _hotListViewController.data = @{kTKPD_AUTHKEY : _auth?:@""};
    _hotListViewController.index = 1;
    
    _productFeedViewController = [ProductFeedViewController new];
    _productFeedViewController.index = 2;
    
    _historyProductViewController = [HistoryProductViewController new];
    _historyProductViewController.index = 3;
    
    _favoritedShopViewController = [FavoritedShopViewController new];
    _favoritedShopViewController.index = 4;

    NSArray *viewControllers = [NSArray arrayWithObject:_hotListViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    _totalOffset = 0;

    _tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width*3, 44)];
    _tabView.backgroundColor = [UIColor whiteColor];

    _tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _tabScrollView.tag = 2;
    _tabScrollView.contentSize = CGSizeMake((self.view.frame.size.width/3)*6, 44);
    _tabScrollView.delegate = self;
    [_tabScrollView setShowsHorizontalScrollIndicator:NO];
    [_tabView addSubview:_tabScrollView];

    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*1, 0, (self.view.frame.size.width/3), 44)];
    [button1 setTitle:@"Hotlist" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(tabButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [_tabScrollView addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 0, (self.view.frame.size.width/3), 44)];
    [button2 setTitle:@"Produk Feed" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(tabButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [_tabScrollView addSubview:button2];

    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*3, 0, (self.view.frame.size.width/3), 44)];
    [button3 setTitle:@"Terakhir Dilihat" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button3.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button3.tag = 3;
    [button3 addTarget:self action:@selector(tabButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [_tabScrollView addSubview:button3];

    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*4, 0, (self.view.frame.size.width/3), 44)];
    [button4 setTitle:@"Toko Favorit" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button4.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button4.tag = 4;
    [button4 addTarget:self action:@selector(tabButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [_tabScrollView addSubview:button4];

    CALayer *bottomBorder = [[CALayer alloc] init];
    bottomBorder.frame = CGRectMake(0, 43, _tabView.frame.size.width, 1);
    bottomBorder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor;
    [_tabView.layer addSublayer:bottomBorder];
    
    [[self view] addSubview:_tabView];

    for (UIScrollView *scrollView in self.pageController.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            _pageScrollView = scrollView;
            _pageScrollView.delegate = self;
            _pageScrollView.tag = 1;
        }
    }
    
    _viewControllerIndex = 1;
 
    _direction = UIPageViewControllerNavigationDirectionForward;
    
    _tabBarCanScrolling = YES;
    
    _notificationView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _notificationView.clipsToBounds = YES;
    
    UIView *notificationTapToCloseArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowDidTap)];
    [notificationTapToCloseArea addGestureRecognizer:tapRecognizer];
    [_notificationView addSubview:notificationTapToCloseArea];
    
    // Notification button
    _notificationButton = [[NotificationBarButton alloc] init];
    UIButton *button = (UIButton *)_notificationButton.customView;
    [button addTarget:self action:@selector(barButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = _notificationButton;

    _notificationArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_triangle_grey"]];
    _notificationArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    _notificationArrowImageView.clipsToBounds = YES;
    _notificationArrowImageView.frame = CGRectMake(_notificationButton.customView.frame.origin.x+12, 60, 10, 5);
    _notificationArrowImageView.alpha = 0;
    [_notificationView addSubview:_notificationArrowImageView];
    
    NotificationRequest *notificationRequest = [NotificationRequest new];
    notificationRequest.delegate = self;
    [notificationRequest loadNotification];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];

    UIImageView *greenArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_green.png"]];
    CGRect frame = greenArrowImageView.frame;
    frame.size.width = 13;
    frame.size.height = 13;
    frame.origin.x = self.view.frame.size.width/2 - 6.5f;
    frame.origin.y = 64;
    greenArrowImageView.frame = frame;
    [self.view addSubview:greenArrowImageView];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"]]; //navigation-bg

    [navigationBar setBackgroundImage:backgroundImage
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[HotlistViewController class]]) {
        return nil;
    }
    else if ([viewController isKindOfClass:[ProductFeedViewController class]]) {
        return _hotListViewController;
    }
    else if ([viewController isKindOfClass:[HistoryProductViewController class]]) {
        return _productFeedViewController;
    }
    else if ([viewController isKindOfClass:[FavoritedShopViewController class]]) {
        return _historyProductViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[HotlistViewController class]]) {
        return _productFeedViewController;
    }
    else if ([viewController isKindOfClass:[ProductFeedViewController class]]) {
        return _historyProductViewController;
    }
    else if ([viewController isKindOfClass:[HistoryProductViewController class]]) {
        return _favoritedShopViewController;
    }
    else if ([viewController isKindOfClass:[FavoritedShopViewController class]]) {
        return nil;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if ([previousViewControllers[0] index] < [pageViewController.viewControllers[0] index]) {
        _viewControllerIndex++;
    } else if ([previousViewControllers[0] index] > [pageViewController.viewControllers[0] index]) {
        _viewControllerIndex--;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setActiveButton];
    });
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if ([pendingViewControllers[0] index] < [pageViewController.viewControllers[0] index]) {
        _direction = UIPageViewControllerNavigationDirectionForward;
    } else if ([pendingViewControllers[0] index] > [pageViewController.viewControllers[0] index]) {
        _direction = UIPageViewControllerNavigationDirectionReverse;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1 && _tabBarCanScrolling) {
        if (_viewControllerIndex == 1) {
            _totalOffset = scrollView.contentOffset.x;
        } else {
            _totalOffset = scrollView.contentOffset.x + ((_viewControllerIndex-1) * self.view.frame.size.width);
        }
        _tabScrollView.contentOffset = CGPointMake((_totalOffset / 3) - (self.view.frame.size.width/3), 0);

        NSLog(@"%f dari %f", _tabScrollView.contentOffset.x, scrollView.contentOffset.x);
    }
}

- (void)tabButtonDidTap:(UIButton *)button
{
    if (button.tag > _viewControllerIndex) {
        _direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        _direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    switch (button.tag) {
        case 1: {
            
            if (_viewControllerIndex == 1) {
                break;
            }
            
            _viewControllerIndex = 1;
            [self setActiveButton];
            _totalOffset = (self.view.frame.size.width/3) * (_viewControllerIndex-1);
            _tabBarCanScrolling = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _tabScrollView.contentOffset = CGPointMake(_totalOffset, 0);
            }];
            [self.pageController setViewControllers:@[_hotListViewController]
                                          direction:_direction
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             _tabBarCanScrolling = YES;
                                         }];
        }
             break;
            
        case 2: {
            
            if (_viewControllerIndex == 2) {
                break;
            }
            
            _viewControllerIndex = 2;
            [self setActiveButton];
            _totalOffset = (self.view.frame.size.width/3) * (_viewControllerIndex-1);
            _tabBarCanScrolling = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _tabScrollView.contentOffset = CGPointMake(_totalOffset, 0);
            }];
            [self.pageController setViewControllers:@[_productFeedViewController]
                                          direction:_direction
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             _tabBarCanScrolling = YES;
                                         }];
        }
            break;
            
        case 3: {
            
            if (_viewControllerIndex == 3) {
                break;
            }
            
            _viewControllerIndex = 3;
            [self setActiveButton];
            _totalOffset = self.view.frame.size.width - (self.view.frame.size.width/3);
            _tabBarCanScrolling = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _tabScrollView.contentOffset = CGPointMake(_totalOffset, 0);
            }];
            [self.pageController setViewControllers:@[_historyProductViewController]
                                          direction:_direction
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             _tabBarCanScrolling = YES;
                                         }];
        }
            break;
            
        case 4: {
            
            if (_viewControllerIndex == 4) {
                break;
            }
            
            _viewControllerIndex = 4;
            [self setActiveButton];
            _totalOffset = (self.view.frame.size.width/3) * (_viewControllerIndex-1);
            _tabBarCanScrolling = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _tabScrollView.contentOffset = CGPointMake(_totalOffset, 0);
            }];
            [self.pageController setViewControllers:@[_favoritedShopViewController]
                                          direction:_direction
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             _tabBarCanScrolling = YES;
                                         }];
        }
            break;
            
        default:
            break;
    }
}

- (void)setActiveButton
{
    for (UIButton *button in _tabScrollView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag == _viewControllerIndex) {
                [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
            } else {
                [button setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - Notification delegate

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    
    if ([_notification.result.total_notif integerValue] == 0) {
        
        _notificationButton.badgeLabel.hidden = YES;
        
    } else {
        
        _notificationButton.enabled = YES;
        
        _notificationButton.badgeLabel.hidden = NO;
        _notificationButton.badgeLabel.text = _notification.result.total_notif;
        
        NSInteger totalNotif = [_notification.result.total_notif integerValue];
        
        CGRect badgeLabelFrame = _notificationButton.badgeLabel.frame;
        
        if (totalNotif >= 10 && totalNotif < 100) {
            
            badgeLabelFrame.origin.x -= 6;
            badgeLabelFrame.size.width += 11;
            
        } else if (totalNotif >= 100 && totalNotif < 1000) {
            
            badgeLabelFrame.origin.x -= 7;
            badgeLabelFrame.size.width += 14;
            
        } else if (totalNotif >= 1000 && totalNotif < 10000) {
            
            badgeLabelFrame.origin.x -= 11;
            badgeLabelFrame.size.width += 22;
            
        } else if (totalNotif >= 10000 && totalNotif < 100000) {
            
            badgeLabelFrame.origin.x -= 17;
            badgeLabelFrame.size.width += 30;
            
        }
        
        _notificationButton.badgeLabel.frame = badgeLabelFrame;
        
    }
}

#pragma mark - Notification methods

- (void)barButtonDidTap
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    _notificationController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    _notificationController.notification = _notification;

    [[[self tabBarController] view] addSubview:_notificationView];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    windowFrame.size.height = 0;
    _notificationView.frame = windowFrame;
    
    CGRect tableFrame = [[UIScreen mainScreen] bounds];
    tableFrame.origin.y = 64;
    self.notificationController.tableView.frame = tableFrame;
    tableFrame.size.height = self.view.frame.size.height-64;
    
    [_notificationView addSubview:_notificationController.tableView];
    
    _notificationArrowImageView.alpha = 1;
    
    [UIView animateWithDuration:0.7 animations:^{
        _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }];
    
    [UIView animateWithDuration:0.55 animations:^{
        _notificationView.frame = [[UIScreen mainScreen] bounds];
        self.notificationController.tableView.frame = tableFrame;
    }];
}

- (void)windowDidTap
{
    CGRect windowFrame = _notificationView.frame;
    windowFrame.size.height = 0;
    
    [UIView animateWithDuration:0.15 animations:^{
        _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _notificationArrowImageView.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        _notificationView.frame = windowFrame;
    } completion:^(BOOL finished) {
        [_notificationView removeFromSuperview];
    }];
}

@end