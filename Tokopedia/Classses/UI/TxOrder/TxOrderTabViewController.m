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

@interface TxOrderTabViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate, TxOrderConfirmedViewControllerDelegate>
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
    
    self.title = @"Konfirmasi Pembayaran";
    
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
    _isMultipleSelect = !_isMultipleSelect;
    NSString *barButtonTitle;

    [self viewControllerAtIndex:_index];
    
    barButtonTitle = _isMultipleSelect?@"Cancel":@"Select";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:barButtonTitle style:UIBarButtonItemStylePlain target:(self) action:@selector(tapBarButton:)];
    [backBarButtonItem setTintColor:[UIColor blackColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
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
            NSString *barButtonTitle = _isMultipleSelect?@"Cancel":@"Select";
            
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:barButtonTitle style:UIBarButtonItemStylePlain target:(self) action:@selector(tapBarButton:)];
            [backBarButtonItem setTintColor:[UIColor blackColor]];
            backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
            self.navigationItem.rightBarButtonItem = backBarButtonItem;
            
            if(!_confirmationViewController)_confirmationViewController = [TxOrderConfirmationViewController new];
            ((TxOrderConfirmationViewController*)_confirmationViewController).isMultipleSelection = _isMultipleSelect;
            childViewController = _confirmationViewController;
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

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

@end
