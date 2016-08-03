//
//  ResolutionCenterCreateViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateViewController.h"
#import "ResolutionCenterCreateStepOneViewController.h"
#import "ResolutionCenterCreateStepTwoViewController.h"
#import "ResolutionCenterCreateStepThreeViewController.h"

@interface ResolutionCenterCreateViewController ()
<
    UIPageViewControllerDelegate,
    UIPageViewControllerDataSource,
    UIScrollViewDelegate
>
@property (strong, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) ResolutionCenterCreateStepOneViewController *stepOneViewController;
@property (strong, nonatomic) ResolutionCenterCreateStepTwoViewController *stepTwoViewController;
@property (strong, nonatomic) ResolutionCenterCreateStepThreeViewController *stepThreeViewController;
@end

@implementation ResolutionCenterCreateViewController{
    NSInteger _currentIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setHidden:NO];
    
    self.title = @"Status Toko";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style: UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut" style: UIBarButtonItemStyleDone target:self action:@selector(didTapNextButton)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    
    [self initViewControllers];
    [self initPageControl];

}

-(void)initPageControl{
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    _pageController.dataSource = self;
    _pageController.delegate = self;
    
    _pageController.view.frame = _contentView.frame;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]]
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:YES
                             completion:^(BOOL finished) {
        
    }];
    
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];
    [[self view] addSubview:_pageIndicatorView];
    [_pageController didMoveToParentViewController:self];
    [self setScrollEnabled:NO forPageViewController:_pageController];
}

- (void)initViewControllers{
    _stepOneViewController = [ResolutionCenterCreateStepOneViewController new];
    _stepTwoViewController = [ResolutionCenterCreateStepTwoViewController new];
    _stepThreeViewController = [ResolutionCenterCreateStepThreeViewController new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Page View Controller Delegate
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    if(_currentIndex == 0){
        return nil;
    }else{
        _currentIndex--;
        return [self viewControllerAtIndex:_currentIndex];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if(_currentIndex == 2){
        return nil;
    }else{
        _currentIndex++;
        return [self viewControllerAtIndex:_currentIndex];
    }
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

-(UIViewController*)viewControllerAtIndex:(NSInteger)index{
    if(index == 0){
        return _stepOneViewController;
    }else if(index == 1){
        return _stepTwoViewController;
    }else if(index == 2){
        return _stepThreeViewController;
    }
    return nil;
}

- (IBAction)didTapBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)didTapNextButton{
    _currentIndex++;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:_currentIndex]]
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:YES
                             completion:nil];
}
@end
