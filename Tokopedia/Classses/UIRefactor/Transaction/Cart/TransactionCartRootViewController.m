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
    
    NotificationManager *_notifManager;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *noLoginView;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIView *pageControlView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *pageButtons;
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
    
    
    
    
    
    _pageButtons = [NSArray sortViewsWithTagInArray:_pageButtons];

    for (UIButton *button in _pageButtons) {
        //button.enabled = NO;
        button.backgroundColor = COLOR_DEFAULT_BUTTON;
        button.layer.cornerRadius = button.frame.size.width/2;
        button.clipsToBounds=YES;
    }
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;

    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [[_pageController view] setFrame:_containerView.frame];
    
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];

    [[self view] addSubview:_pageControlView];
    [_pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _isLogin = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    
    if(!_isLogin) {
        [[self view] addSubview:_noLoginView];
        [_noLoginView setHidden:NO];
    } else {
        [_noLoginView setHidden:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    for (UIButton *button in _pageButtons) {
        button.backgroundColor = COLOR_DEFAULT_BUTTON;
        //button.enabled = NO;
    }
    switch (index) {
        case 0:
        {
            if(!_cartViewController)_cartViewController = [TransactionCartViewController new];
            //TransactionCartViewController *cartViewController = [TransactionCartViewController new];
            _cartViewController.delegate = self;
            ((UIButton*)_pageButtons[index]).enabled = YES;
            childViewController = _cartViewController;
            [_progressView setProgress:0 animated:YES];
            ((UIButton*)_pageButtons[index]).backgroundColor = COLOR_SELECTED_BUTTON;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil; //TODO::
            break;
        }
        case 1:
        {
            if(!_cartSummaryViewController)_cartSummaryViewController = [TransactionCartViewController new];
            _cartSummaryViewController.indexPage = 1;
            _cartSummaryViewController.data =_data;
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
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
            [backBarButtonItem setTintColor:[UIColor whiteColor]];
            backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
            self.navigationItem.leftBarButtonItem = backBarButtonItem;
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
            [barbutton1 setTintColor:[UIColor blackColor]];
            [barbutton1 setTag:11];
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = barbutton1;
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

#pragma mark -   Delegate
-(void)didFinishRequestCheckoutData:(NSDictionary *)data
{
    _data = data;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)didFinishRequestBuyData:(NSDictionary *)data
{
    _data = data;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

}

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            UIBarButtonItem *barbutton = (UIBarButtonItem*)sender;
            ((TransactionCartViewController*)[self viewControllerAtIndex:0]).shouldRefresh = !(barbutton.tag == TAG_BAR_BUTTON_TRANSACTION_BACK);
        }
    }
    else
    {
        UIButton *pageButton = (UIButton*)sender;
        [_pageController setViewControllers:@[[self viewControllerAtIndex:pageButton.tag-10]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
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

- (void)reloadNotification
{
    [self initNotificationManager];
}

#pragma mark - Notification delegate

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

@end
