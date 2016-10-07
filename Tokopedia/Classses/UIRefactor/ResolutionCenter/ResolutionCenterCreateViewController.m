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
#import "ResolutionCenterCreateData.h"
#import "ResolutionCenterCreateResult.h"
#import "NavigateViewController.h"

@interface ResolutionCenterCreateViewController ()
<
    UIPageViewControllerDelegate,
    UIPageViewControllerDataSource,
    UIScrollViewDelegate,
ResolutionCenterCreateStepThreeDelegate
>
@property (strong, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

//TODO: should use UINavigationController instead to control navigation
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) ResolutionCenterCreateStepOneViewController *stepOneViewController;
@property (strong, nonatomic) ResolutionCenterCreateStepTwoViewController *stepTwoViewController;
@property (strong, nonatomic) ResolutionCenterCreateStepThreeViewController *stepThreeViewController;
@property (strong, nonatomic) IBOutlet UIButton *firstButton;
@property (strong, nonatomic) IBOutlet UIButton *secondButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *invoiceButton;
@property (strong, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (strong, nonatomic) ResolutionCenterCreateResult* result;
@end

@implementation ResolutionCenterCreateViewController{
    NSInteger _currentIndex;
    UIColor* greenColor;
    UIColor* grayColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setHidden:NO];

    self.title = @"Buka Komplain";
    [self changeBackButtonToBatal];
   
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut" style: UIBarButtonItemStyleDone target:self action:@selector(didTapNextButton)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    _result = [[ResolutionCenterCreateResult alloc]init];
    
    [self initViewControllers];
    [self initPageIndicator];
    [self initPageControl];

    [_shopNameLabel setText:[NSString stringWithFormat:@"Pembelian dari %@", _order.order_shop.shop_name]];
    [_invoiceButton setTitle:_order.order_detail.detail_invoice forState:UIControlStateNormal];
}

-(void)initPageIndicator{
    greenColor = [UIColor colorWithRed:0.295 green:0.745 blue:0.295 alpha:1];
    grayColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
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
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0 isGoingForward:NO]]
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
    
    
    _stepOneViewController.result = self.result;
    _stepOneViewController.order = self.order;
    _stepOneViewController.product_is_received = _product_is_received;
    
    _stepOneViewController.type  = _type;
    
    _stepOneViewController.resolutionID = _resolutionID;
    
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
        return [self viewControllerAtIndex:_currentIndex isGoingForward:NO];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    if(_currentIndex == 2){
        return nil;
    }else{
        _currentIndex++;
        return [self viewControllerAtIndex:_currentIndex isGoingForward:YES];
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

-(UIViewController*)viewControllerAtIndex:(NSInteger)index isGoingForward:(BOOL)isGoingForward{
    if(index == 0){
        [_firstButton setBackgroundColor:greenColor];
        [_secondButton setBackgroundColor:grayColor];
        [_thirdButton setBackgroundColor:grayColor];
        [_progressBar setProgress:0 animated:YES];
        return _stepOneViewController;
    }else if(index == 1){
        [_firstButton setBackgroundColor:greenColor];
        [_secondButton setBackgroundColor:greenColor];
        [_thirdButton setBackgroundColor:grayColor];
        [_progressBar setProgress:0.5 animated:YES];
        
        if (isGoingForward) {
            _stepTwoViewController = [ResolutionCenterCreateStepTwoViewController new];
            _stepTwoViewController.result = self.result;
            _stepTwoViewController.order = self.order;
            _stepTwoViewController.type  = _type;
        }
        _stepTwoViewController.shouldFlushOptions = isGoingForward;
        return _stepTwoViewController;
    }else if(index == 2){
        [_firstButton setBackgroundColor:greenColor];
        [_secondButton setBackgroundColor:greenColor];
        [_thirdButton setBackgroundColor:greenColor];
        [_progressBar setProgress:1 animated:YES];
        
        if (isGoingForward) {
            _stepThreeViewController = [ResolutionCenterCreateStepThreeViewController new];
            _stepThreeViewController.result = self.result;
            _stepThreeViewController.product_is_received = _product_is_received;
            _stepThreeViewController.delegate = self;
        }
        return _stepThreeViewController;
    }
    return nil;
}

- (IBAction)didTapBackButton{
    if(_currentIndex == 0){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        if(_currentIndex == 1) {
            [self changeBackButtonToBatal];
        }
        _currentIndex--;
        [_pageController setViewControllers:@[[self viewControllerAtIndex:_currentIndex isGoingForward:NO]]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:nil];
    }
}
- (IBAction)onTapInvoice:(id)sender {
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_result.formData.form.order_pdf_url];
}

- (IBAction)didTapNextButton{
    if(_currentIndex == 2){
        [_stepThreeViewController submitCreateResolution];
    }else if(_currentIndex == 1){
        if([_stepTwoViewController verifyForm]){
            _currentIndex++;
            [_pageController setViewControllers:@[[self viewControllerAtIndex:_currentIndex isGoingForward:YES]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
        }
    }else{
        if([_stepOneViewController.result.postObject.category_trouble_id isEqualToString:@"2"] ||
           [_stepOneViewController.result.postObject.category_trouble_id isEqualToString:@"3"] ||
           _stepOneViewController.result.selectedProduct.count > 0) {
            [self changeBackButtonToArrow];
            _currentIndex++;
            [_pageController setViewControllers:@[[self viewControllerAtIndex:_currentIndex isGoingForward:YES]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
        } else if(!_stepOneViewController.result.postObject.category_trouble_id) {
            [StickyAlertView showErrorMessage:@[@"Mohon pilih masalah terlebih dahulu"]];
        } else {
            [StickyAlertView showErrorMessage:@[@"Mohon pilih produk yang bermasalah terlebih dahulu"]];
        }
    }
}

-(void)didFinishCreateComplainInStepThree{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_delegate didFinishCreateComplain];
}

#pragma mark - Customize Back Button Item

-(void) changeBackButtonToArrow {
    UIImage *backImage = [UIImage imageNamed:@"icon_arrow_white"];
    UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customBackButton.frame = CGRectMake(-100, 0, 20, 20);
    [customBackButton setBackgroundImage:backImage forState:UIControlStateNormal];
    
    [customBackButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"q" style:UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton)];
    backButtonItem.customView = customBackButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

-(void) changeBackButtonToBatal {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style: UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
}

@end
