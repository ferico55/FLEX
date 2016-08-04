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
#import "ResolutionProductList.h"
#import "ResolutionCenterCreateData.h"

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
@property (strong, nonatomic) IBOutlet UIButton *firstButton;
@property (strong, nonatomic) IBOutlet UIButton *secondButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong, nonatomic) NSMutableArray<ResolutionProductList*>* selectedProduct;
@property (strong, nonatomic) ResolutionCenterCreateData* formData;
@end

@implementation ResolutionCenterCreateViewController{
    NSInteger _currentIndex;
    UIColor* greenColor;
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
    
    
    _selectedProduct = [NSMutableArray new];
    
    [self initViewControllers];
    [self initPageIndicator];
    [self initPageControl];

}

-(void)initPageIndicator{
    greenColor = [UIColor colorWithRed:0.295 green:0.745 blue:0.295 alpha:1];
    _firstButton.layer.cornerRadius = _firstButton.frame.size.width/2;
    _firstButton.clipsToBounds = YES;
    _secondButton.layer.cornerRadius = _secondButton.frame.size.width/2;
    _secondButton.clipsToBounds = YES;
    _thirdButton.layer.cornerRadius = _thirdButton.frame.size.width/2;
    _thirdButton.clipsToBounds = YES;
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
    
    _stepOneViewController.formData = self.formData;
    _stepOneViewController.selectedProduct = self.selectedProduct;
    _stepTwoViewController.formData = self.formData;
    _stepTwoViewController.selectedProduct = self.selectedProduct;
    /*
    _stepThreeViewController.formData = self.formData;
    _stepThreeViewController.selectedProduct = self.selectedProduct;
     */
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
        [_firstButton setBackgroundColor:greenColor];
        [_progressBar setProgress:0 animated:YES];
        return _stepOneViewController;
    }else if(index == 1){
        [_secondButton setBackgroundColor:greenColor];
        [_progressBar setProgress:0.5 animated:YES];
        return _stepTwoViewController;
    }else if(index == 2){
        [_thirdButton setBackgroundColor:greenColor];
        [_progressBar setProgress:1 animated:YES];
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
