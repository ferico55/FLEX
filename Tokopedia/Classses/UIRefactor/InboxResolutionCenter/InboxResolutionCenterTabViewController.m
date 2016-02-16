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
#import "AlertListFilterView.h"

@interface InboxResolutionCenterTabViewController ()<TKPDAlertViewDelegate, UIPageViewControllerDataSource,UIPageViewControllerDelegate>
{
    NSInteger _index;
    NSDictionary *_data;
    InboxResolutionCenterComplainViewController *_myComplainViewController;
    InboxResolutionCenterComplainViewController *_buyerComplainViewController;
    InboxResolutionCenterComplainViewController *_allComplainViewController;
    NSDictionary *_auth;
    BOOL _isLogin;
    
    NSInteger _filterReadIndex;
    AlertListFilterView *_filter;
    NSArray *_arrayFilterRead;
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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = _readOption.frame;
    frame.size.height = screenRect.size.height;
    frame.size.width = screenRect.size.width;
    _readOption.frame = frame;
    
    _arrayFilterRead = [self arrayFilterStringForKey:@"filter_read"];
    
    _checkListImageViews = [NSArray sortViewsWithTagInArray:_checkListImageViews];
    _filterButtons = [NSArray sortViewsWithTagInArray:_filterButtons];
    
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
    
    [self.view bringSubviewToFront:_readOption];
    
    _filterReadIndex = 0;
    
    [self setTitleButtonString:_arrayFilterRead[_filterReadIndex][@"filter_name"]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"icon_arrow_white.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 25, 35)];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -26, 0, 0)];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
}

-(NSArray *)arrayFilterStringForKey:(NSString *)key
{
    NSMutableArray<NSDictionary*> *tempArrayFilterRead = [NSMutableArray new];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    NSString *filterReadString = [gtmContainer stringForKey:key];
    NSArray *filterReadArray = [filterReadString componentsSeparatedByString:@","];
    for (NSString *filterRead in filterReadArray) {
        NSArray *filterReadDictionaryArray = [filterRead componentsSeparatedByString:@":"];
        NSDictionary *filterReadDictionary = @{
                                               @"filter_name":filterReadDictionaryArray[0],
                                               @"filter_value":filterReadDictionaryArray[1]
                                               };
        [tempArrayFilterRead addObject:filterReadDictionary];
    }
    return [tempArrayFilterRead copy];
}

-(IBAction)tapBackButton:(id)sender
{
    [_splitVC.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Pusat Resolusi";
    
    self.screenName = @"Inbox Resolution";
    [TPAnalytics trackScreenName:@"Inbox Resolution"];
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = nil;
}

- (IBAction)tap:(UISegmentedControl*)sender {
    
    UIPageViewControllerNavigationDirection direction;
    if (_index>sender.selectedSegmentIndex)
        direction = UIPageViewControllerNavigationDirectionReverse;
    else
        direction = UIPageViewControllerNavigationDirectionForward;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:sender.selectedSegmentIndex]] direction:direction animated:YES completion:nil];
    _index = sender.selectedSegmentIndex;
    
    switch (sender.selectedSegmentIndex) {
        case 2:
        {
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
        default:
            break;
    }

}

-(IBAction)tapFilterRead:(id)sender
{
    if (!_filter) {
        _filter = [AlertListFilterView newview];
        NSMutableArray *filterReadNames = [NSMutableArray new];
        for (NSDictionary *filterRead in _arrayFilterRead) {
            [filterReadNames addObject:filterRead[@"filter_name"]];
        }
        _filter.list = [filterReadNames copy];
        _filter.selectedIndex = _filterReadIndex;
        _filter.delegate = self;
        [_filter show];
    }else{
        [_filter dismissWithClickedButtonIndex:-1 animated:YES];
        _filter =nil;
    }

}

-(IBAction)tapBarButton:(UIBarButtonItem*)sender
{
    if (sender.tag == 10) {
        [self viewControllerAtIndex:_index];
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
            if(!_allComplainViewController)_allComplainViewController = [InboxResolutionCenterComplainViewController new];
            _allComplainViewController.detailViewController = _detailViewController;
            _allComplainViewController.typeComplaint = TypeComplaintAll;
            _allComplainViewController.filterReadIndex = _filterReadIndex;
            childViewController = _allComplainViewController;
            break;
        }
        case 1:
        {
            if(!_myComplainViewController)_myComplainViewController = [InboxResolutionCenterComplainViewController new];
            _detailViewController.delegate = _myComplainViewController;
            _myComplainViewController.detailViewController = _detailViewController;
            _myComplainViewController.typeComplaint = TypeComplaintMine;
            _myComplainViewController.filterReadIndex = _filterReadIndex;
            childViewController = _myComplainViewController;
            break;
        }
        case 2:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_buyerComplainViewController)_buyerComplainViewController = [InboxResolutionCenterComplainViewController new];
            _detailViewController.delegate = _buyerComplainViewController;
            _buyerComplainViewController.detailViewController = _detailViewController;
            _buyerComplainViewController.typeComplaint = TypeComplaintBuyer;
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

- (void)setTitleButtonString:(NSString*)string {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 10, 17);
    [button addTarget:self action:@selector(tapFilterRead:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 11;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, 10, 10);
    attachment.image = [UIImage imageNamed:@"icon_triangle_down_white.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.font = [UIFont fontWithName:@"Gotham Medium" size:15.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.textColor = [UIColor whiteColor];

    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",string]];
    [myString appendAttributedString:attachmentString];
    
    [button setAttributedTitle:myString forState:UIControlStateNormal];
    
    self.navigationItem.titleView = button;
}

-(void)alertView:(TKPDAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex >= 0) {
        _filterReadIndex = buttonIndex;
        [self setTitleButtonString:_arrayFilterRead[_filterReadIndex][@"filter_name"]];
    }
    _filter = nil;
    [_pageController setViewControllers:@[[self viewControllerAtIndex:_index]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

@end
