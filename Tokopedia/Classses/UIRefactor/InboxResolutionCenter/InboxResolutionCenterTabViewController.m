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
#import "GeneralTableViewController.h"

@interface InboxResolutionCenterTabViewController ()<TKPDAlertViewDelegate, UIPageViewControllerDataSource,UIPageViewControllerDelegate, ResolutionComplainDelegate, GeneralTableViewControllerDelegate>
{
    NSInteger _index;
    InboxResolutionCenterComplainViewController *_myComplainViewController;
    InboxResolutionCenterComplainViewController *_buyerComplainViewController;
    InboxResolutionCenterComplainViewController *_allComplainViewController;
    
    AlertListFilterView *_filterAlertView;
    
    NSArray *_arrayFilterRead;
    NSArray *_arrayFilterProcess;
    NSArray *_arrayFilterSort;
    
    NSDictionary *_selectedFilterRead;
    NSDictionary *_selectedFilterProcess;
    NSDictionary *_selectedFilterSort;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *pageControlView;
@property (strong, nonatomic) IBOutlet UIView *readOption;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (strong, nonatomic) IBOutlet UIButton *buttonFilter;
@property (strong, nonatomic) IBOutlet UIButton *buttonSort;

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
    
    _arrayFilterRead = [self arrayFilterStringForKey:@"filter_read"]?:@[];
    _arrayFilterSort = [self arrayFilterStringForKey:@"filter_sort"]?:@[];
    _arrayFilterProcess = [self arrayFilterStringForKey:@"filter_process"]?:@[];
    
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
    
    _selectedFilterRead = _arrayFilterRead[0];
    
    [self setTitleButtonString:_selectedFilterRead[@"filter_name"] withImage:@"icon_triangle_down_white.png"];
    
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
    NSDictionary *defaultFilter = @{@"filter_process":@"Dalam Proses:0,Komplain > 10 hari:3,Sudah Selesai:1,Semua:2",
                                    @"filter_read":@"Semua Status:0,Belum Ditanggapi:3,Belum dibaca:1",
                                    @"filter_sort":@"Waktu dibuat:2,Perubahan Terbaru:1"
                                    };
    NSString *filterString = ([[gtmContainer stringForKey:key]isEqualToString:@""])?defaultFilter[key]:[gtmContainer stringForKey:key];
    NSArray *filterArray = [filterString componentsSeparatedByString:@","];
    for (NSString *filter in filterArray) {
        if (![filter isEqualToString:@""]) {
            NSArray *filterDictionaryArray = [filter componentsSeparatedByString:@":"];
            NSDictionary *filterDictionary = @{
                                                   @"filter_name":filterDictionaryArray[0],
                                                   @"filter_value":filterDictionaryArray[1]
                                                   };
            [tempArrayFilterRead addObject:filterDictionary];
        }
    }
    return [tempArrayFilterRead copy];
}

-(IBAction)tapBackButton:(id)sender
{
    [_splitVC.navigationController popViewControllerAnimated:YES];
    [_filterAlertView dismissWithClickedButtonIndex:0 animated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Pusat Resolusi";
    
    [AnalyticsManager trackScreenName:@"Inbox Resolution"];
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_filterAlertView dismissWithClickedButtonIndex:0 animated:NO];
    self.title = nil;
}

- (IBAction)tap:(UISegmentedControl*)sender {
    [AnalyticsManager trackEventName:@"clickResolution" category:GA_EVENT_CATEGORY_INBOX_RESOLUTION action:GA_EVENT_ACTION_CLICK label:[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]];
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
    if (!_filterAlertView) {
        _filterAlertView = [AlertListFilterView newview];
        _filterAlertView.list = [self getListFilterNameFromArray:_arrayFilterRead];
        _filterAlertView.selectedObject = _selectedFilterRead[@"filter_name"];
        _filterAlertView.delegate = self;
        [self setTitleButtonString:_selectedFilterRead[@"filter_name"] withImage:@"icon_triangle_up_white.png"];

        [_filterAlertView show];
    }else{
        [self setTitleButtonString:_selectedFilterRead[@"filter_name"] withImage:@"icon_triangle_down_white.png"];
        [_filterAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        _filterAlertView =nil;
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
-(InboxResolutionCenterComplainViewController*)viewControllerAtIndex:(NSInteger)index
{
    InboxResolutionCenterComplainViewController *childViewController;
    switch (index) {
        case 0:
        {
            if(!_allComplainViewController)_allComplainViewController = [InboxResolutionCenterComplainViewController new];
            [self setDataAtViewController:_allComplainViewController];
            _allComplainViewController.typeComplaint = TypeComplaintAll;
            childViewController = _allComplainViewController;
            break;
        }
        case 1:
        {
            if(!_myComplainViewController)_myComplainViewController = [InboxResolutionCenterComplainViewController new];
            [self setDataAtViewController:_myComplainViewController];
            _myComplainViewController.typeComplaint = TypeComplaintMine;
            childViewController = _myComplainViewController;
            break;
        }
        case 2:
        {
            self.navigationItem.rightBarButtonItem = nil;
            
            if(!_buyerComplainViewController)_buyerComplainViewController = [InboxResolutionCenterComplainViewController new];
            [self setDataAtViewController:_buyerComplainViewController];
            _buyerComplainViewController.typeComplaint = TypeComplaintBuyer;
            childViewController = _buyerComplainViewController;
            break;
        }
        default:
            break;
    }
    return childViewController;
}

-(void)setDataAtViewController:(InboxResolutionCenterComplainViewController*)viewController
{
    _detailViewController.delegate = viewController;
    viewController.delegate = self;
    viewController.filterSort = [_selectedFilterSort[@"filter_value"] integerValue];
    viewController.filterProcess = [_selectedFilterProcess[@"filter_value"] integerValue];
    viewController.filterRead = [_selectedFilterRead[@"filter_value"] integerValue];
    viewController.detailViewController = _detailViewController;
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

- (void)setTitleButtonString:(NSString*)string withImage:(NSString*)imageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 10, 17);
    [button addTarget:self action:@selector(tapFilterRead:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 11;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, 10, 10);
    attachment.image = [UIImage imageNamed:imageName];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.font = [UIFont title1ThemeMedium];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.textColor = [UIColor whiteColor];

    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",string]];
    [myString appendAttributedString:attachmentString];
    
    [button setAttributedTitle:myString forState:UIControlStateNormal];
    
    self.navigationItem.titleView = button;
}

-(void)alertView:(TKPDAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex >= 0) {
        [self setTitleButtonString:_arrayFilterRead[buttonIndex][@"filter_name"] withImage:@"icon_triangle_down_white.png"];
        _selectedFilterRead = _arrayFilterRead[buttonIndex];
         [self refreshChildViewController];
    }
    _filterAlertView = nil;
    [self setTitleButtonString:_selectedFilterRead[@"filter_name"] withImage:@"icon_triangle_down_white.png"];
}

-(void)backToFirstPageWithFilterProcess:(NSInteger)filterProcess
{
    _selectedFilterProcess = _arrayFilterProcess[1];
    
    _segmentControl.selectedSegmentIndex = 0;
    _index = 0;
    _allComplainViewController.filterProcess = [_selectedFilterProcess[@"filter_value"] integerValue];
     [self refreshChildViewController];
    [_pageController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];

}

-(IBAction)tapSort:(UIButton*)button{

    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Urutkan";
    controller.delegate = self;
    controller.senderIndexPath = [NSIndexPath indexPathForRow:10 inSection:0];
    controller.objects = [self getListFilterNameFromArray:_arrayFilterSort];
    controller.selectedObject = _selectedFilterSort[@"filter_name"] ?: _arrayFilterSort[0][@"filter_name"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)tapFilter:(UIButton*)button
{
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Filter";
    controller.delegate = self;
    controller.senderIndexPath = [NSIndexPath indexPathForRow:11 inSection:0];
    controller.objects = [self getListFilterNameFromArray:_arrayFilterProcess];
    controller.selectedObject = _selectedFilterProcess[@"filter_name"]?:_arrayFilterProcess[0][@"filter_name"];
    [self.navigationController pushViewController:controller animated:YES];
}


-(NSArray *)getListFilterNameFromArray:(NSArray*)array
{
    NSMutableArray *objectNames = [NSMutableArray new];
    for (NSDictionary *filter in array) {
        [objectNames addObject:filter[@"filter_name"]];
    }
    
    return [objectNames copy];
}

#pragma mark - Delegate General View Controller
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 10) {
        for (NSDictionary *filterSort in _arrayFilterSort) {
            if ([filterSort[@"filter_name"] isEqual:object]) {
                _selectedFilterSort = filterSort;
            }
        }
    }
    if (indexPath.row == 11) {
        for (NSDictionary *filterProcess in _arrayFilterProcess) {
            if ([filterProcess[@"filter_name"] isEqual:object]) {
                _selectedFilterProcess = filterProcess;
            }
        }
    }
    
    [self refreshChildViewController];
}

-(void)refreshChildViewController
{
    [[self viewControllerAtIndex:0] refreshRequest];
    [[self viewControllerAtIndex:1] refreshRequest];
    [[self viewControllerAtIndex:2] refreshRequest];
}

@end
