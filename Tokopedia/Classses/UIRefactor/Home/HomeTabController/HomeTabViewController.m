//
//  HomeTabViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HomeTabViewController.h"

#import "ProductFeedViewController.h"
#import "HotlistViewController.h"
#import "HistoryProductViewController.h"
#import "FavoritedShopViewController.h"

#import "HomeTabHeaderViewController.h"
#import "NotificationManager.h"
#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "InboxMessageViewController.h"
#import "InboxReviewViewController.h"
#import "NotificationState.h"
#import "UserAuthentificationManager.h"

#import "MyWishlistViewController.h"

#import "RedirectHandler.h"

#import "InboxRootViewController.h"
#import "NavigateViewController.h"
#import "CategoryViewController.h"

#import "Localytics.h"

@interface HomeTabViewController ()
<
    UIScrollViewDelegate,
    NotificationManagerDelegate,
    RedirectHandlerDelegate,
    TKPDTabHomeDelegate
>
{
    NotificationManager *_notifManager;
    NSInteger _page;
    BOOL _isAbleToSwipe;
    UserAuthentificationManager *_userManager;
    RedirectHandler *_redirectHandler;
    NavigateViewController *_navigate;
    NSURL *_deeplinkUrl;
}

@property (strong, nonatomic) CategoryViewController *categoryController;
@property (strong, nonatomic) HotlistViewController *hotlistController;
@property (strong, nonatomic) ProductFeedViewController *productFeedController;
@property (strong, nonatomic) HistoryProductViewController *historyController;
@property (strong, nonatomic) FavoritedShopViewController *shopViewController;
@property (strong, nonatomic) HomeTabHeaderViewController *homeHeaderController;
@property (strong, nonatomic) MyWishlistViewController *wishListViewController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *homeHeaderView;

@end

@implementation HomeTabViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    [self initNotificationCenter];
    return self;
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomePage:)
                                                 name:@"didSwipeHomePage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotification:)
                                                 name:@"redirectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeeplinkUrl:)
                                                 name:@"didReceiveDeeplinkUrl" object:nil];

    
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	__weak typeof(self) weakSelf = self;
    _categoryController = [CategoryViewController new];
    _categoryController.delegate = weakSelf;
    
    
    
    _productFeedController = [ProductFeedViewController new];
    _productFeedController.delegate = weakSelf;
    
    _historyController = [HistoryProductViewController new];
    _historyController.delegate = weakSelf;
    
    _shopViewController = [FavoritedShopViewController new];
    _shopViewController.delegate = weakSelf;
    
    _homeHeaderController = [HomeTabHeaderViewController new];
    
    _wishListViewController = [MyWishlistViewController new];
    _wishListViewController.delegate = self;

    _redirectHandler = [RedirectHandler new];
    _redirectHandler.delegate = self;
    
    _navigate = [NavigateViewController new];

    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*5, 300)];
    [_scrollView setPagingEnabled:YES];
    _scrollView.delegate = self;

    [self addChildViewController:_categoryController];
    [self.scrollView addSubview:_categoryController.view];
    
    [_categoryController didMoveToParentViewController:self];
    [self setArrow];
    [self setHeaderBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.title = @"Beranda";
    
    [self goToPage:_page];
    [self initNotificationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    
    _userManager = [UserAuthentificationManager new];
    if([_userManager isLogin]) {
        _isAbleToSwipe = YES;
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*5, 300)];
        [_scrollView setPagingEnabled:YES];
    } else {
        _isAbleToSwipe = NO;
        [_scrollView setContentSize:CGSizeMake(300, 300)];
        [_scrollView setPagingEnabled:NO];
    }
    
    [Localytics triggerInAppMessage:@"Home - Hot List"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    float fractionalPage = _scrollView.contentOffset.x  / _scrollView.frame.size.width;
    _page = lround(fractionalPage);
}

- (void)setArrow {
    UIImageView *greenArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_green.png"]];
    CGRect frame = greenArrowImageView.frame;
    frame.size.width = 13;
    frame.size.height = 7;
    frame.origin.x = [[UIScreen mainScreen]bounds].size.width/2 - 6.5f;
    frame.origin.y = 64;
    greenArrowImageView.frame = frame;
//    [self.navigationController.navigationBar addSubview:greenArrowImageView];
    [self.view addSubview:greenArrowImageView];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)setHeaderBar {
    [self addChildViewController:_homeHeaderController];
    [_homeHeaderView addSubview:_homeHeaderController.view];
    [_homeHeaderController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!_isAbleToSwipe) return;
    
    float fractionalPage = scrollView.contentOffset.x  / scrollView.frame.size.width;
    NSInteger page = lround(fractionalPage);
    [self goToPage:page];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
}



#pragma mark - Action
- (void)setIndexPage:(int)idxPage
{
    _page = idxPage;
}

- (void)goToPage:(NSInteger)page {
    if(page == 0) {
        CGRect frame = _categoryController.view.frame;
        frame.origin.x = 0;
        _categoryController.view.frame = frame;
        
        [self addChildViewController:_categoryController];
        [self.scrollView addSubview:_categoryController.view];
        [_categoryController didMoveToParentViewController:self];
    }
    if(page == 1) {
        CGRect frame = _productFeedController.view.frame;
        frame.origin.x = _scrollView.frame.size.width;
        _productFeedController.view.frame = frame;
        
        [self addChildViewController:_productFeedController];
        [self.scrollView addSubview:_productFeedController.view];
        [_productFeedController didMoveToParentViewController:self];
    } else if(page == 2) {
        CGRect frame = _wishListViewController.view.frame;
        frame.origin.x = _scrollView.frame.size.width*page;
        _wishListViewController.view.frame = frame;
        
        [self addChildViewController:_wishListViewController];
        [self.scrollView addSubview:_wishListViewController.view];
        [_wishListViewController didMoveToParentViewController:self];
    } else if(page == 3) {
        CGRect frame = _historyController.view.frame;
        frame.origin.x = _scrollView.frame.size.width*page;
        _historyController.view.frame = frame;
        
        [self addChildViewController:_historyController];
        [self.scrollView addSubview:_historyController.view];
        [_historyController didMoveToParentViewController:self];
    } else if(page == 4) {
        CGRect frame = _shopViewController.view.frame;
        frame.origin.x = _scrollView.frame.size.width*page;
        _shopViewController.view.frame = frame;
        
        [self addChildViewController:_shopViewController];
        [self.scrollView addSubview:_shopViewController.view];
        [_shopViewController didMoveToParentViewController:self];
    }
    
    NSDictionary *userInfo = @{@"tag" : @(page)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeHomeTab" object:nil userInfo:userInfo];
}

- (void)didSwipeHomePage:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"page"]integerValue];
    [self goToPage:index-1];
    if(index == 1) {
        [self tapButtonAnimate:0];
    } else if(index == 2) {
        [self tapButtonAnimate:_scrollView.frame.size.width];
    } else if(index == 3) {
        [self tapButtonAnimate:_scrollView.frame.size.width*2];
    } else if(index == 4) {
        [self tapButtonAnimate:_scrollView.frame.size.width*3];
    } else if(index == 5) {
        [self tapButtonAnimate:_scrollView.frame.size.width*4];
    }
}

- (void)tapButtonAnimate:(CGFloat)totalOffset{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(totalOffset, _scrollView.contentOffset.y);
    }];
}

- (void)redirectToWishList
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.tag = 3;
    [_homeHeaderController tapButton:tempBtn];
}

- (void)redirectToProductFeed
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.tag = 2;
    [_homeHeaderController tapButton:tempBtn];
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
    } else if (code == STATE_NEW_RESOLUTION||
              code == STATE_EDIT_RESOLUTION) {
        [self goToResolutionCenter];
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

- (void)goToNewOrder {
    
}

-(void)goToResolutionCenter
{
    [_navigate navigateToInboxResolutionFromViewController:self];
}

#pragma mark - Child view contoller delegate

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}



#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)redirectNotification:(NSNotification*)notification {
    _redirectHandler = [[RedirectHandler alloc]init];
    _redirectHandler.delegate = self;
    
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *data = [userInfo objectForKey:@"data"];
    NSInteger code = [[data objectForKey:@"tkp_code"] integerValue];
    
    [_redirectHandler proxyRequest:code];
}


@end
