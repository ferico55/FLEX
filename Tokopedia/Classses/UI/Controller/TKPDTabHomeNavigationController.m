//
//  TKPDTabHomeNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabHomeNavigationController.h"

@interface TKPDTabHomeNavigationController () {
	UIView* _tabbar;
	NSMutableArray* _buttons;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    
    NSMutableArray *_chevrons;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewtop;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewmenu;
@property (weak, nonatomic) IBOutlet UIButton *buttonfilter;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *tabbarthrees;
@property (weak, nonatomic) IBOutlet UIView *tabbartwos;

- (IBAction)tap:(UISegmentedControl *)sender;

- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarHomeController

@implementation TKPDTabHomeNavigationController

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
    
    _buttons = [NSMutableArray new];
    _chevrons = [NSMutableArray new];
	
	if (_unloadSelectedIndex != -1) {
		[self setViewControllers:_unloadViewControllers];
		
		_unloadSelectedIndex = -1;
		_unloadViewControllers = nil;
	}
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	//CGRect frame = _container.frame;
	//CGSize size = CGSizeMake((inset.left + inset.right) / 2.0f, (inset.top + inset.bottom) / 2.0f);
	//frame = CGRectInset(frame, size.width, size.height);
	//frame = CGRectOffset(frame, inset.left - size.width, inset.top - size.height);
	//_container.frame = frame;
	
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

- (void)setViewControllers:(NSArray *)viewControllers withtitles:(NSArray*)titles
{
	[self setViewControllers:viewControllers animated:YES withtitles:(NSArray*)titles];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated withtitles:(NSArray*)titles
{
	if (viewControllers != nil) {
        
		NSUInteger count = viewControllers.count;
        
        [self.navigationController.navigationBar setTranslucent:NO];
        
        /** for ios 7 need to set tab bar translucent **/
        if([self.tabBarController.tabBar respondsToSelector:@selector(setTranslucent:)])
        {
            [self.tabBarController.tabBar setTranslucent:NO];
        }
        
        /** for ios 7 need to set automatically adjust scrooll view inset**/
        if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        /** initialization mutable variable **/
        _buttons = [NSMutableArray new];
        
        NSInteger widthcontenttop=0;
        
        /** Adjust View to Scrollview **/
        for (int i = 0; i<count; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            UIFont * font = kTKPDHOME_FONTSLIDETITLES;
            button.titleLabel.font = font;
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            CGSize stringSize = [titles[i] sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
            CGFloat widthlabel = stringSize.width+10;
            
            button.frame = CGRectMake(widthcontenttop+6,0,widthlabel,(_scrollviewtop.frame.size.height)-30);
            button.tag = i;
            
            widthcontenttop +=widthlabel;
            
            [_buttons addObject:button];
            [_scrollviewtop addSubview:_buttons[i]];
            [_chevrons addObject:_buttons[i]];
            
        }
        _scrollviewtop.contentSize = CGSizeMake(widthcontenttop+10, 0);
		
		UIViewController* c;
		for (NSInteger i = 0; i < count; i++) {
			c = viewControllers[i];
			if (c.TKPDTabHomeNavigationItem == nil) {
				c.TKPDTabHomeNavigationItem = (TKPDTabHomeNavigationItem*)c.tabBarItem;
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
    [self AdjustPageActive];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
	[self setSelectedViewController:selectedViewController animated:YES];
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
-(IBAction)tap:(UIButton*) sender
{
	if (_viewControllers != nil) {
		
		NSInteger index = _selectedIndex;
        index = sender.tag;
        
		BOOL should = YES;
		
		if (([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])) {
			
			should  = [_delegate tabBarController:self shouldSelectViewController:_viewControllers[index]];
		}
		
		if (should) {
			[self setSelectedIndex:index animated:YES];
			
			if (([_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])) {
				
				[_delegate tabBarController:self didSelectViewController:_viewControllers[index]];
			}
		}
        [self AdjustPageActive];
	}
}

- (IBAction)gesture:(UISwipeGestureRecognizer *)sender
{
	switch (sender.state) {
		case UIGestureRecognizerStateEnded: {
			id o;
			if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
                if (_selectedIndex > 0) {
                    o = _chevrons[_selectedIndex - 1];
                    [self tap:o];
				}
			} else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
				if (_selectedIndex < _chevrons.count -1) {
                    o = _chevrons[_selectedIndex + 1];
                    [self tap:o];
                }
			}
			break;
		}
			
		default:
			break;
	}
}

#pragma mark -
#pragma mark Methods

/** adjust page active behavior **/
-(void)AdjustPageActive
{
    /** reset color button **/
    for (UIButton *btn in _buttons) {
        [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESCOLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:kTKPDHOME_FONTSLIDETITLES];
    }
    /** set button active color **/
    NSInteger index = _selectedIndex<0?0:_selectedIndex;
    UIButton *btn = (UIButton*)_buttons[index];
    [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESACTIVECOLOR forState:UIControlStateNormal];
    [btn.titleLabel setFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
    
    /** set menu slide behavior **/
    if (_selectedIndex>0 && _viewControllers.count>2) {
        CGFloat offset = 0;
        UIButton* btn1;
        UIButton* last;
        for (int i = 0; i<=_selectedIndex-1; i++) {
            btn1 = (UIButton*)_buttons[i];
            last = (UIButton*)_buttons[_selectedIndex-1];
            offset =  offset + (CGFloat)btn1.frame.size.width;
        }
        [_scrollviewtop setContentOffset:CGPointMake(offset-(((CGFloat)btn1.frame.size.width/2+10)*_selectedIndex), 0) animated:YES];
    }
    else
    {
        [_scrollviewtop setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [_scrollviewmenu setContentOffset:CGPointMake(_scrollviewmenu.frame.size.width*_selectedIndex, 0) animated:YES];
}


- (UIEdgeInsets)contentInsetForContainerController
{
	UIEdgeInsets inset = UIEdgeInsetsZero;
	
	//if (self.parentViewController && [self.parentViewController isKindOfClass:[TKPDTabBarHomeController class]]) {
	//	UIEdgeInsets bar = self.TKPDTabBarHomeController.contentInsetForChildController;
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

@end

#pragma mark -
#pragma mark UIViewController category

#import <objc/runtime.h>

@implementation UIViewController (TKPDTabHomeNavigationController)

- (TKPDTabHomeNavigationController*)TKPDTabHomeNavigationController
{
	UIViewController* c = self.parentViewController;
	
	while (c != nil) {
		if ([c isKindOfClass:[TKPDTabHomeNavigationController class]]) {
			return  (TKPDTabHomeNavigationController*)c;
		}
		
		c = c.parentViewController;
	}
	
	return nil;
}

//static void* const kTKPDTabHomeNavigationItemKey = (void*)&kTKPDTabHomeNavigationItemKey;

@dynamic TKPDTabHomeNavigationItem;

- (TKPDTabHomeNavigationItem *)TKPDTabHomeNavigationItem
{
	//return objc_getAssociatedObject(self, @selector(TKPDTabHomeNavigationItem));
	id o = objc_getAssociatedObject(self, @selector(TKPDTabHomeNavigationItem));
	
	if (o == nil) {
		o = self.tabBarItem;
		[self setTKPDTabHomeNavigationItem:o];
	}
	
	return o;
}

- (void)setTKPDTabHomeNavigationItem:(TKPDTabHomeNavigationItem *)TKPDTabHomeNavigationItem
{
	objc_setAssociatedObject(self, @selector(TKPDTabHomeNavigationItem), TKPDTabHomeNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

