//
//  TxOrderTabViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderTabViewController.h"

#import "TxOrderConfirmationViewController.h"
#import "TxOrderConfirmedViewController.h"

#import "string_tx_order.h"

#import "TKPDPhotoPicker.h"

#import "TxOrderPaymentViewController.h"
#import "NotificationManager.h"

@interface TxOrderTabViewController ()
<
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    TxOrderConfirmedViewControllerDelegate,
    TxOrderConfirmationViewControllerDelegate,
    NotificationManagerDelegate
>
{
    NSInteger _index;
    NSDictionary *_data;
    TxOrderConfirmationViewController *_confirmationViewController;
    TxOrderConfirmedViewController *_ConfirmedViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
    BOOL _isMultipleSelect;
    BOOL _isNodata;
    BOOL _isRefresh;
    NotificationManager *_notifManager;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (weak, nonatomic) IBOutlet UIView *pageControlView;

@end

@implementation TxOrderTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _isLogin = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];

    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _segmentControl.selectedSegmentIndex = 0;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [[_pageController view] setFrame:_containerView.frame];
    
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];
    
    [[self view] addSubview:_pageControlView];
    [_pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
    
    
    _isMultipleSelect = NO;
    _isNodata = YES;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)setNotification:(Notification *)notification
{
    if (notification) {
        [self setSegmentedCotrollTitle:[NSString stringWithFormat:@"Belum Konfirmasi (%@)",notification.result.purchase.purchase_payment_conf] atIndex:0];
        [self setSegmentedCotrollTitle:[NSString stringWithFormat:@"Menunggu Verifikasi (%@)",notification.result.purchase.purchase_payment_confirm] atIndex:1];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Konfirmasi Pembayaran";

    [self reloadNotification];
    
    [AnalyticsManager trackScreenName:@"Purchase - Payment Confirmation"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @" ";

}

- (IBAction)tap:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            break;
        }
            case 1:
        {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
        default:
            break;
    }
}

-(IBAction)tapBarButton:(UIBarButtonItem*)sender
{
    if (sender.tag == TAG_BAR_BUTTON_TRANSACTION_DONE) {
        _isMultipleSelect = !_isMultipleSelect;
    }
    else
    {
        _isMultipleSelect = !_isMultipleSelect;
    }
    [self viewControllerAtIndex:_index];
    UIColor *disableColor =[UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1];
    UIColor *enableColor = [UIColor colorWithRed:66.0/255.0f green:189.0/255.0f blue:65.0/255.0f alpha:1];
    if (_isMultipleSelect)[_segmentControl setTintColor:disableColor]; else [_segmentControl setTintColor:enableColor];
    _segmentControl.enabled = !_isMultipleSelect;
}

-(void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
-(UIViewController*)viewControllerAtIndex:(NSInteger)index
{
    id childViewController;
    _index = index;
    switch (index) {
        case 0:
        {
            if (!_isMultipleSelect) {
                UIBarButtonItem *selectBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pilih" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapBarButton:)];
                [selectBarButtonItem setTintColor:[UIColor whiteColor]];
                selectBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
                if (_isNodata)
                    self.navigationItem.rightBarButtonItem = nil;
                else self.navigationItem.rightBarButtonItem = selectBarButtonItem;
                
                self.navigationItem.leftBarButtonItem = nil;
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
                UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tapBarButton:)];
                [backBarButtonItem setTintColor:[UIColor whiteColor]];
                backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
                self.navigationItem.leftBarButtonItem = backBarButtonItem;
            }
            
            if(!_confirmationViewController)_confirmationViewController = [TxOrderConfirmationViewController new];
            ((TxOrderConfirmationViewController*)_confirmationViewController).isMultipleSelection = _isMultipleSelect;
            childViewController = _confirmationViewController;
            [_confirmationViewController removeAllSelected];
            _confirmationViewController.delegate = self;
            break;
        }
        case 1:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_ConfirmedViewController)_ConfirmedViewController = [TxOrderConfirmedViewController new];
            ((TxOrderConfirmedViewController*)_ConfirmedViewController).delegate = self;
            childViewController = _ConfirmedViewController;
            _ConfirmedViewController.isRefresh = _isRefresh;
             break;
        }
        default:
            break;
    }
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
    
#define COUNT_CILD_VIEW_CONTROLLER 2
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

-(void)editPayment:(TxOrderConfirmedList*)object
{
    TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
    vc.isConfirmed = YES;
    vc.paymentID = @[object.payment_id];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)isNodata:(BOOL)isNodata
{
    if (isNodata) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else{
        if (_index == 0)
        {
            UIBarButtonItem *selectBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pilih" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapBarButton:)];
            [selectBarButtonItem setTintColor:[UIColor whiteColor]];
            selectBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
            self.navigationItem.rightBarButtonItem = selectBarButtonItem;
        }
    }
    _isNodata = isNodata;
}

-(void)successCancelOrConfirmPayment
{
    _isMultipleSelect = NO;

    [self viewControllerAtIndex:_index];
    UIColor *disableColor =[UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1];
    UIColor *enableColor = [UIColor colorWithRed:66.0/255.0f green:189.0/255.0f blue:65.0/255.0f alpha:1];
    if (_isMultipleSelect)[_segmentControl setTintColor:disableColor]; else [_segmentControl setTintColor:enableColor];
    _segmentControl.enabled = !_isMultipleSelect;
    _isRefresh = YES;
}

-(void)setIsRefresh:(BOOL)isRefresh
{
    _isRefresh = NO;
}

- (void)setSegmentedCotrollTitle:(NSString*)title atIndex:(NSInteger)index
{
    [_segmentControl setTitle:title forSegmentAtIndex:index];
}

#pragma mark - Notification Manager

- (void)initNotificationManager {
    [[self notifManager] initNotificationRequest];
}

#pragma mark - Notification delegate

- (void)reloadNotification
{
    [self initNotificationManager];
}


-(NotificationManager*)notifManager
{
    if (!_notifManager) {
        _notifManager = [NotificationManager new];
        [_notifManager setViewController:self];
        _notifManager.delegate = self;
    }
    
    return _notifManager;
}

- (void)didReceiveNotification:(Notification *)notification
{
    [self setNotification:notification];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

@end
