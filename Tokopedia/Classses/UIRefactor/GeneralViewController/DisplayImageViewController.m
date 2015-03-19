//
//  DisplayImageViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DisplayImageViewController.h"
#import "scrollViewController.h"

@interface DisplayImageViewController ()<UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    NSInteger _index;
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *pageControlView;


@end

@implementation DisplayImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    CGRect frame = self.view.frame;
    frame.origin.y -=60;
    [[self.pageController view] setFrame:frame];
    
    scrollViewController *viewControllerObject = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:viewControllerObject];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"Icon_close_white.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 50, 50, 50)];
    [self.view addSubview:closeButton];
    
    if (_imageURLStrings.count <=1) {
        [self setScrollEnabled:NO forPageViewController:_pageController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  - UIPageViewController Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(scrollViewController *)viewController indexNumber];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(scrollViewController *)viewController indexNumber];

    index++;
    
    if (index == _imageURLStrings.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (scrollViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    scrollViewController *childViewController = [[scrollViewController alloc] initWithNibName:@"scrollViewController" bundle:nil];
    childViewController.indexNumber = index;
    childViewController.imageURLString = _imageURLStrings[index];
    
    return childViewController;
    
}
- (IBAction)tap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
