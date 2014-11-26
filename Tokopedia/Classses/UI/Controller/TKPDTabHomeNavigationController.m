//
//  TKPDTabHomeNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabHomeNavigationController.h"

@interface TKPDTabHomeNavigationController () <UIScrollViewDelegate> {
	UIView *_tabbar;
	NSMutableArray* _buttons;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    NSMutableArray *_chevrons;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewtop;
@property (weak, nonatomic) IBOutlet UIView *container;

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

    UIImageView *greenArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_green.png"]];
    CGRect frame = greenArrowImageView.frame;
    frame.size.width = 13;
    frame.size.height = 13;
    frame.origin.x = (self.view.frame.size.width/2) - (frame.size.width/2);
    greenArrowImageView.frame = frame;
    [self.view addSubview:greenArrowImageView];

    [_scrollviewtop setContentInset:UIEdgeInsetsMake(0, 106.6f, 0, 106.6f)];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	_selectedViewController.view.frame = _container.bounds;
	
	UIEdgeInsets inset = [self contentInsetForContainerController];
	
	UIView *tabbar;
	CGRect frame;
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
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
                
        /** for ios 7 need to set automatically adjust scrooll view inset**/
        if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        /** initialization mutable variable **/

        [_buttons removeAllObjects];
        [_chevrons removeAllObjects];
        for (UIButton *v in [_scrollviewtop subviews]) {
            [v removeFromSuperview];
        }
        
        NSInteger widthcontenttop=0;
        
        /** Adjust View to Scrollview **/
        for (int i = 0; i<count; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            CGFloat widthlabel = (self.view.frame.size.width/3);
            button.frame = CGRectMake(widthcontenttop, 0, widthlabel, _scrollviewtop.frame.size.height+1);
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
	}
    [self adjustPageActive];
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
		
		CGRect selectframe;
        
		selectframe = _tabbar.frame;
        
		UIViewController* deselect = _selectedViewController;
		UIViewController* select = _viewControllers[selectedIndex];
		
		UIEdgeInsets inset = [self contentInsetForContainerController];
		if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
			
			UINavigationController* n = (UINavigationController*)select;
			if (!n.navigationBarHidden && !n.navigationBar.hidden) {
				
				CGRect rect = n.navigationBar.frame;
				selectframe.origin.y = inset.top;
				selectframe = CGRectZero;
			} else {
                selectframe = CGRectZero;
			}
		} else {
            selectframe = CGRectZero;
		}
		
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
	CGRect bounds = _tabbar.bounds;
	inset.top += CGRectGetHeight(bounds);
	
	return inset;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	if (self.isViewLoaded && (self.view.window == nil)) {
		_unloadSelectedIndex = _selectedIndex;
		_unloadViewControllers = _viewControllers;
		[self setViewControllers:nil];
		self.view = nil;
	}
}

#ifdef _DEBUG
- (void)dealloc
{
	NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
}
#endif

#pragma mark -
#pragma mark View actions

-(void)tap:(UIButton*) sender
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

        [self adjustPageActive];

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
-(void)adjustPageActive
{
    /** reset color button **/
    for (UIButton *btn in _buttons) {
        [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESCOLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:kTKPDHOME_FONTSLIDETITLES];
        btn.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    }

    /** set button active color **/
    NSInteger index = _selectedIndex<0?0:_selectedIndex;
    UIButton *btn = (UIButton*)_buttons[index];
    [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESACTIVECOLOR forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    
    [_scrollviewtop setContentInset:UIEdgeInsetsMake(0, 100, 0, 100)];
    
    /** set menu slide behavior **/
    if (_viewControllers.count>2) {
        CGFloat x;
        CGFloat y = 0;
        if (_selectedIndex == 0) {
            x = (self.view.frame.size.width/3);
            x = x * (-1);
        } else {
            x = (self.view.frame.size.width/3) * (_selectedIndex-1);
        }
        [_scrollviewtop setContentOffset:CGPointMake(x, y) animated:YES];
    }
    else
    {
        CGFloat x = (self.view.frame.size.width/3);
        x = x * (-1);
        [_scrollviewtop setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

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

#pragma mark - Scroll view delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    if(translation.x < 0)
    {
        //scroll to right
        UIButton *button = (UIButton*)_buttons[3];
    } else
    {
        //scroll to left
    }
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

@dynamic TKPDTabHomeNavigationItem;

- (TKPDTabHomeNavigationItem *)TKPDTabHomeNavigationItem
{
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

