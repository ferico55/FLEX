//
//  TKPDTabNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "controller.h"
#import "category.h"
#import "TKPDTabNavigationController.h"
#import "FilterCategoryViewController.h"
#import "SearchResultShopViewController.h"
#import "SearchResultViewController.h"
#import "Tokopedia-Swift.h"

#import "DBManager.h"
#import "SearchViewController.h"

@interface TKPDTabNavigationController () <FilterCategoryViewDelegate, SearchResultDelegate, UISearchResultsUpdating, UISearchControllerDelegate>{
    UIView *_tabbar;
    NSArray *_buttons;
    NSInteger _unloadSelectedIndex;
    NSArray *_unloadViewControllers;
    BOOL _hascatalog;
    
    UIBarButtonItem *_barbuttoncategory;
    
    NSArray *_initialCategories;
    CategoryDetail *_selectedCategory;
}

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabViewHeightConstraint;
@property (strong, nonatomic) UISearchController* searchController;


- (IBAction)tap:(UISegmentedControl *)sender;

- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarController

@implementation TKPDTabNavigationController

@synthesize viewControllers = _viewControllers;
@synthesize selectedViewController = _selectedViewController;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@dynamic contentInsetForChildController;

@synthesize container = _container;

#pragma mark -
#pragma mark Initializations

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hascatalog = NO;
        _selectedIndex = -1;
        //_navigationIndex = -1;
        _unloadSelectedIndex = -1;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
        self.view;
#pragma clang diagnostic pop
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _data = [NSMutableDictionary new];
    
    if (_unloadSelectedIndex != -1) {
        [self setViewControllers:_unloadViewControllers];
        
        _unloadSelectedIndex = -1;
        _unloadViewControllers = nil;
    }

    UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    
    if (![self isUseDynamicFilter]) {
        NSBundle* bundle = [NSBundle mainBundle];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_category_list_white" ofType:@"png"]];
        
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
        }
        else
            _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
        
        _barbuttoncategory.tag = 11;
        [_barbuttoncategory setEnabled:NO];
        
        self.navigationItem.rightBarButtonItem = _barbuttoncategory;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTabShopActive)
                                                 name:@"setTabShopActive"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeNavigationTitle:)
                                                 name:@"changeNavigationTitle"
                                               object:nil];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setSearchBar];
    if (self.navigationTitle) {
        self.navigationItem.title = [self.navigationTitle capitalizedString];
        self.searchController.searchBar.text = self.navigationTitle;
    }
    self.hidesBottomBarWhenPushed = YES;
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.hidesBottomBarWhenPushed = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _selectedViewController.view.frame = _container.bounds;
    
    // Did not remove this because of the todo
    //	UIEdgeInsets inset = [self contentInsetForContainerController];
    //
    //	UIView* tabbar;
    //	CGRect frame;
    //	tabbar = _tabbar;
    //	frame = tabbar.frame;
    //	frame.origin.y = inset.top;
    //
    //	if ([_selectedViewController isKindOfClass:[UINavigationController class]]) {	//TODO: bars
    //		UINavigationController* n = (UINavigationController*)_selectedViewController;
    //
    //		if ((n != nil) && !n.navigationBarHidden && !n.navigationBar.hidden) {
    //			CGRect rect = n.navigationBar.frame;
    //			frame = CGRectOffset(frame, 0.0f, CGRectGetHeight(rect));
    //		}
    //	}
    
    UIEdgeInsets inset = [self contentInsetForChildController];
    if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:childControllerContentInset:)])) {
        [_delegate tabBarController:self childControllerContentInset:inset];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.definesPresentationContext = NO;
    [self.searchController setActive:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.definesPresentationContext = YES;
    self.searchController.searchResultsController.view.hidden = YES;
}

- (void)setSearchBar {
    SearchViewController* resultController = [[SearchViewController alloc] init];
    resultController.presentController = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Cari produk atau toko";
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.searchController.searchBar.barTintColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;
    
    resultController.searchBar = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    
    //sometimes cancel button is missing if placed on navigation, thus it needs a wrapper #ios bugs
    UIView* searchWrapper = [[UIView alloc] initWithFrame:self.searchController.searchBar.bounds];
    [searchWrapper setBackgroundColor:[UIColor clearColor]];
    [searchWrapper addSubview:self.searchController.searchBar];
    self.searchController.searchBar.layer.borderWidth = 1;
    self.searchController.searchBar.layer.borderColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR.CGColor;
    
    [self.searchController.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(searchWrapper);
    }];
    self.navigationItem.titleView = searchWrapper;
}

#pragma mark -
#pragma mark Properties

-(void)setData:(NSDictionary *)data
{
    _data = [data mutableCopy];
    if (data) {
        NSInteger type = [[_data objectForKey:kTKPDCATEGORY_DATATYPEKEY] integerValue];
        if (type == kTKPDCATEGORY_DATATYPECATEGORYKEY) {
            self.navigationItem.title = kTKPDCONTROLLER_TITLECATEGORYKEY;
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SetHiddenSegmentController:)
                                                 name:@"setsegmentcontrol" object:nil];
    if (viewControllers != nil) {
        NSUInteger count = viewControllers.count;
        [_segmentcontrol setSelectedSegmentIndex:0];
        
        [self setViewControllers:nil animated:NO];
        
        UIViewController* c;
        for (NSInteger i = 0; i < count; i++) {
            c = viewControllers[i];
            if (c.TKPDTabNavigationItem == nil) {
                c.TKPDTabNavigationItem = (TKPDTabNavigationItemInNavVC*)c.tabBarItem;
            }
        }
        
        _viewControllers = [viewControllers copy];
        if (_unloadSelectedIndex == -1) {
            [self setSelectedIndex:0 animated:animated];
        } else {
            [self setSelectedIndex:_unloadSelectedIndex animated:animated];
        }
        
    } else {
        if (_selectedViewController != nil) {
            
            [_selectedViewController willMoveToParentViewController:nil];
            [_selectedViewController.view removeFromSuperview];
            [_selectedViewController removeFromParentViewController];
        }
        
        _viewControllers = nil;
        _selectedViewController = nil;
        _selectedIndex = -1;
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    if ((selectedViewController != nil) && (_viewControllers.count == (_buttons.count - 0)) && (selectedViewController != _selectedViewController)) {
        
        UIViewController* c;
        NSInteger i;
        
        for (i = 0; i < _viewControllers.count; i++) {
            c = _viewControllers[i];
            if (c == selectedViewController) {
                break;
            }
        }
        
        if (c != nil) {
            [self setSelectedIndex:i];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
    if (selectedIndex == _selectedIndex) return;
    
    if (_viewControllers != nil) {
        UIViewController* deselect = _selectedViewController;
        if (selectedIndex < 0) {
            selectedIndex = 0;
        }
        UIViewController* select = _viewControllers[selectedIndex];
        
        //      Did not remove this because of the todo
        //		UIEdgeInsets inset = [self contentInsetForContainerController];
        //		if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
        //
        //			UINavigationController* n = (UINavigationController*)select;
        //			if (!n.navigationBarHidden && !n.navigationBar.hidden) {
        //				selectframe.origin.y = inset.top;
        //				selectframe = CGRectZero;
        //			} else {
        //                selectframe = CGRectZero;
        //			}
        //		} else {
        //            selectframe = CGRectZero;
        //		}
        
        int navigate = 0;
        
        if (_selectedIndex < selectedIndex) {
            navigate = +1;
        } else {
            navigate = -1;
        }
        
        _selectedIndex = selectedIndex;
        _selectedViewController = _viewControllers[selectedIndex];
        
        if ([_selectedViewController isKindOfClass:[SearchResultShopViewController class]]) {
            self.navigationItem.rightBarButtonItem = nil;
        } else if ([_selectedViewController isKindOfClass:[SearchResultViewController class]]) {
            ((SearchResultViewController *)_selectedViewController).delegate = self;
            
            if (![self isUseDynamicFilter]) {
                if(_hascatalog && selectedIndex == 1){
                    self.navigationItem.rightBarButtonItem = nil;
                }else{
                    self.navigationItem.rightBarButtonItem = _barbuttoncategory;
                }
            }
        }
        
        if (animated && (deselect != nil) && (navigate != 0)) {
            
            if (deselect != nil) {
                [deselect willMoveToParentViewController:nil];
            }
            
            [self addChildViewController:select];
            
            if (navigate == 0) {
                select.view.frame = _container.bounds;	//dead code
            } else {
                if (navigate > 0) {
                    select.view.frame = CGRectOffset(_container.bounds, (CGRectGetWidth(_container.bounds)), 0.0f);
                } else {
                    select.view.frame = CGRectOffset(_container.bounds, -(CGRectGetWidth(_container.bounds)), 0.0f);
                }
            }
            
            [self transitionFromViewController:deselect toViewController:select duration:0.3 options:(0) animations:^{
                
                if (navigate != 0) {
                    if (navigate > 0) {
                        deselect.view.frame = CGRectOffset(_container.bounds, -(CGRectGetWidth(_container.bounds)), 0.0f);
                    } else {
                        deselect.view.frame = CGRectOffset(_container.bounds, (CGRectGetWidth(_container.bounds)), 0.0f);
                    }
                    select.view.frame = _container.bounds;
                }
                
                _tabbar.userInteractionEnabled = NO;	//race condition
                
            } completion:^(BOOL finished) {
                
                [deselect removeFromParentViewController];
                [select didMoveToParentViewController:self];
                
                _tabbar.userInteractionEnabled = YES;	//race condition
            }];
            
        } else {
            if (deselect != nil) {
                [deselect willMoveToParentViewController:nil];
                [deselect.view removeFromSuperview];
                [deselect removeFromParentViewController];
            }
            
            [self addChildViewController:select];
            
            select.view.frame = _container.bounds;
            
            [_container addSubview:select.view];
            [select didMoveToParentViewController:self];
        }
    }
}

-(BOOL)isUseDynamicFilter{
    if(FBTweakValue(@"Dynamic", @"Filter", @"Enabled", YES)) {
        return YES;
    } else {
        return NO;
    }
}


- (UIEdgeInsets)contentInsetForChildController
{
    UIEdgeInsets inset = [self contentInsetForContainerController];
    
    //CGRect bounds = ((UIView*)_tabbars[0]).bounds;
    CGRect bounds = _tabbar.bounds;
    inset.top += CGRectGetHeight(bounds);
    
    return inset;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
    
    NSLog(@"isViewLoaded: %@", self.isViewLoaded ? @"YES" : @"NO");
    
    if (self.isViewLoaded && (self.view.window == nil)) {
        
        _unloadSelectedIndex = _selectedIndex;
        _unloadViewControllers = _viewControllers;
        [self setViewControllers:nil];
        
        self.view = nil;
    }
    
    NSLog(@"isViewLoaded: %@", self.isViewLoaded ? @"YES" : @"NO");
}

#ifdef _DEBUG
- (void)dealloc
{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];}
#endif

#pragma mark -
#pragma mark View actions
-(IBAction)tap:(UISegmentedControl*) sender
{
    if (_viewControllers != nil) {
        
        NSInteger index = _selectedIndex;
        if ( ![[_data objectForKey:kTKPDCATEGORY_DATATYPEKEY]  isEqual: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)]) {
            switch (sender.selectedSegmentIndex) {
                    //case 1:
                case 0: {
                    index = sender.selectedSegmentIndex;
                    break;
                }
                case 1: {
                    if (_hascatalog) {
                        index = sender.selectedSegmentIndex;
                    }
                    else
                        index = sender.selectedSegmentIndex + 1;
                    break;
                }
                case 2:{
                    index = sender.selectedSegmentIndex;
                    break;
                }
                default:
                    break;
            }
        }
        else
        {
            index = sender.selectedSegmentIndex;
        }
        BOOL should = YES;
        
        if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])) {
            
            should = [_delegate tabBarController:self shouldSelectViewController:_viewControllers[index]];
        }
        
        if (should) {
            [self setSelectedIndex:index animated:NO];
            
            if (index == 1) {
                [AnalyticsManager trackEventName:@"clickSearchResult" category:GA_EVENT_CATEGORY_SEARCH_RESULT action:GA_EVENT_ACTION_CLICK label:@"Catalog"];
            } else if (index == 2) {
                [AnalyticsManager trackEventName:@"clickSearchResult" category:GA_EVENT_CATEGORY_SEARCH_RESULT action:GA_EVENT_ACTION_CLICK label:@"Shop"];
            }
            
            if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])) {
                
                [_delegate tabBarController:self didSelectViewController:_viewControllers[index]];
            }
        }
    }
}

-(IBAction)tapbutton:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                FilterCategoryViewController *controller = [FilterCategoryViewController new];
                controller.delegate = self;
                controller.categories = [_initialCategories mutableCopy];
                controller.selectedCategory = _selectedCategory;
                if ([_data objectForKey:@"department_id"]) {
                    controller.rootCategoryID = [_data objectForKey:@"department_id"]?:@"";
                    controller.filterType = FilterCategoryTypeCategory;
                } else {
                    controller.filterType = FilterCategoryTypeSearchProduct;
                }
                
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
                navigation.navigationBar.translucent = NO;
                [self.navigationController presentViewController:navigation animated:YES completion:nil];                
            }
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Methods

- (UIEdgeInsets)contentInsetForContainerController
{
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if ((self.parentViewController != nil) && [self.parentViewController respondsToSelector:@selector(contentInsetForChildController)]) {
        UIEdgeInsets bar = [((id)self.parentViewController) contentInsetForChildController];
        
        inset.top += bar.top;
        inset.bottom += bar.bottom;
        inset.left += bar.left;
        inset.right += bar.right;
        
    } else {
        UIApplication* app = [UIApplication sharedApplication];
        if (!app.statusBarHidden) {
            
            CGRect bar = app.statusBarFrame;
            CGRect view = _selectedViewController.view.frame;
            
            UINavigationController* n = (UINavigationController*)[self isChildViewControllersContainsNavigationController:self];
            if (n != nil) {
                UINavigationBar* nbar = n.navigationBar;
                //if (!n.navigationBarHidden && !nbar.hidden && nbar.translucent) {
                if ((nbar != nil) && !n.navigationBarHidden && !nbar.hidden && nbar.translucent) {
                    
                    if (_selectedViewController.view.window != nil) {	//TODO:
                        view = [_selectedViewController.view.superview convertRect:view toView:_selectedViewController.view.window];
                        NSAssert(_selectedViewController.view.window != nil, @"nil view's window");
                        
                        if (CGRectIntersectsRect(bar, view)) {
                            bar = CGRectIntersection(bar, view);
                            inset.top += CGRectGetHeight(bar);
                            inset.bottom += CGRectGetHeight(bar);
                        }
                        
                    } else if (nbar.translucent) {
                        inset.top += CGRectGetHeight(bar);
                    }
                }
            }
        }
    }
    return inset;
}

- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller
{
    NSArray* childs = controller.childViewControllers;
    for (UIViewController* c in childs) {
        if ([c isKindOfClass:[UINavigationController class]]) {
            return c;
        } else {
            return [self isChildViewControllersContainsNavigationController:c];
        }
    }
    return nil;
}

#pragma mark - Category delegate
- (void)didSelectCategory:(CategoryDetail *)category {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:self userInfo:@{@"department_id" : category.categoryId, @"department_name" : category.name?:@""}];
    [_data setObject:category.categoryId forKey:@"selected_id"];
}

#pragma mark - Notification setsegmentcontroll
-(void)SetHiddenSegmentController:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger count = [[userinfo objectForKey:@"count"] integerValue];
    
    if (count == 2) {
        
        _segmentcontrol.hidden = NO;
        [_segmentcontrol removeAllSegments];
        [_segmentcontrol insertSegmentWithTitle:@"Produk" atIndex:0 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Toko" atIndex:1 animated:NO];
        
        _hascatalog = NO;
        
        _tabbar = _segmentcontrol;
        
        if ([userinfo objectForKey:@"selectedIndex"]) {
            _selectedIndex = [[userinfo objectForKey:@"selectedIndex"] integerValue];
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
        } else {
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
        }
        
    } else if (count == 3) {	//not default to 3
        _segmentcontrol.hidden = NO;
        _tabbar = _segmentcontrol;
        
        _hascatalog = YES;
        
        [_segmentcontrol removeAllSegments];
        [_segmentcontrol insertSegmentWithTitle:@"Produk" atIndex:0 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Katalog" atIndex:1 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Toko" atIndex:2 animated:NO];
        
        if ([userinfo objectForKey:@"selectedIndex"]) {
            _selectedIndex = [[userinfo objectForKey:@"selectedIndex"] integerValue];
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
            [self tap:_segmentcontrol];
        } else {
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
        }
        
    }
    if ( [[_data objectForKey:kTKPDCATEGORY_DATATYPEKEY]  isEqual: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)] ||
        [[_data objectForKey:kTKPDHASHTAG_HOTLIST]  isEqual: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)]
        ) {
        if (count == 2) {
            _segmentcontrol.hidden = NO;
            [_segmentcontrol removeAllSegments];
            [_segmentcontrol insertSegmentWithTitle:@"Produk" atIndex:0 animated:NO];
            _tabbar = _segmentcontrol;
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
            _hascatalog = NO;
        } else if (count == 3) {	//not default to 3
            _segmentcontrol.hidden = NO;
            [_segmentcontrol removeAllSegments];
            [_segmentcontrol insertSegmentWithTitle:@"Produk" atIndex:0 animated:NO];
            [_segmentcontrol insertSegmentWithTitle:@"Katalog" atIndex:1 animated:NO];
            _tabbar = _segmentcontrol;
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
            _hascatalog = YES;
        }
    }
    
    _barbuttoncategory.enabled = YES;
    
    if (_segmentcontrol.numberOfSegments == 1) {
        _tabViewHeightConstraint.constant = 0;
    } else {
        _tabView.backgroundColor = [UIColor whiteColor];
    }
    
    if([[userinfo objectForKey:@"hide_segment"] isEqualToString:@"1"]) {
        _tabViewHeightConstraint.constant = 0;
    }
}

- (void)updateTabCategory:(CategoryDetail *)category {
    _selectedCategory = category;
}

- (void)updateCategories:(NSArray *)categories {
    if (_initialCategories == nil) {
        _initialCategories = [NSArray arrayWithArray:categories];
    }
}

- (void)setTabShopActive {
    if (_hascatalog) {
        _segmentcontrol.selectedSegmentIndex = 2;
    } else {
        _segmentcontrol.selectedSegmentIndex = 1;
    }
}
- (void)changeNavigationTitle:(NSNotification*)notification {
    NSString *title = [notification object];
    if (title) {
        self.navigationTitle = [title capitalizedString];
        self.navigationItem.title = [title capitalizedString];
        self.searchController.searchBar.text = title;
    }
}

#pragma mark - Search Controller Delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    dispatch_async(dispatch_get_main_queue(), ^{
        searchController.searchResultsController.view.hidden = NO;
    });
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
}


@end

#pragma mark -
#pragma mark UIViewController category

#import <objc/runtime.h>

@implementation UIViewController (TKPDTabNavigationController)

- (TKPDTabNavigationController*)TKPDTabNavigationController
{
    UIViewController* c = self.parentViewController;
    
    while (c != nil) {
        if ([c isKindOfClass:[TKPDTabNavigationController class]]) {
            return  (TKPDTabNavigationController*)c;
        }
        
        c = c.parentViewController;
    }
    
    return nil;
}

@dynamic TKPDTabNavigationItem;

- (TKPDTabNavigationItemInNavVC *)TKPDTabNavigationItem
{
    id o = objc_getAssociatedObject(self, @selector(TKPDTabNavigationItem));
    if (o == nil) {
        o = self.tabBarItem;
        [self setTKPDTabNavigationItem:o];
    }
    return o;
}

- (void)setTKPDTabNavigationItem:(TKPDTabNavigationItemInNavVC *)TKPDTabNavigationItem
{
    objc_setAssociatedObject(self, @selector(TKPDTabNavigationItem), TKPDTabNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
