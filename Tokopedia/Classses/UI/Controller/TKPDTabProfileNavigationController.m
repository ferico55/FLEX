//
//  TKPDTabProfileNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "detail.h"

#import "ProfileInfo.h"

#import "TKPDTabProfileNavigationController.h"
#import "SortViewController.h"
#import "ProductEtalaseViewController.h"

@interface TKPDTabProfileNavigationController () <UIScrollViewDelegate> {
	UIView* _tabbar;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    
    NSArray *_chevrons;
    
    UIBarButtonItem *_barbuttoninfo;
    
    NSInteger _pagedetail;
    
    ProfileInfo *_profileinfo;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actpp;

@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *contentview;

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *tapview;

@property (weak, nonatomic) IBOutlet UIImageView *thumb;

@property (weak, nonatomic) IBOutlet UIView *headerview;

- (IBAction)tap:(UIButton* )sender;

- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarProfileController

@implementation TKPDTabProfileNavigationController

@synthesize viewControllers = _viewControllers;
@synthesize selectedViewController = _selectedViewController;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@dynamic contentInsetForChildController;

@synthesize container = _container;

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
        
        _requestcount = 0;
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _buttons = [NSArray sortViewsWithTagInArray:_buttons];
    _chevrons = _buttons;
	
	if (_unloadSelectedIndex != -1) {
		[self setViewControllers:_unloadViewControllers];
		
		_unloadSelectedIndex = -1;
		_unloadViewControllers = nil;
	}
    
    CGSize size =_contentview.frame.size;
    size.height = size.height - _tapview.frame.size.height-64;
    _scrollview.contentSize = size;
    
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
    
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _barbuttoninfo = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
    }
    else
        _barbuttoninfo = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tapbutton:)];
	[_barbuttoninfo setTag:11];
    _barbuttoninfo.enabled = NO;
    self.navigationItem.rightBarButtonItem = _barbuttoninfo;
    [_scrollview addSubview:_contentview];
    
    _operationQueue = [NSOperationQueue new];
    
//    CGRect frame = _descriptionview.frame;
//    frame.origin.x = _detailview.frame.size.width;
//    _descriptionview.frame = frame;
//    [_detailscrollview addSubview:_descriptionview];
//    
//    frame = _detailview.frame;
//    frame.origin.x = 0;
//    _detailview.frame = frame;
//    [_detailscrollview addSubview:_detailview];
//    
//    size = _detailscrollview.frame.size;
//    size.width = size.width * _detailscrollview.subviews.count-1;
//    [_detailscrollview setContentSize:size];
//    _detailscrollview.pagingEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if (!_isrefreshview) {
    [self configureRestKit];
    if (_isnodata) {
        [self loadData];
    }
    //}
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
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

- (void)setViewControllers:(NSArray *)viewControllers
{
	[self setViewControllers:viewControllers animated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
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
		
		UIViewController* c;
		for (NSInteger i = 0; i < count; i++) {
			c = viewControllers[i];
			if (c.TKPDTabProfileNavigationItem == nil) {
				c.TKPDTabProfileNavigationItem = (TKPDTabProfileNavigationItem*)c.tabBarItem;
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
    selectedIndex = selectedIndex-10;
    if (selectedIndex<0) {
        selectedIndex = 0;
    }
	if (selectedIndex == _selectedIndex) return;
    
	if (_viewControllers != nil) {
        
        if (!_isnodata) {
            id userinfo = _profileinfo;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
        }
		
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
	}
}

-(IBAction)tapbutton:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (sender.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
//                ShopInfoViewController *vc = [ShopInfoViewController new];
//                vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop};
//                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
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

- (UIEdgeInsets)contentInsetForContainerController
{
	UIEdgeInsets inset = UIEdgeInsetsZero;
	
	//if (self.parentViewController && [self.parentViewController isKindOfClass:[TKPDTabBarShopController class]]) {
	//	UIEdgeInsets bar = self.TKPDTabBarShopController.contentInsetForChildController;
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

-(void)setDetailData{
    
    _namelabel.text = _profileinfo.result.user_info.user_name;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profileinfo.result.user_info.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = _thumb;
    thumb = [UIImageView circleimageview:thumb];
    
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [_actpp startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        [_actpp stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_actpp stopAnimating];
    }];
    
    if (!_isnodata) {
        id userinfo = _profileinfo;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
    }
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileInfo class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileInfoResult class]];

    RKObjectMapping *userinfoMapping = [RKObjectMapping mappingForClass:[UserInfo class]];
    [userinfoMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIUSEREMAILKEY:kTKPDPROFILE_APIUSEREMAILKEY,
                                                          kTKPDPROFILE_APIUSERMESSENGERKEY:kTKPDPROFILE_APIUSERMESSENGERKEY,
                                                          kTKPDPROFILE_APIUSERHOBBIESKEY:kTKPDPROFILE_APIUSERHOBBIESKEY,
                                                          kTKPDPROFILE_APIUSERPHONEKEY:kTKPDPROFILE_APIUSERPHONEKEY,
                                                          kTKPDPROFILE_APIUSERIDKEY:kTKPDPROFILE_APIUSERIDKEY,
                                                          kTKPDPROFILE_APIUSERIMAGEKEY:kTKPDPROFILE_APIUSERIMAGEKEY,
                                                          kTKPDPROFILE_APIUSERNAMEKEY:kTKPDPROFILE_APIUSERNAMEKEY
                                                          }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];
        // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIUSERINFOKEY toKeyPath:kTKPDPROFILE_APIUSERINFOKEY withMapping:userinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PEOPLEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    _requestcount ++;
    
    [_act startAnimating];
    
	NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEINFOKEY,
                            kTKPDPROFILE_APIUSERIDKEY : @(602) //@([[_data objectForKey:kTKPDPROFILE_APIUSERIDKEY]integerValue])
                            };
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PEOPLEAPIPATH parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    //[_objectmanager getObjectsAtPath:kTKPDPROFILE_PEOPLEAPIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        [_act stopAnimating];
        [_timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        [_act stopAnimating];
        [_timer invalidate];
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _profileinfo = stats;
    BOOL status = [_profileinfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        _isnodata = NO;
        _headerview.hidden = NO;
        
        [self setDetailData];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
    [self cancel];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
            //_table.tableFooterView = _footer;
            //[_act startAnimating];
            [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            //[_act stopAnimating];
            //_table.tableFooterView = nil;
        }
    }
    else
    {
        //[_act stopAnimating];
        //_table.tableFooterView = nil;
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

@end


#pragma mark -
#pragma mark UIViewController category

#import <objc/runtime.h>

@implementation UIViewController (TKPDTabProfileNavigationController)

- (TKPDTabProfileNavigationController*)TKPDTabProfileNavigationController
{
	UIViewController* c = self.parentViewController;
	
	while (c != nil) {
		if ([c isKindOfClass:[TKPDTabProfileNavigationController class]]) {
			return  (TKPDTabProfileNavigationController*)c;
		}
		
		c = c.parentViewController;
	}
	
	return nil;
}

//static void* const kTKPDTabProfileNavigationItemKey = (void*)&kTKPDTabProfileNavigationItemKey;

@dynamic TKPDTabProfileNavigationItem;

- (TKPDTabProfileNavigationItem *)TKPDTabProfileNavigationItem
{
	//return objc_getAssociatedObject(self, @selector(TKPDTabProfileNavigationItem));
	id o = objc_getAssociatedObject(self, @selector(TKPDTabProfileNavigationItem));
	
	if (o == nil) {
		o = self.tabBarItem;
		[self setTKPDTabProfileNavigationItem:o];
	}
	
	return o;
}

- (void)setTKPDTabProfileNavigationItem:(TKPDTabProfileNavigationItem *)TKPDTabProfileNavigationItem
{
	objc_setAssociatedObject(self, @selector(TKPDTabProfileNavigationItem), TKPDTabProfileNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
