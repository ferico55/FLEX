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
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "InboxMessageViewController.h"
#import "NotificationState.h"
#import "UserAuthentificationManager.h"

#import "MyWishlistViewController.h"

#import "RedirectHandler.h"

#import "InboxRootViewController.h"
#import "NavigateViewController.h"

#import "UIView+HVDLayout.h"
#import "Tokopedia-Swift.h"
#import "SearchViewController.h"

@interface HomeTabViewController ()
<
    UIScrollViewDelegate,
    NotificationManagerDelegate,
    RedirectHandlerDelegate,
    UISearchControllerDelegate,
    UISearchResultsUpdating,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>
{
    NotificationManager *_notifManager;
    NSInteger _page;
    UserAuthentificationManager *_userManager;
    RedirectHandler *_redirectHandler;
    NavigateViewController *_navigate;
    NSURL *_deeplinkUrl;
}

@property (strong, nonatomic) HomePageViewController *homePageController;
@property (strong, nonatomic) HotlistViewController *hotlistController;
@property (strong, nonatomic) ProductFeedViewController *productFeedController;
@property (strong, nonatomic) PromoViewController *promoViewController;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) HistoryProductViewController *historyController;
@property (strong, nonatomic) FavoritedShopViewController *shopViewController;
@property (strong, nonatomic) HomeTabHeaderViewController *homeHeaderController;
@property (strong, nonatomic) MyWishlistViewController *wishListViewController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *homeHeaderView;
@property (strong, nonatomic) NSArray<UIViewController*> *viewControllers;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _homePageController = [HomePageViewController new];
    
    _productFeedController = [ProductFeedViewController new];
    
    _promoViewController = [PromoViewController new];
    
    _historyController = [HistoryProductViewController new];
    _shopViewController = [FavoritedShopViewController new];
    
    _homeHeaderController = [HomeTabHeaderViewController new];

    _redirectHandler = [RedirectHandler new];
    
    _navigate = [NavigateViewController new];
    
    _userManager = [UserAuthentificationManager new];
    
    [self instantiateViewControllers];
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [_scrollView setPagingEnabled:YES];
    
    //this code to prevent user lose their hometabheader being hided by scrollview if they already loggedin from previous version
    //check didLoggedIn method
    CGRect frame = _scrollView.frame;
    frame.origin.y = 44;
    _scrollView.frame = frame;
    
    _scrollView.delegate = self;

    [self addChildViewController:_homePageController];
    [self.scrollView addSubview:_homePageController.view];
    
    [self setSearchBar];
    [self setSearchByImage];
    
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:_homePageController.view
                                attribute:NSLayoutAttributeWidth
                                relatedBy:0
                                toItem:self.scrollView
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0
                                constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint
                                 constraintWithItem:_homePageController.view
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:0
                                 toItem:self.scrollView
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:_homePageController.view
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.scrollView
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:_homePageController.view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.scrollView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];

    [self.scrollView addConstraints:@[width, height, top, leading]];
    [_homePageController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_homePageController didMoveToParentViewController:self];
    [self setArrow];
    [self setHeaderBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchController setActive:NO];
    self.definesPresentationContext = NO;
}

- (void)setSearchBar {
    SearchViewController* resultController = [[SearchViewController alloc] init];
    resultController.presentController = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Cari produk atau toko";
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.searchController.searchBar.barTintColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;
    
    resultController.searchBar = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    
    //sometimes cancel button is missing if placed on navigation, thus it needs a wrapper #ios bugs
    UIView* searchWrapper = [[UIView alloc] initWithFrame:self.searchController.searchBar.bounds];
    [searchWrapper setBackgroundColor:[UIColor clearColor]];
    [searchWrapper addSubview:self.searchController.searchBar];
    self.searchController.searchBar.layer.borderWidth = 1;
    self.searchController.searchBar.layer.borderColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR.CGColor;
    
    [self.searchController.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(searchWrapper);
    }];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.navigationItem.titleView = searchWrapper;
}

- (void)setSearchByImage {
    if([self isEnableImageSearch]) {
        self.searchController.searchBar.showsBookmarkButton = YES;
        [self.searchController.searchBar setImage:[UIImage imageNamed:@"icon_snap.png"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    } else  {
        self.searchController.searchBar.showsBookmarkButton = NO;
    }
}


-(BOOL)isEnableImageSearch{
    UserAuthentificationManager* userManager = [UserAuthentificationManager new];
    if (!userManager.isLogin) {
        return NO;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    NSString *enableImageSearchString = [gtmContainer stringForKey:@"enable_image_search"]?:@"0";
    
    return [enableImageSearchString isEqualToString:@"1"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.title = @"Home";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    [self goToPage:_page];
    if([_userManager isLogin]) {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*5, 300)];
    } else {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*2, 300)];
    }
    [self initNotificationManager];
    
    [Localytics triggerInAppMessage:@"Home - Hot List"];
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    float fractionalPage = _scrollView.contentOffset.x  / _scrollView.frame.size.width;
    _page = lround(fractionalPage);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.definesPresentationContext = YES;
}

- (void)setArrow {
//    UIImageView *greenArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_green.png"]];
//    CGRect frame = greenArrowImageView.frame;
//    frame.size.width = 13;
//    frame.size.height = 7;
//    frame.origin.x = [[UIScreen mainScreen]bounds].size.width/2 - 6.5f;
//    frame.origin.y = 64;
//    greenArrowImageView.frame = frame;
////    [self.navigationController.navigationBar addSubview:greenArrowImageView];
//    [self.view addSubview:greenArrowImageView];
    
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
    float fractionalPage = scrollView.contentOffset.x  / scrollView.frame.size.width;
    NSInteger page = lround(fractionalPage);
    if (page >= 0 && page < _viewControllers.count) {
        [self setIndexPage:page];
        [self goToPage:_page];
    }
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
    CGRect frame = _viewControllers[page].view.frame;
    frame.origin.x = _scrollView.frame.size.width*page;
    frame.size.height = _scrollView.frame.size.height;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    _viewControllers[page].view.frame = frame;
    
    [self addChildViewController:_viewControllers[page]];
    [self.scrollView addSubview:_viewControllers[page].view];
    [_viewControllers[page] didMoveToParentViewController:self];
    
    NSDictionary *userInfo = @{@"tag" : @(page)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeHomeTab" object:nil userInfo:userInfo];
}

- (void)didSwipeHomePage:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"page"]integerValue];
    [self setIndexPage:index-1];
    [self goToPage:_page];
    [self tapButtonAnimate:_scrollView.frame.size.width*(index-1)];
}

- (void)tapButtonAnimate:(CGFloat)totalOffset{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(totalOffset, _scrollView.contentOffset.y);
    }];
}

- (void)redirectToWishList
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.tag = 4;
    [_homeHeaderController tapButton:tempBtn];
}

- (void)redirectToProductFeed
{
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.tag = 2;
    [_homeHeaderController tapButton:tempBtn];
}

- (void)redirectToHome {
    _page = 0;
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.tag = 1;
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
    [AnalyticsManager trackEventName:@"clickTopedIcon" category:GA_EVENT_CATEGORY_NOTIFICATION action:GA_EVENT_ACTION_CLICK label:@"Bell Notification"];
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

#pragma mark - Search Controller Delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self setSearchControllerHidden:NO];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self setSearchControllerHidden:NO];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}


- (void)userDidLogin:(NSNotification*)notification {
    // [self view] gunanya adalah memanggil viewDidLoad dari background. Dipakai di sini untuk ketika untuk mencegah bug crash saat user login langsung dari onboarding.
    [self view];
    [self instantiateViewControllers];
    [self setSearchByImage];
    [self redirectToProductFeed];
    [self setIndexPage:1];
}

- (void)userDidLogout:(NSNotification*)notification {
    [self view];
    [self instantiateViewControllers];
    [self redirectToHome];
    [self setSearchByImage];
}
    
#pragma mark - Method

- (void) instantiateViewControllers {
    if (_userManager.isLogin) {
        _viewControllers = @[_homePageController, _productFeedController, _promoViewController, _historyController, _shopViewController];
    } else {
        _viewControllers = @[_homePageController, _promoViewController];
    }
}

-(void) setSearchControllerHidden:(BOOL) hidden {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.searchController.searchResultsController.view.hidden = hidden;
    });
}

- (void)scrollToTop
{
    NSArray *vcs = [_viewControllers mutableCopy];
    if ([vcs[_page] respondsToSelector:@selector(scrollToTop)]) {
        [vcs[_page] scrollToTop];
    }
}

@end
