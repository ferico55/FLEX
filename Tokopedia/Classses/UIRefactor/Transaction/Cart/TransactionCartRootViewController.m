//
//  TransactionCartRootViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "string_transaction.h"
#import "TransactionCartRootViewController.h"
#import "TransactionCartViewController.h"
#import "TransactionCartResultViewController.h"
#import "NotificationManager.h"
#import "RegisterViewController.h"

#import "TransactionCartFormMandiriClickPayViewController.h"

#import "NotificationManager.h"

@interface TransactionCartRootViewController ()
<
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    TransactionCartViewControllerDelegate,
    NotificationManagerDelegate
>
{
    NSInteger _index;
    NSDictionary *_data;
    TransactionCartViewController *_cartViewController;
    TransactionCartViewController *_cartSummaryViewController;
    TransactionCartResultViewController *_cartResultViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
    BOOL _isShouldRefreshingCart;
    
    NotificationManager *_notifManager;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *noLoginView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *pageControlView;
@property (weak, nonatomic) IBOutlet UIButton *registerText;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *pageButtons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabHeightConstraint;

@property (strong, nonatomic) UIPageViewController *pageController;

@end

@implementation TransactionCartRootViewController

#define COUNT_CILD_VIEW_CONTROLLER 3
#define COLOR_DEFAULT_BUTTON [UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0]
#define COLOR_SELECTED_BUTTON [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1.0]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _isShouldRefreshingCart = NO;
    [self initNotification];
    
    
    _pageButtons = [NSArray sortViewsWithTagInArray:_pageButtons];

    for (UIButton *button in _pageButtons) {
        button.backgroundColor = COLOR_DEFAULT_BUTTON;
        button.layer.cornerRadius = button.frame.size.width/2;
        button.clipsToBounds=YES;
    }
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    
    [[_pageController view] setFrame:_containerView.frame];
    
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];

    [[self view] addSubview:_pageControlView];
    [_pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldBackToFirstPage)
                                                 name:SHOULD_REFRESH_CART
                                               object:nil];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Cart Page";
    if (_index == 0) {
        
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        _auth = [secureStorage keychainDictionary];
        _isLogin = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
        
        if(!_isLogin) {
            [[self view] addSubview:_noLoginView];
            [_noLoginView setHidden:NO];
        } else {
            
            if(_isShouldRefreshingCart) {
                [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
                [((TransactionCartViewController*)[self viewControllerAtIndex:0]) doClearAllData];
                _isShouldRefreshingCart = NO;
            } else {
                if (_cartViewController == nil) {
                    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                }
            }
            
            [_noLoginView setHidden:YES];
            
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    _isShouldRefreshingCart = NO;
}

-(void)dealloc
{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

-(void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

-(UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    id childViewController;
    _index = index;
    for (UIButton *button in _pageButtons) {
        button.backgroundColor = COLOR_DEFAULT_BUTTON;
        button.enabled = NO;
    }
    switch (index) {
        case 0:
        {
            if(!_cartViewController)
            {
                _cartViewController = [TransactionCartViewController new];
                _cartViewController.firstInit = YES;
            }
            else
            {
                _cartViewController.firstInit = NO;
            }
            _cartViewController.delegate = self;
            ((UIButton*)_pageButtons[index]).enabled = YES;
            childViewController = _cartViewController;
            [_progressView setProgress:0 animated:YES];
            ((UIButton*)_pageButtons[index]).backgroundColor = COLOR_SELECTED_BUTTON;
            self.navigationItem.leftBarButtonItem = nil;
            
            if (self.navigationController.viewControllers.count>1) {
                UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [backButton setImage:[UIImage imageNamed:@"icon_arrow_white.png"] forState:UIControlStateNormal];
                [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
                [backButton setFrame:CGRectMake(0, 0, 25, 35)];
                [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -26, 0, 0)];
                
                UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                
                backButton.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
                self.navigationItem.leftBarButtonItem = barButton;
            }
            _isShouldRefreshingCart = NO;
            if (_isLogin && self.navigationController.viewControllers.count<=1) {
                [self initNotificationManager];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.titleView = nil;
                self.navigationItem.title = @"Keranjang Belanja";
            }
            break;
        }
        case 1:
        {
            if(!_cartSummaryViewController)_cartSummaryViewController = [TransactionCartViewController new];
            _cartSummaryViewController.indexPage = 1;
            _cartSummaryViewController.data =_data;
            _cartSummaryViewController.listSummary = [_data objectForKey:DATA_CART_SUMMARY_LIST_KEY];
            _cartSummaryViewController.delegate = self;
            ((UIButton*)_pageButtons[index-1]).enabled = YES;
            ((UIButton*)_pageButtons[index-1]).backgroundColor = COLOR_SELECTED_BUTTON;
            ((UIButton*)_pageButtons[index]).enabled = YES;
            childViewController = _cartSummaryViewController;
            [_progressView setProgress:0.5 animated:YES];
            [UIView animateWithDuration:0.0 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                ((UIButton*)_pageButtons[index]).backgroundColor = COLOR_SELECTED_BUTTON;
            } completion:^(BOOL finished) {
            }];
            
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setImage:[UIImage imageNamed:@"icon_arrow_white.png"] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
            [backButton setFrame:CGRectMake(0, 0, 25, 35)];
            [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -26, 0, 0)];
            
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
            
            self.navigationItem.leftBarButtonItem = barButton;
            self.navigationItem.hidesBackButton = YES;
            
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
        case 2:
        {
            if(!_cartResultViewController)_cartResultViewController = [TransactionCartResultViewController new];
            _cartResultViewController.data = _data;
            for (UIButton *button in _pageButtons) {
                button.enabled = NO;
            }
            childViewController = _cartResultViewController;
            [_progressView setProgress:1 animated:YES];
            ((UIButton*)_pageButtons[index-1]).backgroundColor = COLOR_SELECTED_BUTTON;
            ((UIButton*)_pageButtons[index-2]).backgroundColor = COLOR_SELECTED_BUTTON;
            [UIView animateWithDuration:0.0 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                ((UIButton*)_pageButtons[index]).backgroundColor = COLOR_SELECTED_BUTTON;
            } completion:^(BOOL finished) {
            }];
            
            UIBarButtonItem *barbutton1;
            barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
            [barbutton1 setTintColor:[UIColor whiteColor]];
            [barbutton1 setTag:11];
            if (_isLogin) {
                [self initNotificationManager];
                self.navigationItem.rightBarButtonItem = barbutton1;
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
            }
            self.navigationItem.leftBarButtonItem = nil;
            
            break;
        }
        default:
            break;
    }
    ((UIButton*)_pageButtons[index]).enabled = YES;
    return (UIViewController*)childViewController;
}

#pragma mark - UIPageViewController Delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = _index;
    
    if (index == 0) {
        _index = 0;
        return nil;
    }
    
    index--;
    _index = index;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = _index;
    
    index++;
    _index = index;
    
    if (index == COUNT_CILD_VIEW_CONTROLLER) {
        _index = COUNT_CILD_VIEW_CONTROLLER;
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - Delegate
-(void)didFinishRequestCheckoutData:(NSDictionary *)data
{
    if (data) {
        _pageControlView.hidden = NO;
        _tabHeightConstraint.constant = 44;
    } else {
        _pageControlView.hidden = YES;
        _tabHeightConstraint.constant = 0;
    }
    _data = data;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:1]]
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:YES
                             completion:nil];
}

-(void)didFinishRequestBuyData:(NSDictionary *)data
{
    _data = data;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:2]]
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:YES
                             completion:nil];

}

-(void)shouldBackToFirstPage
{
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    ((TransactionCartViewController*)[self viewControllerAtIndex:0]).indexPage = 0;
    [((TransactionCartViewController*)[self viewControllerAtIndex:0]) doClearAllData];
    _isShouldRefreshingCart = YES;
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (self.navigationController.viewControllers.count > 1 && _index!=1) {
            UIViewController *destinationVC;
            if (_index == 0) {
                destinationVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
            }
            else
            {
                destinationVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
            }
            [self.navigationController popToViewController:destinationVC animated:YES];
        }
        else if (_index == 1)
        {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        }
        else{
            [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            [((TransactionCartViewController*)[self viewControllerAtIndex:0]) doClearAllData];
        }
        
    }
    else
    {
        UIButton *pageButton = (UIButton*)sender;
        if(pageButton.tag == 10) {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:pageButton.tag-10]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        } else {
            RegisterViewController *vc = [RegisterViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

-(void)tapBackButton:(id)sender
{
    if (self.navigationController.viewControllers.count > 1 && _index!=1) {
        UIViewController *destinationVC;
        if (_index == 0) {
            destinationVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
        }
        else
        {
            destinationVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
        }
        [self.navigationController popToViewController:destinationVC animated:YES];
    }
    else if (_index == 1)
    {
        [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
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

- (void)pushViewController:(id)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Notification Center
- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doRefreshingCart)
                                                 name:@"doRefreshingCart" object:nil];
    
}

- (void)doRefreshingCart {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _isLogin = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    if (_isLogin && self.navigationController.viewControllers.count<=1) {
        [self initNotificationManager];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    _isShouldRefreshingCart = YES;
}


-(void)isNodata:(BOOL)isNodata
{
    _pageControlView.hidden = isNodata;
    _containerView.hidden = isNodata;
    if (isNodata) {
        NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
        [self.view addSubview:noResultView];
    }
    else
    {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[NoResultView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    if (_isLogin && self.navigationController.viewControllers.count<=1) {
        [self initNotificationManager];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)pushVC:(TransactionCartViewController *)vc toMandiriClickPayVCwithData:(NSDictionary *)data
{
    TransactionCartFormMandiriClickPayViewController *mandiriVC = [TransactionCartFormMandiriClickPayViewController new];
    mandiriVC.data = data;
    if ([vc conformsToProtocol:@protocol(TransactionCartMandiriClickPayFormDelegate)]) {
        mandiriVC.delegate = (id <TransactionCartMandiriClickPayFormDelegate>)vc;
    }
    [self.navigationController pushViewController:mandiriVC animated:YES];
}

@end
