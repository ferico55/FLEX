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
}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
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


@end




@implementation ShopPageHeader

@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)initButton {
    //    self.leftButton.layer.cornerRadius = 3;
    //    self.leftButton.layer.borderWidth = 1;
    //    self.leftButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    //
    //    self.rightButton.layer.cornerRadius = 3;
    //    self.rightButton.layer.borderWidth = 1;
    //    self.rightButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    //
    _auth = [_userManager getUserLoginData];
    if ([_auth allValues] > 0) {
        //toko sendiri dan login
        if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue] == [[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue]) {
            
        } else {
            
        }
    }
    
    
    
    
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
            //            self.rightButton.tintColor = [UIColor lightGrayColor];
        }
    } else {
        [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
        
        [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
        //        self.rightButton.tintColor = [UIColor lightGrayColor];
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
    [_shopImageView.layer setCornerRadius:(_shopImageView.bounds.size.width / 2.0f)];
    [_shopImageView.layer setMasksToBounds:YES];
    
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
        CGRect newFrame = _luckyBadgeView.frame;
        newFrame.origin.x += _goldBadgeView.frame.size.width;
        [_luckyBadgeView setFrame:newFrame];
    }
    
    
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
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
//    _statView.openStatusLabel.text = _shop.result.info.shop_location;
    [_statView.openStatusLabel setHidden:YES];
    [_statView.statLabel setHidden:YES];
    
    NSString *stats = [NSString stringWithFormat:@"%@ Barang Terjual & %@ Favorit",
                       _shop.result.stats.shop_item_sold,
                       _shop.result.info.shop_total_favorit];
    
    
    
//    [_statView.statLabel setText:stats];
    // Set cover image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    if([[_shop.result.is_open stringValue] isEqualToString:@"2"]) {
        _shopClosedView.hidden = NO;
        NSString *until = [NSString stringWithFormat:@"Toko ini akan tutup sampai : %@",_shop.result.closed_info.until];
        NSString *reason = [NSString stringWithFormat:@"Alasan : %@",_shop.result.closed_info.note];
        [_shopClosedReason setCustomAttributedText:reason];
        [_shopClosedUntil setText:until];
    } else {
        _shopClosedView.hidden = YES;
    }
    
    if(_shop.result.info.shop_is_gold == 1) {
        [_coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            _coverImageView.contentMode = UIViewContentModeScaleToFill;
            _coverImageView.image = image;
            _coverImageView.hidden = NO;
#pragma clang diagnostic pop
        } failure:nil];
    } else {
        [_coverImageView setBackgroundColor:kTKPDNAVIGATION_NAVIGATIONBGCOLOR];
    }
    
    NSURLRequest *requestBadge =  [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_lucky?:@""]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_luckyBadgeView setImageWithURLRequest:requestBadge placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        _luckyBadgeView.contentMode = UIViewContentModeScaleToFill;
        _luckyBadgeView.image = image;
        _luckyBadgeView.hidden = NO;
#pragma clang diagnostic pop
    } failure:nil];

    
    
    //set shop image
    NSURLRequest* requestAvatar = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar?:@""]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_avatarIndicator startAnimating];
    [_shopImageView setImageWithURLRequest:requestAvatar placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        _shopImageView.image = image;
        _shopImageView.hidden = NO;
        
        _shopImageView.layer.cornerRadius = _shopImageView.frame.size.height /2;
        _shopImageView.layer.masksToBounds = YES;
        _shopImageView.layer.borderWidth = 0;
#pragma clang diagnostic pop
    } failure:nil];
    
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