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

#import "NotificationState.h"

#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"

#import "NavigateViewController.h"

@interface TKPDTabHomeViewController ()
<   UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    UIGestureRecognizerDelegate,
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate,
    TKPDTabHomeDelegate,
    NotificationManagerDelegate
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

    NavigateViewController *_navigate;
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

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    _userManager = [UserAuthentificationManager new];

    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];

    _viewControllerIndex = 1;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [self.pageController.view setMultipleTouchEnabled:YES];
    
    CGRect pageControllerFrame = [[self view] bounds];
    pageControllerFrame.origin.y = 108;
    pageControllerFrame.size.height -= 108;
    [[self.pageController view] setFrame:pageControllerFrame];
    
    _hotListViewController = [HotlistViewController new];
    _hotListViewController.data = @{kTKPD_AUTHKEY : [_userManager getUserLoginData]?:@""};
    _hotListViewController.index = 1;
    _hotListViewController.delegate = self;

    [self.pageController setViewControllers:@[_hotListViewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];

    _productFeedViewController = [ProductFeedViewController new];
    _productFeedViewController.index = 2;
    _productFeedViewController.delegate = self;
    
    _historyProductViewController = [HistoryProductViewController new];
    _historyProductViewController.index = 3;
    _historyProductViewController.delegate = self;
    
    _favoritedShopViewController = [FavoritedShopViewController new];
    _favoritedShopViewController.index = 4;
    _favoritedShopViewController.delegate = self;
    
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
    [self.view addSubview:_tabView];
    
    UIImageView *greenArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_green.png"]];
    CGRect frame = greenArrowImageView.frame;
    frame.size.width = 13;
    frame.size.height = 13;
    frame.origin.x = self.view.frame.size.width/2 - 6.5f;
    frame.origin.y = 64;
    greenArrowImageView.frame = frame;
    [self.view addSubview:greenArrowImageView];

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
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 43, _tabScrollView.contentSize.width, 1)];
    border.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [_tabScrollView addSubview:border];
    
    for (UIScrollView *scrollView in self.pageController.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            _pageScrollView = scrollView;
            _pageScrollView.delegate = self;
            _pageScrollView.tag = 1;
        }
    }
    
    _direction = UIPageViewControllerNavigationDirectionForward;
    
    _tabBarCanScrolling = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectAfterNotification:)
                                                 name:@"redirectAfterNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPageController)
                                                 name:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION
                                               object:nil];

}

-(void)pan
{}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];

    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
    
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
    
    if ([[_pageController.viewControllers objectAtIndex:0] isKindOfClass:[HotlistViewController class]]) {
        _tabScrollView.contentOffset = CGPointMake(0, 0);
    } else if ([[_pageController.viewControllers objectAtIndex:0] isKindOfClass:[ProductFeedViewController class]]) {
        _tabScrollView.contentOffset = CGPointMake(self.view.frame.size.width/3, 0);
    } else if ([[_pageController.viewControllers objectAtIndex:0] isKindOfClass:[HistoryProductViewController class]]) {
        _tabScrollView.contentOffset = CGPointMake(2*(self.view.frame.size.width/3), 0);
    } else if ([[_pageController.viewControllers objectAtIndex:0] isKindOfClass:[FavoritedShopViewController class]]) {        
        _tabScrollView.contentOffset = CGPointMake(3*(self.view.frame.size.width/3), 0);
    }
    
    _userManager = [UserAuthentificationManager new];

    if(_userManager.isLogin) {

        _tabScrollView.scrollEnabled = YES;
        
        for (id subview in _tabScrollView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                button.hidden = NO;
            }
        }

        for(id view in _pageController.view.subviews){
            if([view isKindOfClass:[UIScrollView class]]){
                [(UIScrollView *)view setScrollEnabled:YES];
            }
        }
        


    } else {
        
        _viewControllerIndex = 1;

        _tabScrollView.scrollEnabled = NO;
        _tabScrollView.contentOffset = CGPointMake(0, 0);

        for (id subview in _tabScrollView.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if (button.tag > 1) {
                    button.hidden = YES;
                }
            }
        }
        
        for(id view in _pageController.view.subviews){
            if([view isKindOfClass:[UIScrollView class]]){
                [(UIScrollView *)view setScrollEnabled:NO];
            }
        }
        
        [self.pageController setViewControllers:@[_hotListViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ProductFeedViewController class]]) {
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

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1 && _tabBarCanScrolling) {
        if (_viewControllerIndex == 1) {
            _totalOffset = scrollView.contentOffset.x;
        } else {
            _totalOffset = scrollView.contentOffset.x + ((_viewControllerIndex-1) * self.view.frame.size.width);
        }
        _tabScrollView.contentOffset = CGPointMake((_totalOffset / 3) - (self.view.frame.size.width/3), 0);
    }
}

#pragma mark - Other methods

- (void)tabButtonDidTap:(UIButton *)button {
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
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

#pragma mark - Notification delegate

- (void)reloadNotification
{
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)redirectAfterNotification:(NSNotification *)userInfo
{
    NSDictionary *userDict = userInfo.userInfo;
    NSInteger code = [[userDict objectForKey:@"state"] integerValue];
    
    if (code == STATE_NEW_MESSAGE) {
        [self goToInboxMessage];
    } else if (code == STATE_NEW_TALK) {
        [self goToInboxTalk];
    } else if (code == STATE_NEW_ORDER) {
        [self goToNewOrder];
    } else if (code == STATE_NEW_REPSYS ||
               code == STATE_EDIT_REPSYS ||
               code == STATE_NEW_REVIEW ||
               code == STATE_EDIT_REVIEW ||
               code == STATE_REPLY_REVIEW) {
        [self goToInboxReview];
    }
}

- (void)goToInboxMessage {
    [_navigate navigateToInboxMessageFromViewController:self];
}

- (void)goToInboxTalk {
    [_navigate navigateToInboxTalkFromViewController:self];
}

- (void)goToInboxReview {
    [_navigate navigateToInboxReviewFromViewController:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:_pageScrollView];
        if (fabsf(velocity.y) * 2 < fabsf(velocity.x)) {
            return YES;
        }
    }
    return NO;
}



- (void)goToNewOrder {
    
}

- (void)reloadPageController
{
    [self.pageController setViewControllers:@[_hotListViewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

@end