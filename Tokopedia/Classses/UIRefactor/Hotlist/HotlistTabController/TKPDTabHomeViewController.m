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
#import "NotificationManager.h"
#import "UserAuthentificationManager.h"


@interface TKPDTabHomeViewController ()
<   UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    UIScrollViewDelegate,
    TKPDTabHomeDelegate
>
{
    NSDictionary *_auth;
    UIView *_view;
    UIView *_tabView;
    NSInteger _viewControllerIndex;
    CGFloat _totalOffset;
    UIPageViewControllerNavigationDirection _direction;

    BOOL _tabBarCanScrolling;

    NotificationManager *_notifManager;
    UserAuthentificationManager *_userManager;

}

@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) UIScrollView *tabScrollView;
@property (strong, nonatomic) UIScrollView *pageScrollView;

@property (strong, nonatomic) HotlistViewController *hotListViewController;
@property (strong, nonatomic) ProductFeedViewController *productFeedViewController;
@property (strong, nonatomic) HistoryProductViewController *historyProductViewController;
@property (strong, nonatomic) FavoritedShopViewController *favoritedShopViewController;


@end

@implementation TKPDTabHomeViewController


#pragma mark - Init Notification
- (void) initNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:@"goToViewController" object:nil];
    [nc addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotificationBar" object:nil];
    [nc addObserver:self selector:@selector(goToViewController:) name:@"goToViewController" object:nil];
    
}

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

    _userManager = [UserAuthentificationManager new];
    
    _hotListViewController = [HotlistViewController new];
    _hotListViewController.data = @{kTKPD_AUTHKEY : [_userManager getUserLoginData]?:@""};
    _hotListViewController.index = 1;
    _hotListViewController.delegate = self;
    
    _productFeedViewController = [ProductFeedViewController new];
    _productFeedViewController.index = 2;
    _productFeedViewController.delegate = self;
    
    _historyProductViewController = [HistoryProductViewController new];
    _historyProductViewController.index = 3;
    _historyProductViewController.delegate = self;
    
    _favoritedShopViewController = [FavoritedShopViewController new];
    _favoritedShopViewController.index = 4;
    _favoritedShopViewController.delegate = self;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
    [self initNotification];
    _userManager = [UserAuthentificationManager new];
    
    if(_userManager.getUserId == @"0") {
        int i = 1;
        for (UIView *subview in [_tabScrollView subviews]) {
            if(i != 1) {
                [subview removeFromSuperview];
            }
            i++;
        }
    } else {
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
    }

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
    NSString *navigationBarImagePath = [[NSBundle mainBundle] pathForResource:kTKPDIMAGE_NAVBARBG ofType:@"png"];
    UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:navigationBarImagePath];

    [navigationBar setBackgroundImage:backgroundImage
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
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

#pragma mark - Child view contoller delegate

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Notification Manager

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

- (void)goToViewController:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    UIViewController *ui  = (UIViewController*)[userinfo objectForKey:@"nav"];
    [self tapWindowBar];
    [self presentViewController:ui animated:YES completion:nil];
}

@end