//
//  TransactionCartRootViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "TransactionCartRootViewController.h"
#import "TransactionCartViewController.h"
#import "TransactionCartResultViewController.h"

@interface TransactionCartRootViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate, TransactionCartViewControllerDelegate>
{
    NSInteger _index;
    NSDictionary *_data;
    TransactionCartViewController *_cartViewController;
    TransactionCartViewController *_cartSummaryViewController;
    TransactionCartResultViewController *_cartResultViewController;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (weak, nonatomic) IBOutlet UIView *pageControlView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *pageButtons;
@end

@implementation TransactionCartRootViewController

#define COUNT_CILD_VIEW_CONTROLLER 3
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _pageButtons = [NSArray sortViewsWithTagInArray:_pageButtons];
    
    for (UIButton *button in _pageButtons) {
        button.enabled = NO;
    }
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;

    [[_pageController view] setFrame:_containerView.frame];
    _pageController.view.backgroundColor = [UIColor yellowColor];
    
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];

    [[self view] addSubview:_pageControlView];
    [_pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
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
    for (UIButton *button in _pageButtons) {
        button.enabled = NO;
    }
    switch (index) {
        case 0:
        {
            if(!_cartViewController)_cartViewController = [TransactionCartViewController new];
            _cartViewController.delegate = self;
            ((UIButton*)_pageButtons[index]).enabled = YES;
            childViewController = _cartViewController;
            break;
        }
        case 1:
        {
            if(!_cartSummaryViewController)_cartSummaryViewController = [TransactionCartViewController new];
            _cartSummaryViewController.indexPage = 1;
            _cartSummaryViewController.data =_data;
            _cartSummaryViewController.delegate = self;
            ((UIButton*)_pageButtons[index-1]).enabled = YES;
            ((UIButton*)_pageButtons[index]).enabled = YES;
            childViewController = _cartSummaryViewController;
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
    UIButton *pageButton = (UIButton*)sender;
    
    [_pageController setViewControllers:@[[self viewControllerAtIndex:pageButton.tag-10]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

@end
