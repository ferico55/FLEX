//
//  TKPDTabShopNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "detail.h"
#import "Shop.h"
#import "TKPDTabShopNavigationController.h"
#import "ShopInfoViewController.h"
#import "BackgroundLayer.h"
#import "SortViewController.h"
#import "ProductEtalaseViewController.h"
#import "SendMessageViewController.h"
#import "FavoriteShopAction.h"
#import "ShopProductViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "../Detail/Shop/Settings/ShopSettingViewController.h"

#import "URLCacheController.h"
#import "UIImage+ImageEffects.h"

@interface TKPDTabShopNavigationController () <UIScrollViewDelegate> {
	UIView* _tabbar;
	NSInteger _unloadSelectedIndex;
	NSArray* _unloadViewControllers;
    
    NSArray *_chevrons;
    
    UIBarButtonItem *_barbuttoninfo;
    
    NSInteger _pagedetail;
    
    NSMutableDictionary *_detailfilter;
    
    Shop *_shop;
    BOOL _isnodata;
    NSInteger _requestcount;
    BOOL _isaddressexpanded;
    BOOL _isrefreshview;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    BOOL is_dismissed;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    BOOL navigationBarAnimated;
}

@property (weak, nonatomic) IBOutlet UIView *filterview;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actpp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actcover;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ppimage;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *shopdesclabel;
@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *contentview;

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (weak, nonatomic) IBOutlet UIView *tapview;
@property (strong, nonatomic) IBOutlet UIView *stickyTapView;

@property (weak, nonatomic) IBOutlet UILabel *labelFavAndSold;
@property (weak, nonatomic) IBOutlet UILabel *labelLastOnline;
@property (weak, nonatomic) IBOutlet UIButton *buttonfav;
@property (weak, nonatomic) IBOutlet UIButton *buttonMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonsetting;

@property (strong, nonatomic) IBOutlet UIView *descriptionview;
@property (strong, nonatomic) IBOutlet UIView *detailview;

@property (weak, nonatomic) IBOutlet UIScrollView *detailscrollview;
@property (weak, nonatomic) IBOutlet UIButton *buttonaddproduct;

@property (strong, nonatomic) IBOutlet UIButton *backButtonCustom;
@property (strong, nonatomic) IBOutlet UIButton *infoButtonCustom;
@property (weak, nonatomic) IBOutlet UIImageView *blurCoverImage;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *badgeGoldMerchant;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(UIButton* )sender;

- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarShopController

@implementation TKPDTabShopNavigationController

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
        _isrefreshview = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Shop";
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _operationQueue = [NSOperationQueue new];
    _detailfilter = [NSMutableDictionary new];
    _cachecontroller = [URLCacheController new];
    _cacheconnection = [URLCacheConnection new];
    
    _buttons = [NSArray sortViewsWithTagInArray:_buttons];
    _chevrons = _buttons;
	
	if (_unloadSelectedIndex != -1) {
		[self setViewControllers:_unloadViewControllers];
		_unloadSelectedIndex = -1;
		_unloadViewControllers = nil;
	}
    
    /** set inset table for different size**/
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGSize size =_contentview.frame.size;
    size.height = size.height - _tapview.frame.size.height;
    _scrollview.contentSize = size;
    
    //set back bar button
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tapbutton:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set info bar button as right bar button item
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONINFO ofType:@"png"]];
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
    
    CGRect frame = _descriptionview.frame;
    frame.origin.x = _detailview.frame.size.width;
    _descriptionview.frame = frame;
    [_detailscrollview addSubview:_descriptionview];
    
    frame = _detailview.frame;
    frame.origin.x = 0;
    _detailview.frame = frame;
    [_detailscrollview addSubview:_detailview];
    
    size = _detailscrollview.frame.size;
    size.width = size.width * _detailscrollview.subviews.count-1;
    [_detailscrollview setContentSize:size];
    _detailscrollview.pagingEnabled = YES;
    
    _operationQueue = [NSOperationQueue new];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil];
    
    _detailfilter = [NSMutableDictionary new];
    
    _cachecontroller.URLCacheInterval = 86400.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToTop)
                                                 name:@"scrollToTop" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableScroll)
                                                 name:@"enableParentScroll" object:nil];
    
    navigationBarAnimated = false;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NavigationShouldHide"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [UIView animateWithDuration:0.3 animations:^(void) {
                                                          _blurCoverImage.alpha = 0;
                                                          _ppimage.alpha = 1;
                                                      } completion:^(BOOL finished) {
                                                          navigationBarAnimated = false;
                                                      }];
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NavigationShouldUnhide"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [UIView animateWithDuration:0.3 animations:^(void) {
                                                          _blurCoverImage.alpha = 1;
                                                          _ppimage.alpha = 0;
                                                      } completion:^(BOOL finished) {
                                                          navigationBarAnimated = false;
                                                      }];
                                                      
                                                  }];
    
    _buttonfav.layer.cornerRadius = 3;
    _buttonfav.layer.borderWidth = 1;
    _buttonfav.layer.borderColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1].CGColor;
    
    _buttonMessage.layer.cornerRadius = 3;
    _buttonMessage.layer.borderWidth = 1;
    _buttonMessage.layer.borderColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1].CGColor;

    _buttonsetting.layer.cornerRadius = 3;
    _buttonsetting.layer.borderWidth = 1;
    _buttonsetting.layer.borderColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1].CGColor;
    
    _buttonaddproduct.layer.cornerRadius = 3;
    _buttonaddproduct.layer.borderWidth = 1;
    _buttonaddproduct.layer.borderColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1].CGColor;
    _buttonaddproduct.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
    _buttonaddproduct.titleEdgeInsets = UIEdgeInsetsMake(2, 4, 0, 0);
    
    _buttonsetting.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureRestKit];
    if (_isnodata) {
        [self request];
    }
    self.navigationController.navigationBarHidden = _shop.result.info.shop_is_gold;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
    
    CGRect containerFrame = _container.frame;
    containerFrame.size.height = self.view.frame.size.height - 94;
    _container.frame = containerFrame;
    
    CGRect contentFrame = _contentview.frame;
    contentFrame.size.height = 318 + containerFrame.size.height;
    _contentview.frame = contentFrame;
	
	_selectedViewController.view.frame = _container.bounds;
	
	UIEdgeInsets inset = [self contentInsetForContainerController];
	
	UIView* tabbar;
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
			if (c.TKPDTabShopNavigationItem == nil) {
				c.TKPDTabShopNavigationItem = (TKPDTabShopNavigationItem*)c.tabBarItem;
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
    
    if (_selectedIndex >= 0) {
        CALayer *upperBorder = [CALayer layer];
        upperBorder.backgroundColor = [[UIColor colorWithRed:(18.0/255.0) green:(199.0/255.0) blue:(0.0/255.0) alpha:1.0] CGColor];
        upperBorder.frame = CGRectMake(0, 42.0f, CGRectGetWidth([_chevrons[_selectedIndex?:0] frame]), 2.0f);
        [[_chevrons[_selectedIndex] layer] addSublayer:upperBorder];
    }
    
    [self updateTabColor];
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
    
    if (selectedIndex != 0) {
        _filterview.hidden = YES;
    } else {
        _filterview.hidden = NO;
        CGRect scrollFrame;
        scrollFrame.origin = _scrollview.frame.origin;
        scrollFrame.size = CGSizeMake(_scrollview.frame.size.width, _scrollview.frame.size.height);
        _scrollview.frame = scrollFrame;
    }
    
    CGRect containerFrame = _container.frame;
    CGFloat prevContainerHeight = containerFrame.size.height;
    CGFloat newContainerHeight = self.view.frame.size.height - 108;
    containerFrame.size.height = newContainerHeight;
    _container.frame = containerFrame;
    
    CGRect contentViewFrame = _contentview.frame;
    contentViewFrame.size.height = containerFrame.size.height - (prevContainerHeight - newContainerHeight);
    _contentview.frame = contentViewFrame;
    
	if (_viewControllers != nil) {
        CGRect selectframe;
		selectframe = _tabbar.frame;
        
		UIViewController* deselect = _selectedViewController;
		UIViewController* select = _viewControllers[selectedIndex];
		
		UIEdgeInsets inset = [self contentInsetForContainerController];
        
		if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
			
			UINavigationController* n = (UINavigationController*)select;
			if (!n.navigationBarHidden && !n.navigationBar.hidden) {
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
        
        [self updateTabColor];
        
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
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark View actions
-(IBAction)tap:(UIButton*) sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
            case 15:
            {
                SendMessageViewController *vc = [SendMessageViewController new];
                vc.data = @{
                            kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDDETAIL_APISHOPNAMEKEY:_shop.result.info.shop_name
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 16 :
            {
                [self configureRestkitFav];
                [self doFav:_shop.result.info.shop_id withDefaultButton:btn];
                btn.tag = 17;
                [btn setTitle:@"Unfavorite" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
                [btn.layer setBorderWidth:0];
                [UIView animateWithDuration:0.3 animations:^(void) {
                    [btn setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }];
                break;
            }
            case 17 :
            {
                [self configureRestkitFav];
                [self doFav:_shop.result.info.shop_id withDefaultButton:btn];
                btn.tag = 16;
                [btn setTitle:@"Favorite" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
                [btn.layer setBorderWidth:1];
                [UIView animateWithDuration:0.3 animations:^(void) {
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }];
            }
            case 19:
            {
                //add produk
                break;
            }
            case 20:
            {
                // back button action
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
            case 18 :
            {
                //settings
                ShopSettingViewController *vc = [ShopSettingViewController new];
                vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY], kTKPDDETAIL_DATAINFOSHOPSKEY:_shop.result};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                if (_viewControllers != nil) {
                    
                    NSInteger index = _selectedIndex;
                    index = sender.tag;
                    
                    BOOL should = YES;
                    
                    //add border green on bottom button
                    CALayer *upperBorder = [CALayer layer];
                    upperBorder.backgroundColor = [[UIColor colorWithRed:(18.0/255.0) green:(199.0/255.0) blue:(0.0/255.0) alpha:1.0] CGColor];
                    upperBorder.frame = CGRectMake(0, 42.0f, CGRectGetWidth([_chevrons[index-10] frame]), 2.0f);
                    
                    for(int i=0;i<4;i++) {
                        CALayer *whiteBorder = [CALayer layer];
                        whiteBorder.backgroundColor = [[UIColor whiteColor] CGColor];
                        whiteBorder.frame = CGRectMake(0, 42.0f, CGRectGetWidth([_chevrons[i] frame]), 2.0f);
                        [[_chevrons[i] layer] addSublayer:whiteBorder];
                    }
                    
                    [[_chevrons[index-10] layer] addSublayer:upperBorder];
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
                break;
        }
    }
}

-(IBAction)tapbutton:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                // sort button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SortViewController *vc = [SortViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 11:
            {
                // etalase button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                ProductEtalaseViewController *vc = [ProductEtalaseViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 12:
            {
                NSString *activityItem = [NSString stringWithFormat:@"%@ - %@ | Tokopedia %@", _shop.result.info.shop_name,
                                          _shop.result.info.shop_location, _shop.result.info.shop_url];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            case 13:
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
            case 14:
            {
                ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
                vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                           kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                [self.navigationController pushViewController:vc animated:YES];
                
                break;
            }
            default:
                break;
        }
    }
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
                ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
                vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                [self.navigationController pushViewController:vc animated:YES];
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


#pragma mark - Request
-(void) configureRestkitFav {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                        @"is_success":@"is_success"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:@"action/favorite-shop.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}


-(void) doFav:(NSInteger)shop_id withDefaultButton:(UIButton*)btn{
    //    if (_request.isExecuting) return;
    NSString *s_id = [@(shop_id) stringValue];
    NSDictionary* param = @{
                            kTKPDDETAIL_ACTIONKEY:@"fav_shop",
                            @"shop_id":s_id
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/favorite-shop.pl" parameters:param];
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessfav:mappingResult withOperation:operation];
        
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailurefav:error];
        
        [_timer invalidate];
        _timer = nil;
    }];
    
    
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    
    
}

-(void) requestsuccessfav:(id)mappingResult withOperation:(NSOperationQueue*)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void) requestfailurefav:(id)object {
    
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

-(void)setDetailData
{
    _detailview.hidden = NO;
    _descriptionview.hidden = NO;
    _pagecontrol.hidden = NO;
    
    _namelabel.text = _shop.result.info.shop_name;
    _shopdesclabel.text = _shop.result.info.shop_description;
    _locationlabel.text = _shop.result.info.shop_location;
    
    if([_shop.result.info.shop_already_favorited isEqualToString:@"1"]) {
        [_buttonfav setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
        [_buttonfav setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
        [_buttonfav setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonfav setTitle:@"Unfavorite" forState:UIControlStateNormal];
        [_buttonfav.layer setBorderWidth:0];
        _buttonfav.tag = 17;
    } else {
        [_buttonfav setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
        [_buttonfav setBackgroundColor:[UIColor whiteColor]];
        [_buttonfav setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _buttonfav.tag = 16;
    }
    
    _labelFavAndSold.text = [NSString stringWithFormat:@"%@ Favorited  %@ Sold Items", _shop.result.info.shop_total_favorit, _shop.result.stats.shop_item_sold];
    
    _labelLastOnline.text = [NSString stringWithFormat:@"Last Online : %@", _shop.result.info.shop_owner_last_login];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = _ppimage;
    thumb.image = nil;
    thumb.layer.cornerRadius = thumb.frame.size.width/2;
    thumb.layer.borderColor = [UIColor whiteColor].CGColor;
    thumb.layer.borderWidth = 3;
    
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    _shop.result.info.shop_is_gold = true;
    
    if (_shop.result.info.shop_is_gold == true) {
        
        _backButtonCustom.hidden = NO;
        _infoButtonCustom.hidden = NO;
        _navigationTitleLabel.hidden = YES;

        self.navigationController.navigationBarHidden = YES;
        
        self.view.clipsToBounds = NO;
        self.contentview.clipsToBounds = NO;
        
        if ([_shop.result.info.shop_name length] > 18) {
            NSRange stringRange = {0, MIN([_shop.result.info.shop_name length], 18)};
            stringRange = [_shop.result.info.shop_name rangeOfComposedCharacterSequencesForRange:stringRange];
            _navigationTitleLabel.text = [NSString stringWithFormat:@"%@...", [_shop.result.info.shop_name substringWithRange:stringRange]];
        } else {
            _navigationTitleLabel.text = _shop.result.info.shop_name;
        }
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        [self.coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            self.coverImageView.image = image;
            self.coverImageView.hidden = NO;
            self.coverImageView.backgroundColor = [UIColor blackColor];
            self.blurCoverImage.image = [self.coverImageView.image applyLightEffect];
            self.blurCoverImage.hidden = NO;
#pragma clang diagnostic pop
        } failure:nil];
        
        //add gradient in cover image
        _coverImageView.layer.sublayers = nil;
        CAGradientLayer *gradientLayer = [BackgroundLayer blackGradientFromTop];
        gradientLayer.frame = _coverImageView.bounds;
        [_coverImageView.layer insertSublayer:gradientLayer atIndex:0];
        
        [_namelabel sizeToFit];
        [_shopdesclabel sizeToFit];
    }
    else {
        _backButtonCustom.hidden = YES;
        _infoButtonCustom.hidden = YES;
        _navigationTitleLabel.hidden = YES;
        
        self.blurCoverImage.hidden = NO;
        self.coverImageView.hidden = NO;
        
        self.navigationController.navigationBarHidden = NO;
        
        [_stickyTapView layoutIfNeeded];
        CGRect stickyTabFrame = _stickyTapView.frame;
        stickyTabFrame.origin.y = 0;
        [UIView animateWithDuration:0.3 animations:^(void) {
            _stickyTapView.frame = stickyTabFrame;
        }];
        [_stickyTapView layoutIfNeeded];
        
        _scrollview.contentOffset = CGPointMake(0, -50);
        _scrollview.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0);
        
        _badgeGoldMerchant.hidden = YES;
    }
}

- (void)scrollContainer
{
    CGFloat offset;
    if (_shop.result.info.shop_is_gold) {
        offset = 317.0;
    } else {
        offset = 378.0;
    }
    if (_scrollview.contentOffset.y < offset) {
        _stickyTapView.hidden = YES;
        [self disableScrollAtIndex:_selectedIndex];
    } else {
        _stickyTapView.hidden = NO;
        [self enableScrollAtIndex:_selectedIndex];
    }
}

- (void)disableScrollAtIndex:(int)index
{
    switch (index) {
        case 0:
            ((ShopProductViewController *)_selectedViewController).table.scrollEnabled = NO;
            break;
        case 1:
            ((ShopTalkViewController *)_selectedViewController).table.scrollEnabled = NO;
            break;
        case 2:
            ((ShopReviewViewController *)_selectedViewController).table.scrollEnabled = NO;
            break;
        case 3:
            ((ShopNotesViewController *)_selectedViewController).table.scrollEnabled = NO;
            break;
        default:
            ((ShopProductViewController *)_selectedViewController).table.scrollEnabled = NO;
            break;
    }
}

- (void)enableScrollAtIndex:(int)index
{
    switch (index) {
        case 0:
            ((ShopProductViewController *)_selectedViewController).table.scrollEnabled = YES;
            break;
        case 1:
            ((ShopTalkViewController *)_selectedViewController).table.scrollEnabled = YES;
            break;
        case 2:
            ((ShopReviewViewController *)_selectedViewController).table.scrollEnabled = YES;
            break;
        case 3:
            ((ShopNotesViewController *)_selectedViewController).table.scrollEnabled = YES;
            break;
        default:
            ((ShopProductViewController *)_selectedViewController).table.scrollEnabled = YES;
            break;
    }
}

- (void)scrollToTop
{
    CGFloat y;
    if (_shop.result.info.shop_is_gold) {
        y = 314;
    } else {
        y = 379;
    }
    [self.scrollview setContentOffset:CGPointMake(0, y) animated:YES];
    
}

- (void)enableScroll
{
    _scrollview.scrollEnabled = YES;
}

- (void)updateTabColor
{
    // Tab View
    for (int i = 10; i < 14; i++) {
        UIButton *selectedButton = (UIButton *)[_tapview viewWithTag:i];
        [selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    UIButton *selectedTabButton = (UIButton *)[_tapview viewWithTag:10+_selectedIndex];
    [selectedTabButton setTitleColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    // Sticky Tab View
    for (int i = 10; i < 14; i++) {
        UIButton *selectedButton = (UIButton *)[_stickyTapView viewWithTag:i];
        [selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIView *border = [_stickyTapView viewWithTag:10+i];
        border.hidden = YES;
    }
    
    UIButton *selectedStickyTabButton = (UIButton *)[_stickyTapView viewWithTag:10+_selectedIndex];
    [selectedStickyTabButton setTitleColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    UIView *selectedBorder = (UIView *)[_stickyTapView viewWithTag:20+_selectedIndex];
    selectedBorder.hidden = NO;
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Shop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIISOPENKEY:kTKPDDETAILSHOP_APIISOPENKEY}];
    
    RKObjectMapping *closedinfoMapping = [RKObjectMapping mappingForClass:[ClosedInfo class]];
    [closedinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIUNTILKEY:kTKPDDETAILSHOP_APIUNTILKEY,
                                                            kTKPDDETAILSHOP_APIRESONKEY:kTKPDDETAILSHOP_APIRESONKEY
                                                            }];
    
    RKObjectMapping *ownerMapping = [RKObjectMapping mappingForClass:[Owner class]];
    [ownerMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIOWNERIMAGEKEY:kTKPDDETAILSHOP_APIOWNERIMAGEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERPHONEKEY:kTKPDDETAILSHOP_APIOWNERPHONEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERIDKEY:kTKPDDETAILSHOP_APIOWNERIDKEY,
                                                       kTKPDDETAILSHOP_APIOWNEREMAILKEY:kTKPDDETAILSHOP_APIOWNEREMAILKEY,
                                                       kTKPDDETAILSHOP_APIOWNERNAMEKEY:kTKPDDETAILSHOP_APIOWNERNAMEKEY,
                                                       kTKPDDETAILSHOP_APIOWNERMESSAGERKEY:kTKPDDETAILSHOP_APIOWNERMESSAGERKEY
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
                                                          kTKPDDETAILSHOP_APICOVERKEY:kTKPDDETAILSHOP_APICOVERKEY,
                                                          kTKPDDETAILSHOP_APITOTALFAVKEY:kTKPDDETAILSHOP_APITOTALFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                          kTKPDDETAILSHOP_APISHOPISGOLD:kTKPDDETAILSHOP_APISHOPISGOLD,
                                                          kTKPDDETAILSHOP_APISHOPURLKEY:kTKPDDETAILSHOP_APISHOPURLKEY,                                                          
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY:kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALETALASEKEY:kTKPDSHOP_APISHOPTOTALETALASEKEY,
                                                           kTKPDSHOP_APISHOPTOTALPRODUCTKEY:kTKPDSHOP_APISHOPTOTALPRODUCTKEY,
                                                           kTKPDSHOP_APISHOPTOTALSOLDKEY:kTKPDSHOP_APISHOPTOTALSOLDKEY
                                                           }];
    
    RKObjectMapping *shipmentMapping = [RKObjectMapping mappingForClass:[Shipment class]];
    [shipmentMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APISHIPMENTIDKEY:kTKPDDETAILSHOP_APISHIPMENTIDKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY:kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTNAMEKEY:kTKPDDETAILSHOP_APISHIPMENTNAMEKEY
                                                          }];
    
    RKObjectMapping *shipmentpackageMapping = [RKObjectMapping mappingForClass:[ShipmentPackage class]];
    [shipmentpackageMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APISHIPPINGIDKEY,
                                                            kTKPDDETAILSHOP_APIPRODUCTNAMEKEY
                                                            ]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                    kTKPDDETAILSHOP_APIPAYMENTNAMEKEY]];
    
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
    [addressMapping addAttributeMappingsFromArray:@[kTKPDDETAIL_APILOCATIONKEY,
                                                    kTKPDSHOP_APIADDRESSNAMEKEY,
                                                    kTKPDSHOP_APIADDRESSIDKEY,
                                                    kTKPDSHOP_APIPOSTALCODEKEY,
                                                    kTKPDSHOP_APIDISTRICTIDKEY,
                                                    kTKPDSHOP_APIFAXKEY,
                                                    kTKPDSHOP_APICITYIDKEY,
                                                    kTKPDSHOP_APIPHONEKEY,
                                                    kTKPDSHOP_APIEMAILKEY,
                                                    kTKPDSHOP_APIPROVINCEIDKEY
                                                    ]];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY toKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY withMapping:closedinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIOWNERKEY toKeyPath:kTKPDDETAILSHOP_APIOWNERKEY withMapping:ownerMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIINFOKEY toKeyPath:kTKPDDETAILSHOP_APIINFOKEY withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISTATKEY toKeyPath:kTKPDDETAILSHOP_APISTATKEY withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY withMapping:shipmentMapping];
    [resultMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY withMapping:shipmentpackageMapping];
    [shipmentMapping addPropertyMapping:shipmentpackageRel];
    
    RKRelationshipMapping *paymentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY toKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY withMapping:paymentMapping];
    [resultMapping addPropertyMapping:paymentRel];
    
    RKRelationshipMapping *addressRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIADDRESSKEY toKeyPath:kTKPDDETAIL_APIADDRESSKEY withMapping:addressMapping];
    [resultMapping addPropertyMapping:addressRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    _requestcount ++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue])
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
	if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOP_APIPATH parameters:param];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            app.networkActivityIndicatorVisible = NO;
            [self requestsuccess:mappingResult withOperation:operation];
            [_timer invalidate];
            _buttonsetting.enabled = YES;
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            app.networkActivityIndicatorVisible = NO;
            [self requestfailure:error];
            [_timer invalidate];
            _buttonsetting.enabled = NO;
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
        _buttonsetting.enabled = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
	}
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _shop = info;
    NSString *statusstring = _shop.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //only save cache for first page
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
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
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id info = [result objectForKey:@""];
            _shop = info;
            NSString *statusstring = _shop.status;
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
            _shop = stats;
            BOOL status = [_shop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                _isnodata = NO;
                _barbuttoninfo.enabled = YES;
                [self setDetailData];
            }
            
            //enable button after request
            _buttonaddproduct.enabled = YES;
            _buttonfav.enabled = YES;
            _buttonMessage.enabled = YES;
            _buttonsetting.enabled = YES;

        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
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
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _detailscrollview.frame.size.width;
    _pagedetail = floor((_detailscrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pagecontrol.currentPage = _pagedetail;
    
    [self scrollContainer];
    
    if (sender.contentOffset.y > self.view.frame.size.height) {
        _scrollview.scrollEnabled = NO;
    } else {
        _scrollview.scrollEnabled = YES;
    }
    
    if (sender.contentOffset.y < 0) {
        CGRect frame = _coverImageView.frame;
        CGPoint translation = [sender.panGestureRecognizer translationInView:sender.superview];
        if(translation.y > 0)
        {
            frame.origin.y = sender.contentOffset.y;
            frame.size.height =  149 + fabsf(sender.contentOffset.y);
        } else {
            frame.origin.y = 0;
            frame.size.height = 149;
        }
        _coverImageView.frame = frame;
    }
    
    if (_shop.result.info.shop_is_gold) {

        if (!navigationBarAnimated) {
            navigationBarAnimated = true;
            if (sender.contentOffset.y > 82) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NavigationShouldUnhide" object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NavigationShouldHide" object:self];
            }
        }
        if (sender.contentOffset.y > 170) {
            _navigationTitleLabel.hidden = NO;
        } else {
            _navigationTitleLabel.hidden = YES;
        }
    }
}



#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    
    if(_data) {
        //cache
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOP_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]]];
        _cachecontroller.filePath = _cachepath;
        _cachecontroller.URLCacheInterval = 86400.0;
        [_cachecontroller initCacheWithDocumentPath:path];
        
        NSDictionary *auth = (NSDictionary *)[_data objectForKey:kTKPD_AUTHKEY];
        if (auth && ![auth isEqual:[NSNull null]]) {
            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue] == [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue]) {
                _buttonsetting.hidden = NO;
                _buttonaddproduct.hidden = NO;

                _buttonfav.hidden = YES;
                _buttonMessage.hidden = YES;
            }
        }
        else
        {
            _buttonsetting.hidden = YES;
            _buttonaddproduct.hidden = YES;
            
            _buttonfav.hidden = NO;
            _buttonMessage.hidden = NO;
        }
        
    }
    
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    _requestcount = 0;
    _isrefreshview = YES;
    
    /** request data **/
    [self configureRestKit];
    [self request];
}


#pragma mark - Notification
- (void)updateView:(NSNotification *)notification;
{
    [self cancel];
    NSDictionary *userinfo = notification.userInfo;
    [_detailfilter addEntriesFromDictionary:userinfo];
    
    [self refreshView:nil];
}

@end


#pragma mark -
#pragma mark UIViewController category

#import <objc/runtime.h>

@implementation UIViewController (TKPDTabShopNavigationController)

- (TKPDTabShopNavigationController*)TKPDTabShopNavigationController
{
	UIViewController* c = self.parentViewController;
	
	while (c != nil) {
		if ([c isKindOfClass:[TKPDTabShopNavigationController class]]) {
			return  (TKPDTabShopNavigationController*)c;
		}
		
		c = c.parentViewController;
	}
	
	return nil;
}

//static void* const kTKPDTabShopNavigationItemKey = (void*)&kTKPDTabShopNavigationItemKey;

@dynamic TKPDTabShopNavigationItem;

- (TKPDTabShopNavigationItem *)TKPDTabShopNavigationItem
{
	//return objc_getAssociatedObject(self, @selector(TKPDTabShopNavigationItem));
	id o = objc_getAssociatedObject(self, @selector(TKPDTabShopNavigationItem));
	
	if (o == nil) {
		o = self.tabBarItem;
		[self setTKPDTabShopNavigationItem:o];
	}
	
	return o;
}

- (void)setTKPDTabShopNavigationItem:(TKPDTabShopNavigationItem *)TKPDTabShopNavigationItem
{
	objc_setAssociatedObject(self, @selector(TKPDTabShopNavigationItem), TKPDTabShopNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
