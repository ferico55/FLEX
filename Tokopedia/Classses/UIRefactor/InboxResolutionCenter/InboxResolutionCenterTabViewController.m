//
//  InboxResolutionCenterTabViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolutionCenterTabViewController.h"

#import "InboxResolutionCenterComplainViewController.h"

@interface InboxResolutionCenterTabViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
{
    NSInteger _index;
    NSDictionary *_data;
    InboxResolutionCenterComplainViewController *_myComplainViewController;
    InboxResolutionCenterComplainViewController *_buyerComplainViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *pageControlView;

@end

@implementation InboxResolutionCenterTabViewController

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
    
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:(self) action:@selector(back:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Konfirmasi Pembayaran";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = nil;
}

-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self viewControllerAtIndex:_index];
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
            if(!_myComplainViewController)_myComplainViewController = [InboxResolutionCenterComplainViewController new];
            _myComplainViewController.isMyComplain = YES;
            childViewController = _myComplainViewController;
            break;
        }
        case 1:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_buyerComplainViewController)_buyerComplainViewController = [InboxResolutionCenterComplainViewController new];
            childViewController = _buyerComplainViewController;
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


@end
