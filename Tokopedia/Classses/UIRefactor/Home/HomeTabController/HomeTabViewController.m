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
#import "WishListViewController.h"

#import "RedirectHandler.h"

@interface HomeTabViewController () <UIScrollViewDelegate,
                                    NotificationManagerDelegate,
                                    RedirectHandlerDelegate,
                                    TKPDTabHomeDelegate>
{
    NotificationManager *_notifManager;
    NSInteger _page;
    BOOL _isAbleToSwipe;
    UserAuthentificationManager *_userManager;
    RedirectHandler *_redirectHandler;
}

@property (strong, nonatomic) HotlistViewController *hotlistController;
@property (strong, nonatomic) ProductFeedViewController *productFeedController;
@property (strong, nonatomic) HistoryProductViewController *historyController;
@property (strong, nonatomic) FavoritedShopViewController *shopViewController;
@property (strong, nonatomic) HomeTabHeaderViewController *homeHeaderController;
@property (strong, nonatomic) WishListViewController *wishListViewController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *homeHeaderView;

@end

@implementation HomeTabViewController

#pragma mark - Init
- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomePage:)
                                                 name:@"didSwipeHomePage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotification:)
                                                 name:@"redirectNotification" object:nil];
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hotlistController = [HotlistViewController new];
    _hotlistController.delegate = self;
    
    _productFeedController = [ProductFeedViewController new];
    _productFeedController.delegate = self;
    
    _historyController = [HistoryProductViewController new];
    _historyController.delegate = self;
    
    _shopViewController = [FavoritedShopViewController new];
    _shopViewController.delegate = self;
    
    _homeHeaderController = [HomeTabHeaderViewController new];
    
    _wishListViewController = [WishListViewController new];
    _wishListViewController.delegate = self;

    _redirectHandler = [RedirectHandler new];
    _redirectHandler.delegate = self;
    
    [self initNotificationCenter];

    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [_scrollView setFrame:self.view.frame];
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*5, 300)];
    [_scrollView setPagingEnabled:YES];
    _scrollView.delegate = self;

    [self addChildViewController:_hotlistController];
    [self.scrollView addSubview:_hotlistController.view];
    
    [_hotlistController didMoveToParentViewController:self];
    [self setArrow];
    [self setHeaderBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [_scrollView setFrame:self.view.frame];
    self.navigationController.title = @"Beranda";
    
    [self goToPage:_page];
    [self initNotificationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    
    _userManager = [UserAuthentificationManager new];
    if([[_userManager getUserId] isEqualToString:@"0"]) {
        _isAbleToSwipe = NO;
        [_scrollView setContentSize:CGSizeMake(300, 300)];
        [_scrollView setPagingEnabled:NO];

    } else {
        _isAbleToSwipe = YES;
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*5, 300)];
        [_scrollView setPagingEnabled:YES];
    }
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
    frame.origin.x = self.view.frame.size.width/2 - 6.5f;
    frame.origin.y = 64;
    greenArrowImageView.frame = frame;
//    [self.navigationController.navigationBar addSubview:greenArrowImageView];
    [self.view addSubview:greenArrowImageView];
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



#pragma mark - Action
- (void)setIndexPage:(int)idxPage
{
    _page = idxPage;
}

- (void)goToPage:(NSInteger)page {
    if(page == 0) {
        CGRect frame = _hotlistController.view.frame;
        frame.origin.x = 0;
        _hotlistController.view.frame = frame;
        
        [self addChildViewController:_hotlistController];
        [self.scrollView addSubview:_hotlistController.view];
        [_hotlistController didMoveToParentViewController:self];
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
    } else if (code == STATE_NEW_REVIEW ||
               code == STATE_EDIT_REVIEW ||
               code == STATE_REPLY_REVIEW) {
        [self goToInboxReview];
    }
}

- (void)goToInboxMessage {
    InboxMessageViewController *vc = [InboxMessageViewController new];
    vc.data=@{@"nav":@"inbox-message"};
    
    InboxMessageViewController *vc1 = [InboxMessageViewController new];
    vc1.data=@{@"nav":@"inbox-message-sent"};
    
    InboxMessageViewController *vc2 = [InboxMessageViewController new];
    vc2.data=@{@"nav":@"inbox-message-archive"};
    
    InboxMessageViewController *vc3 = [InboxMessageViewController new];
    vc3.data=@{@"nav":@"inbox-message-trash"};
    NSArray *vcs = @[vc,vc1, vc2, vc3];
    
    TKPDTabInboxMessageNavigationController *inboxController = [TKPDTabInboxMessageNavigationController new];
    [inboxController setSelectedIndex:2];
    [inboxController setViewControllers:vcs];
    
    [self.navigationController pushViewController:inboxController animated:YES];
}

- (void)goToInboxTalk {
    InboxTalkViewController *vc = [InboxTalkViewController new];
    vc.data=@{@"nav":@"inbox-talk"};
    
    InboxTalkViewController *vc1 = [InboxTalkViewController new];
    vc1.data=@{@"nav":@"inbox-talk-my-product"};
    
    InboxTalkViewController *vc2 = [InboxTalkViewController new];
    vc2.data=@{@"nav":@"inbox-talk-following"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxTalkNavigationController *nc = [TKPDTabInboxTalkNavigationController new];
    [nc setSelectedIndex:2];
    [nc setViewControllers:vcs];
    //    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
    //    [nav.navigationBar setTranslucent:NO];
    //    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [self.navigationController pushViewController:nc animated:YES];
}

- (void)goToInboxReview {
    InboxReviewViewController *vc = [InboxReviewViewController new];
    vc.data=@{@"nav":@"inbox-review"};
    
    InboxReviewViewController *vc1 = [InboxReviewViewController new];
    vc1.data=@{@"nav":@"inbox-review-my-product"};
    
    InboxReviewViewController *vc2 = [InboxReviewViewController new];
    vc2.data=@{@"nav":@"inbox-review-my-review"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxReviewNavigationController *nc = [TKPDTabInboxReviewNavigationController new];
    [nc setSelectedIndex:2];
    [nc setViewControllers:vcs];
    //    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
    //    [nav.navigationBar setTranslucent:NO];
    //    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)goToNewOrder {
    
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
