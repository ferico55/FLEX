//
//  MainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "MainViewController.h"

#import "LoginViewController.h"
#import "SearchViewController.h"
#import "TransactionCartRootViewController.h"
#import "MoreNavigationController.h"
#import "MoreViewController.h"
#import "CategoryViewController.h"

#import "TKPDTabHomeViewController.h"

#import "HotlistViewController.h"
#import "ProductFeedViewController.h"
#import "HistoryProductViewController.h"
#import "FavoritedShopViewController.h"

#import "activation.h"

#import "TKPDSecureStorage.h"
#import "URLCacheController.h"

@interface MainViewController () <UITabBarControllerDelegate, LoginViewDelegate>
{
    UITabBarController *_tabBarController;
    TKPDTabHomeViewController *_swipevc;
    NSMutableDictionary *_auth;
    URLCacheController *_cacheController;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _auth = [NSMutableDictionary new];
    _cacheController = [URLCacheController new];
    
    
    [self performSelector:@selector(viewDidLoadQueued) withObject:nil afterDelay:kTKPDMAIN_PRESENTATIONDELAY];	//app launch delay presentation
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationLogin:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION object:nil];
    [center addObserver:self selector:@selector(applicationlogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil];

    [center addObserver:self selector:@selector(updateTabBarMore:) name:UPDATE_TABBAR object:nil];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Memory Management
-(void)dealloc
{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma methods

- (void)viewDidLoadQueued
{
	//NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];	//TODO: secure storage
    //id auth = [defaults loadCustomObjectWithKey:kTKPD_AUTHKEY];
    //id auth = [defaults objectForKey:kTKPD_AUTHKEY];
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
	NSDictionary* auth = [secureStorage keychainDictionary];
	_auth = [auth mutableCopy];
    	
    _data = nil;
    [self presentcontrollers];
}

-(void)presentcontrollers
{
    [self createtabbarController];
    
    _tabBarController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:_tabBarController animated:YES completion:^{
		
	}];
}

-(void)createtabbarController
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    _tabBarController = [UITabBarController new];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : kTKPDNAVIGATION_TABBARTITLECOLOR }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : kTKPDNAVIGATION_TABBARACTIVETITLECOLOR }
                                             forState:UIControlStateSelected];
    
    /** TAB BAR INDEX 1 **/
    NSArray *titles;
    /** adjust view controllers at tab bar controller **/
    NSMutableArray *viewcontrollers = [NSMutableArray new];
    /** create new view controller **/
    if (!isauth) {
        // before login
        titles = kTKPD_HOMETITLEARRAY;
        HotlistViewController *v = [HotlistViewController new];
        v.data = @{kTKPD_AUTHKEY : _auth?:@{}};
        [viewcontrollers addObject:v];
    }
    else{
        // after login
        titles = kTKPD_HOMETITLEISAUTHARRAY;
        HotlistViewController *v = [HotlistViewController new];
        v.data = @{kTKPD_AUTHKEY : _auth?:@{}};
        [viewcontrollers addObject:v];
        ProductFeedViewController *v1 = [ProductFeedViewController new];
        [viewcontrollers addObject:v1];
        HistoryProductViewController *v2 = [HistoryProductViewController new];
        [viewcontrollers addObject:v2];
        FavoritedShopViewController *v3 = [FavoritedShopViewController new];
        [viewcontrollers addObject:v3];
    }
    
//    /** Adjust View Controller **/
    _swipevc = [TKPDTabHomeViewController new];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:_swipevc];
    
    
    /** TAB BAR INDEX 2 **/
    CategoryViewController *categoryvc = [CategoryViewController new];
    UINavigationController *categoryNavBar = [[UINavigationController alloc]initWithRootViewController:categoryvc];
    [categoryNavBar.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        categoryvc.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 3 **/
    SearchViewController *search = [SearchViewController new];
    if (_auth) {
        search.data = @{kTKPD_AUTHKEY:_auth?:@{}};
    }
    UINavigationController *searchNavBar = [[UINavigationController alloc]initWithRootViewController:search];
    searchNavBar.navigationBar.translucent = NO;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        search.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 4 **/
    TransactionCartRootViewController *cart = [TransactionCartRootViewController new];
    UINavigationController *cartNavBar = [[UINavigationController alloc]initWithRootViewController:cart];
    [cartNavBar.navigationBar setTranslucent:NO];
    //[cartNavBar.navigationItem setTitleView:logo];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
        cart.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /** TAB BAR INDEX 5 **/
    UINavigationController *moreNavBar;
    if (!isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MoreNavigationController *moreNavController = [storyboard instantiateViewControllerWithIdentifier:@"MoreNavigationViewController"];
        moreNavBar = moreNavController;
    }

    [moreNavBar.navigationBar setTranslucent:NO];
    
    /** for ios 7 need to set automatically adjust scrooll view inset **/
    if([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)])
    {
        _swipevc.extendedLayoutIncludesOpaqueBars = YES;
        categoryvc.extendedLayoutIncludesOpaqueBars = YES;
        search.extendedLayoutIncludesOpaqueBars = YES;
        cart.extendedLayoutIncludesOpaqueBars = YES;
        moreNavBar.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    NSArray* controllers = [NSArray arrayWithObjects:swipevcNav, categoryNavBar, searchNavBar, cartNavBar, moreNavBar, nil];
    _tabBarController.viewControllers = controllers;
    _tabBarController.delegate = self;
    //tabBarController.tabBarItem.title = nil;
    [self adjusttabbar];
}

-(void)adjusttabbar
{
    UITabBar *tabbar = _tabBarController.tabBar;
    
    UITabBarItem *tabBarItem1 = [tabbar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabbar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabbar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabbar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabbar.items objectAtIndex:4];
    
    UIImage *image;
    UIImage *image_active;
    /** set tab bar item 1**/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_HOME];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_HOME];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem1 setImage:image];
        [tabBarItem1 setSelectedImage:image_active];
        
        
    }
    else{
        [tabBarItem1 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    }
    //tabBarItem1.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem1.title = kTKPDNAVIGATION_TABBARTITLEARRAY[0];
    
    [tabBarItem1 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 2**/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_CATEGORY];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_CATEGORY];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem2 setImage:image];
        [tabBarItem2 setSelectedImage:image_active];
    }
    else
        [tabBarItem2 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem2.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem2.title = kTKPDNAVIGATION_TABBARTITLEARRAY[1];
    
    [tabBarItem2 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 3*/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_SEARCH];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_SEARCH];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem3 setImage:image];
        [tabBarItem3 setSelectedImage:image_active];
    }
    else
        [tabBarItem3 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem3.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem3.title = kTKPDNAVIGATION_TABBARTITLEARRAY[2];
    
    [tabBarItem3 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 4*/
    image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_CART];
    image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_CART];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem4 setImage:image];
        [tabBarItem4 setSelectedImage:image_active];
    }
    else
        [tabBarItem4 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem4.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    tabBarItem4.title = kTKPDNAVIGATION_TABBARTITLEARRAY[3];
    
    [tabBarItem4 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
    /** set tab bar item 5*/
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY]boolValue];
    if(isauth) {
        image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_MORE];
        image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_MORE];
    } else {
        image =[UIImage imageNamed:kTKPDIMAGE_ICONTABBAR_LOGIN];
        image_active =[UIImage imageNamed:kTKPDIMAGE_ICONTABBARACTIVE_LOGIN];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image_active = [image_active imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [tabBarItem5 setImage:image];
        [tabBarItem5 setSelectedImage:image_active];
    }
    else
        [tabBarItem5 setFinishedSelectedImage:image_active withFinishedUnselectedImage:image];
    //tabBarItem5.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    if(isauth) {
        tabBarItem5.title = kTKPDNAVIGATION_TABBARTITLEARRAY[4];
    } else {
        tabBarItem5.title = kTKPDNAVIGATION_TABBARTITLEARRAY[5];
    }

    [tabBarItem5 setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"GothamBook" size:9.0], UITextAttributeFont,
      nil]
                               forState:UIControlStateNormal];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    
    NSBundle* bundle = [NSBundle mainBundle];
	//UIImage* image;
	id proxy = [UITabBar appearance];
    
	image = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_TABBARBG ofType:@"png"]]; //navigation-bg
    
    [proxy setBackgroundImage:image];
    [proxy setSelectedImageTintColor:[UIColor blackColor]];
    
    //[proxy setShadowImage:[UIImage imageNamed:kTKPDIMAGE_NAVBARBG]];
    
    // Omit the conditional if minimum OS is iOS 6 or above
    if ([UITabBar instancesRespondToSelector:@selector(setShadowBlurRadius:)]) {
        [proxy setShadowBlurRadius:0];
    }
    
    [proxy setShadowImage:[[UIImage alloc] init]];
    
#endif
}

#pragma mark - Notification observers

- (void)applicationLogin:(NSNotification*)notification
{
    NSDictionary* auth = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
	_auth = [auth mutableCopy];
    
    BOOL isauth = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
    
    //refreshing cart when first login
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];

	// Assume tabController is the tab controller
    // and newVC is the controller you want to be the new view controller at index 0
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:_tabBarController.viewControllers];
    UINavigationController *swipevcNav = [[UINavigationController alloc]initWithRootViewController:_swipevc];
    swipevcNav.navigationBar.translucent = NO;
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [_swipevc.navigationItem setTitleView:logo];

    UINavigationController *searchNavBar = newControllers[2];
    id search = searchNavBar.viewControllers[0];
    if (_auth) {
        ((SearchViewController*)search).data = @{kTKPD_AUTHKEY:_auth?:@{}};
    }
    
    UINavigationController *moreNavBar = newControllers[4];
    if (!isauth) {
        LoginViewController *more = [LoginViewController new];
        moreNavBar = [[UINavigationController alloc]initWithRootViewController:more];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        MoreNavigationController *moreNavController = [storyboard instantiateViewControllerWithIdentifier:@"MoreNavigationViewController"];
        moreNavBar = moreNavController;
    }
    [moreNavBar.navigationBar setTranslucent:NO];

    [newControllers replaceObjectAtIndex:0 withObject:swipevcNav];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavBar];

    [_tabBarController setViewControllers:newControllers animated:YES];

    [self adjusttabbar];
}

- (void)updateTabBarMore:(NSNotification*)notification
{
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:_tabBarController.viewControllers];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MoreNavigationController *moreNavController = [storyboard instantiateViewControllerWithIdentifier:@"MoreNavigationViewController"];
    [moreNavController.navigationBar setTranslucent:NO];
    [newControllers replaceObjectAtIndex:4 withObject:moreNavController];
    [_tabBarController setViewControllers:newControllers animated:YES];
    
    [self adjusttabbar];
}

- (void)applicationlogout:(NSNotification*)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Apakah Anda yakin ingin keluar ?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Batal"
                                              otherButtonTitles:@"Iya", nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)doApplicationLogout {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [_cacheController initCacheWithDocumentPath:path];
    [_cacheController clearCache];
    
    
    TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
    [storage resetKeychain];	//delete all previous sensitive data
    [_auth removeAllObjects];
    
    [self performSelector:@selector(applicationLogin:) withObject:nil afterDelay:kTKPDMAIN_PRESENTATIONDELAY];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            [self doApplicationLogout];
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    BOOL _isLogin = [[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue];
//    if(!_isLogin) {
//        if(tabBarController.selectedIndex == 3) {
//            UINavigationController *navigationController = [[UINavigationController alloc] init];
//            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
//            navigationController.navigationBar.translucent = NO;
//            navigationController.navigationBar.tintColor = [UIColor whiteColor];
//            
//            
//            LoginViewController *controller = [LoginViewController new];
//            controller.delegate = _tabBarController.viewControllers[3];
//            controller.isPresentedViewController = YES;
//            controller.redirectViewController = _tabBarController.viewControllers[3];
//            navigationController.viewControllers = @[controller];
//            UIViewController *nav = _tabBarController.viewControllers[3];
//            [nav presentViewController:navigationController animated:YES completion:nil];
//        }
//    }
}

-(void)redirectViewController:(id)viewController {
    
}

@end
