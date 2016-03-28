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
#import "MyShopEtalaseFilterViewController.h"
#import "SettingUserProfileViewController.h"
#import "ProfileSettingViewController.h"
#import "SendMessageViewController.h"

#import "URLCacheController.h"

@interface TKPDTabProfileNavigationController () <UIScrollViewDelegate, SettingUserProfileDelegate> {
	UIView* _tabbar;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    
    NSMutableArray *_chevrons;
    
    UIBarButtonItem *_barbuttoninfo;
    
    NSInteger _pagedetail;
    
    ProfileInfo *_profileinfo;
    
    BOOL _isnodata, hasLoadViewWillAppear;
    BOOL _isrefreshview;
    NSInteger _requestcount;
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSTimer *_timer;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actpp;

@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *contentview;

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIView *tapview;

@property (weak, nonatomic) IBOutlet UIImageView *thumb;

@property (weak, nonatomic) IBOutlet UIView *headerview;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *buttoneditprofile;
@property (weak, nonatomic) IBOutlet UIButton *buttonmessage;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(UIButton* )sender;

- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarProfileController

@implementation TKPDTabProfileNavigationController
@synthesize isOtherProfile;
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
    _chevrons = [NSMutableArray arrayWithArray:_buttons];
    
	
	if (_unloadSelectedIndex != -1) {
		[self setViewControllers:_unloadViewControllers];
		
		_unloadSelectedIndex = -1;
		_unloadViewControllers = nil;
	}
    
    CGSize size =_contentview.frame.size;
    size.height = size.height - _tapview.frame.size.height-64;
    _scrollview.contentSize = size;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_shop_setting" ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _barbuttoninfo = [[UIBarButtonItem alloc] initWithImage:image
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(tapbutton:)];
    } else {
        _barbuttoninfo = [[UIBarButtonItem alloc] initWithImage:img
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(tapbutton:)];
    }
    _barbuttoninfo.tag = 11;

    [_scrollview addSubview:_contentview];
    
    _operationQueue = [NSOperationQueue new];
    _cachecontroller = [URLCacheController new];
    _cacheconnection = [URLCacheConnection new];
    // add notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY object:nil];
    
    //cache
    _cachecontroller.URLCacheInterval = 86400.0;

    _button.layer.cornerRadius = 2;
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!hasLoadViewWillAppear && isOtherProfile) {
        for(UIButton *temp in _chevrons)
        {
            if(temp.tag == 12) {//Btn Kontak
                [_chevrons removeObject:temp];
                [temp removeFromSuperview];
                break;
            }
        }
        
        //Set Frame for button
        int originX = 0;
        for(UIButton *temp in _chevrons) {
            temp.frame = CGRectMake(originX, temp.frame.origin.y, self.view.bounds.size.width/2.0f, temp.bounds.size.height);
            originX = temp.frame.origin.x+temp.bounds.size.width;
        }
    }
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata) {
            [self loadData];
        }
    }
    
    if(! hasLoadViewWillAppear) {
        hasLoadViewWillAppear = !hasLoadViewWillAppear;
        //Hidden bottom green color
        CGRect frame = _scrollview.bounds;
        frame.origin.y = frame.size.height;
        frame.size.height += frame.size.height;
        UIView* grayView = [[UIView alloc] initWithFrame:frame];
        grayView.backgroundColor = ((UIViewController *) [_viewControllers firstObject]).view.backgroundColor;
        [_scrollview insertSubview:grayView atIndex:0];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
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
	//tabbar.frame = frame;
	
	UIEdgeInsets inset = [self contentInsetForChildController];
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
        
//        /** initialization mutable variable **/
//        _buttons = [NSMutableArray new];
		
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
    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor colorWithRed:(22.0/255.0) green:(125.0/255.0) blue:(22.0/255.0) alpha:1.0] CGColor];
    upperBorder.frame = CGRectMake(0, 41.0f, (isOtherProfile? self.view.bounds.size.width/2.0f:CGRectGetWidth([_chevrons[_selectedIndex] frame])), 3.0f);
    
    [[_chevrons[_selectedIndex] layer] addSublayer:upperBorder];

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

		UIViewController* deselect = _selectedViewController;
		UIViewController* select = _viewControllers[selectedIndex];

// Did not remove this because of the todo
//		UIEdgeInsets inset = [self contentInsetForContainerController];
//		if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
//			
//			UINavigationController* n = (UINavigationController*)select;
//			if (!n.navigationBarHidden && !n.navigationBar.hidden) {
//				
//				//CGRect rect = n.navigationBar.frame;
//				//rect = [self.view convertRect:rect fromView:n.navigationBar.superview];
//				//(*selectframe).origin.y = CGRectGetMaxY(rect);
//				selectframe.origin.y = inset.top;
//				//selectframe = CGRectOffset(selectframe, 0.0f, CGRectGetHeight(rect));
//				selectframe = CGRectZero;
//			} else {
//				//selectframe.origin.y = inset.top;
//                selectframe = CGRectZero;
//			}
//		} else {
//            selectframe = CGRectZero;
//			//selectframe.origin.y = inset.top;
//		}
		
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
        
        if (!_isnodata) {
            id userinfo = _profileinfo;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
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

- (void)dealloc
{
	NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
    _cachecontroller = nil;
    _cacheconnection = nil;
}

#pragma mark -
#pragma mark View actions
-(IBAction)tap:(UIButton*) sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        
    }
	if (_viewControllers != nil) {
		
		NSInteger index = sender.tag;
        
        //reset tab border color and text color
        for(int i=0;i<_chevrons.count;i++) {
            CALayer *whiteBorder = [CALayer layer];
            whiteBorder.backgroundColor = [[UIColor whiteColor] CGColor];
            whiteBorder.frame = CGRectMake(0, 41.0f, CGRectGetWidth([_chevrons[i] frame]), 3.0f);
            [[_chevrons[i] layer] addSublayer:whiteBorder];
            UIButton *button = (UIButton *)[_chevrons objectAtIndex:i];
            [button setTitleColor:[UIColor colorWithRed:22.0/255.0 green:125.0/255.0 blue:22.0/255.0 alpha:1] forState:UIControlStateNormal];
        }

        //set button text color to green
        [sender setTitleColor:[UIColor colorWithRed:22.0/255.0 green:125.0/255.0 blue:22.0/255.0 alpha:1] forState:UIControlStateNormal];
        
        //add border green on bottom button
        CALayer *upperBorder = [CALayer layer];
        upperBorder.backgroundColor = [[UIColor colorWithRed:(22.0/255.0) green:(125.0/255.0) blue:(22.0/255.0) alpha:1.0] CGColor];
        upperBorder.frame = CGRectMake(0, 41.0f, CGRectGetWidth([_chevrons[index-10] frame]), 3.0f);
        [[_chevrons[index-10] layer] addSublayer:upperBorder];

        
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

-(IBAction)tapbutton:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                if (self.presentingViewController != nil) {
                    if (self.navigationController.viewControllers.count > 1) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            }
                
            case 11:
            {
                //setting action
                ProfileSettingViewController *vc = [ProfileSettingViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            
                
            case 20:
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
            case 10:
            {
                //button message action
                break;
            }
            case 11:
            {
                //button edit profile action
                SettingUserProfileViewController *vc = [SettingUserProfileViewController new];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            case 12 : {
                SendMessageViewController *messageController = [SendMessageViewController new];
                messageController.data = @{
                                           kTKPDSHOPEDIT_APIUSERIDKEY:[_data objectForKey:kTKPDSHOPEDIT_APIUSERIDKEY]?:@"",
                                           kTKPDDETAIL_APISHOPNAMEKEY:_profileinfo.result.user_info.user_name
                                           };
                [self.navigationController pushViewController:messageController animated:YES];
                
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
    
    UIImageView *thumb = _thumb;
    thumb = [UIImageView circleimageview:thumb];
    thumb.layer.borderColor = [UIColor whiteColor].CGColor;
    thumb.layer.borderWidth = 2;
    thumb.image = nil;
    __weak typeof(thumb) wthumb = thumb;
    
    UserAuthentificationManager *authManager = [UserAuthentificationManager new];
    NSURL *profilePictureURL = [NSURL URLWithString:[authManager.getUserLoginData objectForKey:@"user_image"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:profilePictureURL];
    [thumb setImageWithURLRequest:request
                 placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
         //NSLOG(@"thumb: %@", thumb);
         [wthumb setImage:image];
    #pragma clang diagnostic pop
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     }];
    
     if (!_isnodata) {
        id userinfo = _profileinfo;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
    }
}

-(void)refreshView
{
    [self cancel];
    /** clear object **/
    _requestcount = 0;
    _isrefreshview = YES;
    /** request data **/
    
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Methods
-(void)updateView:(NSUserDefaults*)userdefault
{
    [self refreshView];
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    
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
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIUSERINFOKEY
                                                                                  toKeyPath:kTKPDPROFILE_APIUSERINFOKEY
                                                                                withMapping:userinfoMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                  toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                withMapping:shopinfoMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY
                                                                                  toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY
                                                                                withMapping:shopstatsMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PEOPLEAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    _requestcount ++;
    
	NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEINFOKEY,
                            kTKPDPROFILE_APIPROFILEUSERIDKEY : @([[_data objectForKey:kTKPDPROFILE_APIUSERIDKEY]integerValue])
                            };
    
    [_cachecontroller getFileModificationDate];
    
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    NSTimer *timer;
    [_act startAnimating];

    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDPROFILE_PEOPLEAPIPATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        [_act stopAnimating];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                             target:self
                                           selector:@selector(requesttimeout)
                                           userInfo:nil
                                            repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _profileinfo = info;
    NSString *statusstring = _profileinfo.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //only save cache for first page
        [_cacheconnection connection:operation.HTTPRequestOperation.request
                  didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];

        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        
        NSError *mappingError = nil;
        
        BOOL isMapped = [mapper execute:&mappingError];
        
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id info = [result objectForKey:@""];
            _profileinfo = info;
            NSString *statusstring = _profileinfo.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
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
        else{
            
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
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (sender.contentOffset.y <= _headerview.frame.size.height) {
        CGFloat opacity = 1.0f - (sender.contentOffset.y / _headerview.frame.size.height);
        _namelabel.layer.opacity = opacity;
        _button.layer.opacity = opacity;
    }
    
    if (sender.contentOffset.y <= 70.0f) {
        CGFloat opacity = 1.0f - (sender.contentOffset.y / 70.0f);
        _thumb.layer.opacity = opacity;
    }
    
    if (sender.contentOffset.y > 138.0f) {
        self.title = _profileinfo.result.user_info.user_name;
    } else {
        self.title = @"";
    }
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    
    if (data) {
        //cache
        NSString *path= [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDPROFILE_CACHEFILEPATH];
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDPROFILE_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDPROFILE_APIUSERIDKEY]integerValue]]];
        _cachecontroller.filePath = _cachepath;
        [_cachecontroller initCacheWithDocumentPath:path];
        
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary *auth = [secureStorage keychainDictionary];
        
        if (auth && ![auth isEqual:[NSNull null]]) {
            if ([[_data objectForKey:kTKPD_USERIDKEY]integerValue] == [[auth objectForKey:kTKPD_USERIDKEY]integerValue]) {
                
                [_button setTitle:@"Ubah Profil" forState:UIControlStateNormal];
                [_button setImage:nil forState:UIControlStateNormal];
                [_button setTag:11];
                
                self.navigationItem.rightBarButtonItem = _barbuttoninfo;
                
            } else {
                [_button setTitle:@"Message" forState:UIControlStateNormal];
                [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
                [_button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
                [_button setImage:[UIImage imageNamed:@"icon_message.png"] forState:UIControlStateNormal];
                [_button setTag:12];
                
                [_barbuttoninfo setEnabled:NO];
                [_barbuttoninfo setTintColor: [UIColor clearColor]];
            }
        }
        else
        {
            [_button setTitle:@"Message" forState:UIControlStateNormal];
            [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
            [_button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
            [_button setImage:[UIImage imageNamed:@"icon_message.png"] forState:UIControlStateNormal];
            [_button setTag:12];
            
            [_barbuttoninfo setEnabled:NO];
            [_barbuttoninfo setTintColor: [UIColor clearColor]];
        }
    }
}

#pragma mark - Setting user profile delegate

- (void)successEditUserProfile
{
    [self refreshView];
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
