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
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "NotificationState.h"
#import "UserAuthentificationManager.h"

#import "MyWishlistViewController.h"

#import "RedirectHandler.h"

#import "NavigateViewController.h"

#import "UIView+HVDLayout.h"
#import "Tokopedia-Swift.h"
#import "SearchViewController.h"
#import "PromoViewController.h"

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
    BOOL _needToActivateSearch;
    BOOL _isViewLoaded;
}

@property (strong, nonatomic) HomePageViewController *homePageController;
@property (strong, nonatomic) HotlistViewController *hotlistController;
@property (strong, nonatomic) FeedViewController *feedController;
@property (strong, nonatomic) PromoViewController *promoViewController;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) HistoryProductViewController *historyController;
@property (strong, nonatomic) FavoritedShopViewController *shopViewController;
@property (strong, nonatomic) HomeTabHeaderViewController *homeHeaderController;
@property (strong, nonatomic) MyWishlistViewController *wishListViewController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *homeHeaderView;
@property (strong, nonatomic) NSArray<UIViewController*> *viewControllers;

@property (strong, nonatomic) SearchBarWrapperView *searchBarWrapperView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateSearch:) name:@"activateSearch" object:nil];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _homePageController = [HomePageViewController new];
    
    _feedController = [FeedViewController new];
    
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
    [self setSearchBar];
    
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchController setActive:NO];
    self.definesPresentationContext = NO;
}

- (void)setSearchBar {
    SearchViewController* resultController = [[SearchViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:resultController];
    [_searchController setSearchBarToTopWithViewController:self];
    _searchBarWrapperView = [_searchController getSearchWrapperView];
    
    [self.searchController.searchBar setTextFieldColorWithColor:[UIColor whiteColor]];
    [self.searchController.searchBar setTextColorWithColor:[UIColor blackColor]];
    
    resultController.searchBar = self.searchController.searchBar;
    resultController.searchBar.text = @"";
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
    
    self.definesPresentationContext = YES;
    [self.searchController.searchBar setShowsCancelButton:NO animated:YES];
    
    [self goToPage:_page];
    [self tapButtonAnimate:_scrollView.frame.size.width*(_page)];
    if([_userManager isLogin]) {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*5, 300)];
    } else {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width*2, 300)];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    float fractionalPage = _scrollView.contentOffset.x  / _scrollView.frame.size.width;
    _page = lround(fractionalPage);
    
    _isViewLoaded = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isViewLoaded = YES;
    [self initNotificationManager];
}

- (void)setArrow {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStylePlain
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
    int page = (int) lround(fractionalPage);
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
    if (!_viewControllers) return;

    _shopViewController.isOpened = false;
    if(page == 4){
        _shopViewController.isOpened = true;
    }
    
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

- (void)navigateUsingTPRoutesWithString:(NSString *)urlString onNotificationManager:(id)notificationManager {
    [notificationManager tapWindowBar];
    [self performSelector:@selector(redirectUsingTPRoutesToURL:) withObject:urlString afterDelay:0.45];
}

- (void)redirectUsingTPRoutesToURL:(NSString *)urlString {
    [TPRoutes routeURL:[NSURL URLWithString:urlString]];
}

- (void)goToInboxMessage {
    [TPRoutes routeURL:[NSURL URLWithString:@"tokopedia://topchat"]];
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
    NSDictionary* data = [notification.userInfo objectForKey:@"data"];
    if ([data objectForKey:@"applinks"] != nil) {
        NSString* applinks = [data objectForKey:@"applinks"];
        [TPRoutes routeURL:[NSURL URLWithString:applinks]];
    } else {
        _redirectHandler = [[RedirectHandler alloc]init];
        _redirectHandler.delegate = self;
        
        NSInteger code = [[data objectForKey:@"tkp_code"] integerValue];
        
        [_redirectHandler proxyRequest:code];
    }
}

#pragma mark - Search Controller Delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self setSearchControllerHidden:NO];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self setSearchControllerHidden:NO];
    self.navigationItem.rightBarButtonItem = nil;
    if (_searchBarWrapperView != nil)
        _searchBarWrapperView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
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
    [self setSearchBar];
}

- (void)activateSearch:(NSNotification*)notification {
    if (_isViewLoaded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.searchController.searchBar becomeFirstResponder];
            });
        });
    } else {
        _needToActivateSearch = YES;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark - Method

- (void) instantiateViewControllers {
    if (_userManager.isLogin) {
        _viewControllers = @[_homePageController, _feedController, _promoViewController, _historyController, _shopViewController];
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
