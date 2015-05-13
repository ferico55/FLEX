//
//  ReputationPageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationPageViewController.h"

#import "ReputationMyProductViewController.h"
#import "ReputationMyReviewViewController.h"

@interface ReputationPageViewController () <UIPageViewControllerDelegate>


@property (strong, nonatomic) ReputationMyProductViewController *myProductReputation;
@property (strong, nonatomic) ReputationMyReviewViewController *myReputation;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentTab;

@end

@implementation ReputationPageViewController

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
    
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    [_segmentTab addTarget:self action:@selector(segmentTabAction:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    _myProductReputation = [ReputationMyProductViewController new];
    _myReputation = [ReputationMyReviewViewController new];
    
    NSArray *viewControllers = [NSArray arrayWithObject:_myProductReputation];
    [_pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    [self addChildViewController:_pageController];
    [self.view addSubview:[_pageController view]];
    
    CGRect newFrame = [[_pageController view] frame];
    newFrame.origin.y += 45;
    [_pageController view].frame = newFrame;
    
    [self setScrollEnabled:NO forPageViewController:_pageController];
    [_pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[ReputationMyProductViewController class]]) {
        return nil;
    }
    if ([viewController isKindOfClass:[ReputationMyReviewViewController class]]) {
        return _myProductReputation;
        
    }
    
    return nil;
}

#pragma mark - pageViewControllerSource Delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[ReputationMyProductViewController class]]) {
        return _myReputation;
    }
    if ([viewController isKindOfClass:[ReputationMyReviewViewController class]]) {
        return nil;
    }
    
    return nil;
}

#pragma mark - Segmented Action
- (void)segmentTabAction:(id)sender forEvent:(UIEvent *)event {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if(selectedSegment == 0) {
        [_pageController setViewControllers:@[_myProductReputation] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    } else {
        [_pageController setViewControllers:@[_myReputation] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
