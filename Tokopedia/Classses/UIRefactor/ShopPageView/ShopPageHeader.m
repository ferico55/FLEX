//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//
#import "DetailProductViewController.h"
#import "ShopContainerViewController.h"
#import "ShopPageHeader.h"
#import "ShopDescriptionView.h"
#import "ShopStatView.h"
#import "ShopBadgeLevel.h"
#import "detail.h"
#import "SmileyAndMedal.h"
#import "string_product.h"
#import "UserAuthentificationManager.h"
#import "ShopSettingViewController.h"
#import "SendMessageViewController.h"
#import "ProductAddEditViewController.h"
#import "string_more.h"
#import "LoginViewController.h"
#import "ShopTabView.h"

@import Masonry;

@interface ShopPageHeader () <UIScrollViewDelegate, UISearchBarDelegate, LoginViewDelegate> {
    ShopDescriptionView *_descriptionView;
    ShopStatView *_statView;
    UserAuthentificationManager *_userManager;
    
    NSInteger _requestCount;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
    
    NSDictionary *_auth;
    ShopPageTab _selectedTab;
    IBOutlet UIView *_tabContainer;
}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGoldBadgeWidth;
@property (weak, nonatomic) IBOutlet UIImageView *goldBadgeView;
@property (weak, nonatomic) IBOutlet UIImageView *luckyBadgeView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avatarIndicator;
@property (weak, nonatomic) IBOutlet UIView *manipulatedView;
@property (weak, nonatomic) IBOutlet UIView *navigationTab;
@property (weak, nonatomic) IBOutlet UIView *shopClosedView;
@property (weak, nonatomic) IBOutlet UILabel *shopClosedReason;
@property (weak, nonatomic) IBOutlet UILabel *shopClosedUntil;

@property (strong, nonatomic) IBOutlet UIView *homeMarker;
@property (strong, nonatomic) IBOutlet UIView *productMarker;
@property (strong, nonatomic) IBOutlet UIView *talkMarker;
@property (strong, nonatomic) IBOutlet UIView *reviewMarker;
@property (strong, nonatomic) IBOutlet UIView *noteMarker;


@end




@implementation ShopPageHeader

@synthesize data = _data;

- (instancetype)initWithSelectedTab:(ShopPageTab)tab {
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        _selectedTab = tab;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _selectedTab = ShopPageTabUnknown;
    }
    return self;
}


- (void)initButton {
    _auth = [_userManager getUserLoginData];
    if ([_auth allValues] > 0) {
        if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue] == [[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue]) {
            [self.leftButton setTitle:@"Settings" forState:UIControlStateNormal];
            [self.leftButton setImage:[UIImage imageNamed:@"icon_setting_grey"] forState:UIControlStateNormal];
            
            [self.rightButton setTitle:@"Add Product" forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"icon_plus_grey"] forState:UIControlStateNormal];
        } else {
            [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
            [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
            
            [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
        }
    } else {
        [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
        
        [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
    }
    
    self.leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _auth = [_userManager getUserLoginData];
    
    if(CGSizeEqualToSize(_statView.bounds.size, CGSizeZero)) {
        _statView.frame = CGRectMake(0, _statView.frame.origin.y, self.view.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width*2, 77)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _userManager = [UserAuthentificationManager new];
    [self initButton];
    
    _descriptionView = [ShopDescriptionView newView];
    _descriptionView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, _descriptionView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    _statView.frame = CGRectZero;
    id pageController = ((UIViewController *) _delegate).parentViewController;
    if([pageController isMemberOfClass:[UIPageViewController class]]) {
        if([((UIPageViewController *) pageController).delegate isMemberOfClass:[ShopContainerViewController class]]) {
            [_statView.imgStatistic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopUp:)]];
        }
    }
    
    [self.scrollView addSubview:_statView];
    
    
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
    _operationQueue = [NSOperationQueue new];
    
    [_navigationTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_navigationTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_navigationTab.layer setShadowRadius:1];
    [_navigationTab.layer setShadowOpacity:0.3];
    
    ShopTabView *tabView = [[ShopTabView alloc] initWithTab:_selectedTab];
    [_tabContainer addSubview:tabView];
    
    tabView.showHomeTab = self.showHomeTab;
    
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_tabContainer);
    }];
    
    tabView.onTabSelected = self.onTabSelected;
}

- (void)showPopUp:(id)sender {
    id pageController = ((UIViewController *) _delegate).parentViewController;
    [((ShopContainerViewController *) ((UIPageViewController *) pageController).delegate) showPopUp:[NSString stringWithFormat:@"%@ %@", _shop.result.stats.shop_reputation_score, CStringPoin] withSender:((UITapGestureRecognizer *) sender).view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeaderData {
    _scrollView.hidden = NO;
    _leftButton.enabled = YES;
    _rightButton.enabled = YES;
    
    _descriptionView.nameLabel.text = [NSString stringWithFormat:@"Terakhir Online : %@", _shop.result.info.shop_owner_last_login];
    
    if (_shop.result.info.shop_is_gold == 1) {
        _goldBadgeView.hidden = NO;
    } else {
        _constraintGoldBadgeWidth.constant = 0;
    }
    
    
    
    UIFont *font = [UIFont smallTheme];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;
    style.alignment = NSTextAlignmentLeft;
    
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_shop.result.info.shop_description?:@""
                                                                                    attributes:attributes];
    _descriptionView.descriptionLabel.attributedText = productNameAttributedText;
    _descriptionView.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    _descriptionView.descriptionLabel.numberOfLines = 4;    
    
    _statView.locationLabel.text = _shop.result.info.shop_name;
    [_statView.openStatusLabel setHidden:YES];
    [_statView.statLabel setHidden:YES];
    
    if ([[_shop.result.is_open stringValue] isEqualToString:@"1"]) {
        _shopClosedView.hidden = YES;
    } else if ([[_shop.result.is_open stringValue] isEqualToString:@"2"]) {
        _shopClosedView.hidden = NO;
        NSString *until = [NSString stringWithFormat:@"Toko ini akan tutup sampai : %@",_shop.result.closed_info.until];
        NSString *reason = [NSString stringWithFormat:@"Alasan : %@",_shop.result.closed_info.note];
        [_shopClosedReason setCustomAttributedText:reason];
        [_shopClosedUntil setText:until];
    } else if ([[_shop.result.is_open stringValue] isEqualToString:@"3"]) {
        _shopClosedView.hidden = NO;
        NSString *title = @"Toko dalam status moderasi";
        NSString *description = @"Kami sarankan untuk tidak melakukan transaksi secara langsung di toko ini.";
        [_shopClosedReason setCustomAttributedText:description];
        [_shopClosedUntil setText:title];
    }
    
    if(_shop.result.info.shop_is_gold == 1) {
        [_coverImageView setImageWithURL:[NSURL URLWithString:_shop.result.info.shop_cover?:@""]];
    } else {
        [_coverImageView setBackgroundColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    }
    
    [_luckyBadgeView setImageWithURL:[NSURL URLWithString:_shop.result.info.shop_lucky?:@""]];
    
    [_shopImageView setImageWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar?:@""]
                   placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]];
    
}

- (void)setHeaderShopPage:(Shop*)shop {
    _shop = shop;
    [self.delegate didReceiveShop:_shop];
    if(_shop) {
        [self setHeaderData];
        [self generateMedal];
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float fractionalPage = scrollView.contentOffset.x  / scrollView.frame.size.width;
    NSInteger page = lround(fractionalPage);
    _pageControl.currentPage = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - Method
- (void)generateMedal {
    [SmileyAndMedal generateMedalWithLevel:_shop.result.stats.shop_badge_level.level withSet:_shop.result.stats.shop_badge_level.set withImage:_statView.imgStatistic isLarge:YES];
    _statView.constraintWidthMedal.constant = _statView.imgStatistic.image.size.width;
    
    [_statView.imgStatistic setContentMode:UIViewContentModeLeft];
}


#pragma mark - Actions

- (IBAction)tapButton:(id)sender
{
    NSDictionary *auth = (NSDictionary *)[_data objectForKey:kTKPD_AUTHKEY];
    
    UIButton *button = (UIButton *)sender;
    UINavigationController *nav = [_delegate didReceiveNavigationController];
    switch (button.tag) {
        case 14: {
            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] == [[auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {
                ShopSettingViewController *settingController = [ShopSettingViewController new];
                settingController.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                           kTKPDDETAIL_DATAINFOSHOPSKEY:_shop.result
                                           };
                
                nav.hidesBottomBarWhenPushed = YES;
                [nav.navigationController pushViewController:settingController animated:YES];
                break;
            }
            
            if(_auth) {
                //Send Message
                SendMessageViewController *messageController = [SendMessageViewController new];
                messageController.data = @{
                                           kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                                           kTKPDDETAIL_APISHOPNAMEKEY:_shop.result.info.shop_name
                                           };
                [nav.navigationController pushViewController:messageController animated:YES];
                
            } else {
                UINavigationController *navigationController = [[UINavigationController alloc] init];
                navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                navigationController.navigationBar.translucent = NO;
                navigationController.navigationBar.tintColor = [UIColor whiteColor];
                
                
                LoginViewController *controller = [LoginViewController new];
                controller.delegate = self;
                controller.isPresentedViewController = YES;
                controller.redirectViewController = self;
                navigationController.viewControllers = @[controller];
                
                [nav.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
            
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Login Delegate
- (void)redirectViewController:(id)viewController {
    
}

@end
