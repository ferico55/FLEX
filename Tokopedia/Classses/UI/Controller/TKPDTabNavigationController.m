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
#import "CategoryMenuViewController.h"

@interface TKPDTabNavigationController () {
	UIView* _tabbar;
	NSArray* _buttons;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    BOOL _hascatalog;
    
    UIBarButtonItem *_barbuttoncategory;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonlocation;

@property (weak, nonatomic) IBOutlet UIButton *buttonfilter;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *tabbarthrees;
@property (weak, nonatomic) IBOutlet UIView *tabbartwos;
@property (weak, nonatomic) IBOutlet UIView *catalogproductbuttonview;
@property (weak, nonatomic) IBOutlet UIView *shopbuttonview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol;
@property (weak, nonatomic) IBOutlet UIView *viewtop;

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
@synthesize tabbarthrees = _tabbarthrees;
@synthesize tabbartwos = _tabbartwos;

#pragma mark -
#pragma mark Factory methods

//+ (id)allocinit
//{
//	id o = [[self class] alloc];
//	if (o != nil) {
//		o = [o initWithNibName:nil bundle:nil];
//		return o;
//	}
//	return nil;
//}

#pragma mark -
#pragma mark Initializations

//- (id)init
//{
//	return [self initWithNibName:nil bundle:nil];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hascatalog = YES;
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
    
    self.navigationItem.title = kTKPDCONTROLLER_TITLESEARCHKEY;
    
	if (_unloadSelectedIndex != -1) {
		[self setViewControllers:_unloadViewControllers];
		
		_unloadSelectedIndex = -1;
		_unloadViewControllers = nil;
        }
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    //TODO:: Change image
    //if ([[_data objectForKey:kTKPDCONTROLLER_DATATYPEKEY]  isEqual: @(kTKPDCONTROLLER_DATATYPECATEGORYKEY)]) {
        img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONMORECATEGORY ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
        }
        else
            _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
        [_barbuttoncategory setTag:11];
        [_barbuttoncategory setEnabled:NO];
        self.navigationItem.rightBarButtonItem = _barbuttoncategory;
    //}
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	_selectedViewController.view.frame = _container.bounds;
	
	UIEdgeInsets inset = [self contentInsetForContainerController];
	
	UIView* tabbar;
	CGRect frame;
	//if (_selectedIndex < 3) {
	//	tabbar = _tabbars[0];
	//} else {
	//	tabbar = _tabbars[1];
	//}
	tabbar = _tabbar;
	frame = tabbar.frame;
	frame.origin.y = inset.top;
	
	if ([_selectedViewController isKindOfClass:[UINavigationController class]]) {	//TODO: bars
		UINavigationController* n = (UINavigationController*)_selectedViewController;
		
		if ((n != nil) && !n.navigationBarHidden && !n.navigationBar.hidden) {
			CGRect rect = n.navigationBar.frame;
			frame = CGRectOffset(frame, 0.0f, CGRectGetHeight(rect));
		}
	}
	//tabbar.frame = frame;
	
	inset = [self contentInsetForChildController];
	if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:childControllerContentInset:)])) {
		[_delegate tabBarController:self childControllerContentInset:inset];
	}
}

#pragma mark -
#pragma mark Properties

-(void)setData:(NSDictionary *)data
{
    _data = data;
    
    if (data) {
        if ( [[_data objectForKey:kTKPDCATEGORY_DATATYPEKEY]  isEqual: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)])
            self.navigationItem.title = kTKPDCONTROLLER_TITLECATEGORYKEY;
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
//		if (count == 2) {
//			_tabbar = _tabbartwos;
//			_tabbar.hidden = NO;
//			_tabbarthrees.hidden = YES;
//			
//		} else if (count == 3) {	//not default to 3
//			_tabbar = _tabbarthrees;
//			_tabbar.hidden = NO;
//			_tabbartwos.hidden = YES;
//			
//		} else {
//			_tabbar = nil;
//			_tabbarthrees.hidden = YES;
//			_tabbartwos.hidden = YES;
//		}

		[self setViewControllers:nil animated:NO];
		
//		if (count == 2) {
//			_tabbar = _tabbartwos;
//			_tabbar.hidden = NO;
//			_tabbarthrees.hidden = YES;
//			
//		} else if (count == 3) {	//not default to 3
//			_tabbar = _tabbarthrees;
//			_tabbar.hidden = NO;
//			_tabbartwos.hidden = YES;
//			
//		} else {
//			_tabbar = nil;
//			_tabbarthrees.hidden = YES;
//			_tabbartwos.hidden = YES;
//		}
		
		UIViewController* c;
		for (NSInteger i = 0; i < count; i++) {
			c = viewControllers[i];
			if (c.TKPDTabNavigationItem == nil) {
				c.TKPDTabNavigationItem = (TKPDTabNavigationItem*)c.tabBarItem;
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
		//_navigationIndex = -1;
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
		
		//UIView* selecttabbar;
		CGRect selectframe;
        
		//selecttabbar = _tabbar;
		selectframe = _tabbar.frame;
		
		UIViewController* deselect = _selectedViewController;
		UIViewController* select = _viewControllers[selectedIndex];
		
		UIEdgeInsets inset = [self contentInsetForContainerController];
		if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
			
			UINavigationController* n = (UINavigationController*)select;
			if (!n.navigationBarHidden && !n.navigationBar.hidden) {
				
				CGRect rect = n.navigationBar.frame;
				//rect = [self.view convertRect:rect fromView:n.navigationBar.superview];
				//(*selectframe).origin.y = CGRectGetMaxY(rect);
				selectframe.origin.y = inset.top;
				//selectframe = CGRectOffset(selectframe, 0.0f, CGRectGetHeight(rect));
				selectframe = CGRectZero;
			} else {
				//selectframe.origin.y = inset.top;
                selectframe = CGRectZero;
			}
		} else {
            selectframe = CGRectZero;
			//selectframe.origin.y = inset.top;
		}
		
		//selecttabbar.frame = selectframe;
		
		int navigate = 0;

		if (_selectedIndex < selectedIndex) {
			navigate = +1;
		} else {
			navigate = -1;
		}
		
		_selectedIndex = selectedIndex;
		_selectedViewController = _viewControllers[selectedIndex];
				
		if (animated && (deselect != nil) && (navigate != 0)) {
			
			if (deselect != nil) {
				[deselect willMoveToParentViewController:nil];
				//[deselect.view removeFromSuperview];
				//[deselect removeFromParentViewController];
			}
			
			[self addChildViewController:select];
			//select.view.frame = _container.bounds;
			
			if (navigate == 0) {
				select.view.frame = _container.bounds;	//dead code
			} else {
				if (navigate > 0) {
					select.view.frame = CGRectOffset(_container.bounds, (CGRectGetWidth(_container.bounds)), 0.0f);
				} else {
					select.view.frame = CGRectOffset(_container.bounds, -(CGRectGetWidth(_container.bounds)), 0.0f);
				}
			}
			
			[self transitionFromViewController:deselect toViewController:select duration:0.3 options:(0 /*UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft*/) animations:^{
				
				if (navigate != 0) {
					//tabbar0.frame = frame0;
					//tabbar1.frame = frame1;
					
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
	NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
}
#endif

#pragma mark -
#pragma mark View actions
-(IBAction)tap:(UISegmentedControl*) sender
{
	if (_viewControllers != nil) {
		
		NSInteger index = _selectedIndex;
        
        switch (sender.selectedSegmentIndex) {
            //case 1:
            case 0: {
                //if (_selectedIndex > 2) {
                //	index = (_navigationIndex != -1) ? _navigationIndex : 0;
                //}
                //if (_selectedIndex > 0) {
                //    index = _selectedIndex - 1;
                //} else {
                //    index = 0;
                //}
                index = sender.selectedSegmentIndex;
                break;
            }
            case 1: {
                //if (_selectedIndex < 3) {
                //	index = (_navigationIndex != -1) ? _navigationIndex : 3;
                //}
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
    
		BOOL should = YES;
		
		if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])) {
			
			should = [_delegate tabBarController:self shouldSelectViewController:_viewControllers[index]];
		}
		
		if (should) {
			[self setSelectedIndex:index animated:NO];
			
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
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                NSInteger d_id = [[_data objectForKey:kTKPDCONTROLLER_DATADEPARTMENTIDKEY] integerValue];
                vc.data = @{kTKPDCONTROLLER_DATADEPARTMENTIDKEY:@(d_id)};
                [self.navigationController pushViewController:vc animated:YES];
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
	
	//if (self.parentViewController && [self.parentViewController isKindOfClass:[TKPDTabBarController class]]) {
	//	UIEdgeInsets bar = self.TKPDTabBarController.contentInsetForChildController;
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

#pragma mark - Notification setsegmentcontroll
-(void)SetHiddenSegmentController:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger count = [[userinfo objectForKey:@"count"]integerValue];
    
    if (count == 2) {
        _segmentcontrol.hidden = NO;
        [_segmentcontrol removeAllSegments];
        [_segmentcontrol insertSegmentWithTitle:@"Product" atIndex:0 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Shop" atIndex:1 animated:NO];
        _tabbar = _segmentcontrol;
        [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
        //_tabbar.hidden = NO;
        //_tabbarthrees.hidden = YES;
        //_hascatalog = NO;
        _catalogproductbuttonview.hidden = NO;
    } else if (count == 3) {	//not default to 3
        _segmentcontrol.hidden = NO;
        [_segmentcontrol removeAllSegments];
        [_segmentcontrol insertSegmentWithTitle:@"Product" atIndex:0 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Catalog" atIndex:1 animated:NO];
        [_segmentcontrol insertSegmentWithTitle:@"Shop" atIndex:2 animated:NO];
        _tabbar = _segmentcontrol;
        [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
        //_tabbar.hidden = NO;
        //_tabbartwos.hidden = YES;
        //_hascatalog = YES;
    }
    if ( [[_data objectForKey:kTKPDCATEGORY_DATATYPEKEY]  isEqual: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)]) {
        if (count == 2) {
            _segmentcontrol.hidden = NO;
            [_segmentcontrol removeAllSegments];
            [_segmentcontrol insertSegmentWithTitle:@"Product" atIndex:0 animated:NO];
            _tabbar = _segmentcontrol;
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
            //_tabbar.hidden = NO;
            //_tabbarthrees.hidden = YES;
            //_hascatalog = NO;
            _catalogproductbuttonview.hidden = NO;
        } else if (count == 3) {	//not default to 3
            _segmentcontrol.hidden = NO;
            [_segmentcontrol removeAllSegments];
            [_segmentcontrol insertSegmentWithTitle:@"Product" atIndex:0 animated:NO];
            [_segmentcontrol insertSegmentWithTitle:@"Catalog" atIndex:1 animated:NO];
            _tabbar = _segmentcontrol;
            [_segmentcontrol setSelectedSegmentIndex:_selectedIndex];
            //_tabbar.hidden = NO;
            //_tabbartwos.hidden = YES;
            //_hascatalog = YES;
        }
    }
    _barbuttoncategory.enabled = YES;
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

//static void* const kTKPDTabNavigationItemKey = (void*)&kTKPDTabNavigationItemKey;

@dynamic TKPDTabNavigationItem;

- (TKPDTabNavigationItem *)TKPDTabNavigationItem
{
	//return objc_getAssociatedObject(self, @selector(TKPDTabNavigationItem));
	id o = objc_getAssociatedObject(self, @selector(TKPDTabNavigationItem));
	
	if (o == nil) {
		o = self.tabBarItem;
		[self setTKPDTabNavigationItem:o];
	}
	
	return o;
}

- (void)setTKPDTabNavigationItem:(TKPDTabNavigationItem *)TKPDTabNavigationItem
{
	objc_setAssociatedObject(self, @selector(TKPDTabNavigationItem), TKPDTabNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

