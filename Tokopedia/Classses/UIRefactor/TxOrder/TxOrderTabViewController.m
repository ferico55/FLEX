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

#import "camera.h"
#import "CameraController.h"

#import "TxOrderPaymentViewController.h"

@interface TxOrderTabViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate, TxOrderConfirmedViewControllerDelegate, TxOrderConfirmationViewControllerDelegate>
{
    NSInteger _index;
    NSDictionary *_data;
    TxOrderConfirmationViewController *_confirmationViewController;
    TxOrderConfirmedViewController *_ConfirmedViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
    BOOL _isMultipleSelect;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (weak, nonatomic) IBOutlet UIView *pageControlView;

@end

@implementation TxOrderTabViewController

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
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Konfirmasi Pembayaran";
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
    UIColor *enableColor = [UIColor colorWithRed:0/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1];
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
    switch (index) {
        case 0:
        {
            if (!_isMultipleSelect) {
                UIBarButtonItem *selectBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pilih" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapBarButton:)];
                [selectBarButtonItem setTintColor:[UIColor whiteColor]];
                selectBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
                self.navigationItem.rightBarButtonItem = selectBarButtonItem;
            }
            else
                self.navigationItem.rightBarButtonItem = nil;
            
            if (_isMultipleSelect) {
                UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tapBarButton:)];
                [backBarButtonItem setTintColor:[UIColor whiteColor]];
                backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
                self.navigationItem.leftBarButtonItem = backBarButtonItem;
            }
            else self.navigationItem.leftBarButtonItem = nil;
            
            if(!_confirmationViewController)_confirmationViewController = [TxOrderConfirmationViewController new];
            ((TxOrderConfirmationViewController*)_confirmationViewController).isMultipleSelection = _isMultipleSelect;
            //((TxOrderConfirmationViewController*)_confirmationViewController).isSelectAll = _isSelectAll;
            childViewController = _confirmationViewController;
            _confirmationViewController.delegate = self;
            break;
        }
        case 1:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_ConfirmedViewController)_ConfirmedViewController = [TxOrderConfirmedViewController new];
            ((TxOrderConfirmedViewController*)_ConfirmedViewController).delegate = self;
            childViewController = _ConfirmedViewController;
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

-(void)uploadProof
{
    CameraController* c = [CameraController new];
    [c snap];
    c.delegate = _ConfirmedViewController;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
    nav.wantsFullScreenLayout = YES;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:nav animated:YES completion:nil];

}

-(void)editPayment:(TxOrderConfirmedList*)object
{
    TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
    vc.isConfirmed = YES;
    vc.paymentID = object.payment_id;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)isNodata:(BOOL)isNodata
{
    if (isNodata) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

@end
