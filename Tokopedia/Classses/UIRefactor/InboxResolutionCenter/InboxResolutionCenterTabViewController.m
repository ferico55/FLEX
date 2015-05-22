//
//  InboxResolutionCenterTabViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolutionCenterTabViewController.h"

#import "InboxResolutionCenterComplainViewController.h"

#import "string_inbox_resolution_center.h"

@interface InboxResolutionCenterTabViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
{
    NSInteger _index;
    NSDictionary *_data;
    InboxResolutionCenterComplainViewController *_myComplainViewController;
    InboxResolutionCenterComplainViewController *_buyerComplainViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
    
    NSInteger _filterReadIndex;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *pageControlView;
@property (strong, nonatomic) IBOutlet UIView *readOption;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *checkListImageViews;
@end

@implementation InboxResolutionCenterTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _checkListImageViews = [NSArray sortViewsWithTagInArray:_checkListImageViews];
    _filterButtons = [NSArray sortViewsWithTagInArray:_filterButtons];
    
    for (int i = 0; i<_filterButtons.count; i++) {
        [_filterButtons[i] setTitle:ARRAY_FILTER_UNREAD[i] forState:UIControlStateNormal];
    }
    
    for (UIImageView *image in _checkListImageViews) {
        image.hidden = YES;
    }
    
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
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    
    [self.view addSubview:_readOption];
    
    _filterReadIndex = 0;
    [self updateCheckList];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Pusat Resolusi";
    self.screenName = @"Inbox Resolution";
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = nil;
}

- (IBAction)tap:(UISegmentedControl*)sender {
    _index = sender.selectedSegmentIndex;
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            [self updateCheckList];
            break;
        }
        case 1:
        {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
            self.navigationItem.rightBarButtonItem = nil;
            [self updateCheckList];
            break;
        }
        default:
            break;
    }

}
- (IBAction)tapButton:(UIButton*)sender {
    
    _filterReadIndex = sender.tag-10;
    if(_readOption.isHidden) {
        
        _verticalSpaceButtons.constant = -131;
        
        CGRect frame = _buttonsContainer.frame;
        frame.origin.y = -131;
        _buttonsContainer.frame = frame;
        
        _readOption.hidden = NO;
        _readOption.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            _readOption.alpha = 1;
        }];
        
        _verticalSpaceButtons.constant = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = 0;
            _buttonsContainer.frame = frame;
        }];
    } else {
        [_pageController setViewControllers:@[[self viewControllerAtIndex:_index]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        _verticalSpaceButtons.constant = -131;
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = -131;
            _buttonsContainer.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _readOption.alpha = 0;
            } completion:^(BOOL finished) {
                _readOption.hidden = YES;
            }];
        }];
    }
    [self updateCheckList];
}

-(IBAction)tapBarButton:(UIBarButtonItem*)sender
{
    if (sender.tag == 10) {
        [self viewControllerAtIndex:_index];
    }
    if ( sender.tag == 11) {
        if(_readOption.isHidden) {
            
            _verticalSpaceButtons.constant = -131;
            
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = -131;
            _buttonsContainer.frame = frame;
            
            _readOption.hidden = NO;
            _readOption.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                _readOption.alpha = 1;
            }];
            
            _verticalSpaceButtons.constant = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _buttonsContainer.frame;
                frame.origin.y = 0;
                _buttonsContainer.frame = frame;
            }];
        } else {
            [_pageController setViewControllers:@[[self viewControllerAtIndex:_index]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
            _verticalSpaceButtons.constant = -131;
            
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = _buttonsContainer.frame;
                frame.origin.y = -131;
                _buttonsContainer.frame = frame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    _readOption.alpha = 0;
                } completion:^(BOOL finished) {
                    _readOption.hidden = YES;
                }];
            }];
        }
    }
}
- (IBAction)gesture:(id)sender {
    if(_readOption.isHidden) {
        
        _verticalSpaceButtons.constant = -131;
        
        CGRect frame = _buttonsContainer.frame;
        frame.origin.y = -131;
        _buttonsContainer.frame = frame;
        
        _readOption.hidden = NO;
        _readOption.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            _readOption.alpha = 1;
        }];
        
        _verticalSpaceButtons.constant = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = 0;
            _buttonsContainer.frame = frame;
        }];
    } else {
        [_pageController setViewControllers:@[[self viewControllerAtIndex:_index]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        
        _verticalSpaceButtons.constant = -131;
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = -131;
            _buttonsContainer.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _readOption.alpha = 0;
            } completion:^(BOOL finished) {
                _readOption.hidden = YES;
            }];
        }];
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
            _myComplainViewController.filterReadIndex = _filterReadIndex;
            childViewController = _myComplainViewController;
            break;
        }
        case 1:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_buyerComplainViewController)_buyerComplainViewController = [InboxResolutionCenterComplainViewController new];
            _buyerComplainViewController.isMyComplain = NO;
            _buyerComplainViewController.filterReadIndex = _filterReadIndex;
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

-(void)updateCheckList
{
    for (UIImageView *image in _checkListImageViews) {
        image.hidden = YES;
    }
    ((UIButton*)_checkListImageViews[_filterReadIndex]).hidden = NO;
    [self setTitleButtonString:ARRAY_FILTER_UNREAD[_filterReadIndex]];

}

- (void)setTitleButtonString:(NSString*)string {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 10, 17);
    [button addTarget:self action:@selector(tapBarButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 11;
    
    NSString *title = [NSString stringWithFormat:@"%@",string];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize: 16.0f]
                           range:NSMakeRange(0, [string length])];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.font = [UIFont systemFontOfSize: 11.0f];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setAttributedTitle:attributedText forState:UIControlStateNormal];
    UIImage *arrowImage = [UIImage imageNamed:@"icon_triangle_down_white.png"];
    
    CGRect rect = CGRectMake(0,0,10,7);
    UIGraphicsBeginImageContext( rect.size );
    [arrowImage drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    
    [button setImage:img forState:UIControlStateNormal];
    
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 115, 0, -10);
    
    self.navigationItem.titleView = button;
}


@end
