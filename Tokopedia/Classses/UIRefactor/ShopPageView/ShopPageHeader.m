//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import "ShopPageHeader.h"
#import "ShopDescriptionView.h"
#import "ShopStatView.h"
#import "detail.h"
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


- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setHeaderShopPage:)
                                                 name:@"setHeaderShopPage"
                                               object:nil];
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
}

- (void)viewDidLoad
{
    [_shopImageView.layer setCornerRadius:(_shopImageView.bounds.size.width / 2.0f)];
    [_shopImageView.layer setMasksToBounds:YES];
    
    [super viewDidLoad];
    _userManager = [UserAuthentificationManager new];
    
    [self initNotificationCenter];
    [self initButton];
    
    _descriptionView = [ShopDescriptionView newView];
    _descriptionView.frame = CGRectMake(_descriptionView.frame.origin.x, _descriptionView.frame.origin.y, _descriptionView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    [self.scrollView addSubview:_statView];
    
 
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
    _operationQueue = [NSOperationQueue new];
    
    [_navigationTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_navigationTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_navigationTab.layer setShadowRadius:1];
    [_navigationTab.layer setShadowOpacity:0.3];
    
    [self.scrollView setContentSize:CGSizeMake(640, 77)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)coverScreenshot {
    UIGraphicsBeginImageContext(_coverImageView.bounds.size);
    [_coverImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setHeaderData {
    _scrollView.hidden = NO;
    _leftButton.enabled = YES;
    _rightButton.enabled = YES;
    
    _descriptionView.nameLabel.text = [NSString stringWithFormat:@"Terakhir Online : %@", _shop.result.info.shop_owner_last_login];
    
//    [_descriptionView.nameLabel sizeToFit];
    
    if (_shop.result.info.shop_is_gold == 1) {
        _goldBadgeView.hidden = NO;
        
//        CGRect newFrame = self.view.frame;
//        newFrame.size.height += 70;
//        self.view.frame = newFrame;
//        
//        CGRect newFrame2 = _manipulatedView.frame;
//        newFrame2.origin.y += 70;
//        _manipulatedView.frame = newFrame2;
    } else {
//        CGRect newFrame = _manipulatedView.frame;
//        newFrame.origin.y -= 70;
//        _manipulatedView.frame = newFrame;
//        
//        CGRect newFrame2 = self.view.frame;
//        newFrame2.size.height -= 70;
//        self.view.frame = newFrame2;
        
    }
    
    if(_shop.result.info.shop_already_favorited == 1) {
//        [self setButtonFav];
    }
    
//    self.title = _shop.result.info.shop_name;
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;
    style.alignment = NSTextAlignmentCenter;

    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style
                                 };

    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_shop.result.info.shop_description?:@""
                                                                                    attributes:attributes];
    _descriptionView.descriptionLabel.attributedText = productNameAttributedText;
    _descriptionView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionView.descriptionLabel.numberOfLines = 4;
    
    CGRect newFrame = CGRectMake(20, 50, 280, 150);
    _descriptionView.descriptionLabel.frame = newFrame;
    [_descriptionView.descriptionLabel sizeToFit];
    
    CGRect myFrame = _descriptionView.descriptionLabel.frame;
    myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, 280, myFrame.size.height);
    _descriptionView.descriptionLabel.frame = myFrame;
    
    
    
    
    
    _statView.locationLabel.text = _shop.result.info.shop_name;
    
    
    _statView.openStatusLabel.text = _shop.result.info.shop_location;
    
    
    NSString *stats = [NSString stringWithFormat:@"%@ Barang Terjual & %@ Favorit",
                       _shop.result.stats.shop_item_sold,
                       _shop.result.info.shop_total_favorit];
    

    
    [_statView.statLabel setText:stats];
    // Set cover image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    if([[_shop.result.is_open stringValue] isEqualToString:@"2"]) {
        _shopClosedView.hidden = NO;
        NSString *until = [NSString stringWithFormat:@"Toko ini akan tutup sampai : %@",_shop.result.closed_info.until];
        NSString *reason = [NSString stringWithFormat:@"Alasan : %@",_shop.result.closed_info.note];
        [_shopClosedReason setText:reason];
        [_shopClosedUntil setText:until];
    } else {
        _shopClosedView.hidden = YES;
    }

    if(_shop.result.info.shop_is_gold == 1) {
        [_coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            
            _coverImageView.image = image;
            _coverImageView.hidden = NO;
            [self.delegate didLoadImage:image];
            
            
#pragma clang diagnostic pop
        } failure:nil];
    } else {
        [_coverImageView setBackgroundColor:[UIColor clearColor]];
    }
    
    
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

- (void)setHeaderShopPage:(NSNotification*)notification {
    id userinfo = notification.userInfo;
    
    _shop = userinfo;
    [self.delegate didReceiveShop:_shop];
    if(_shop) {
        [self setHeaderData];
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
            
        case 15: {
            
//            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] == [[auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {
//                ProductAddEditViewController *productViewController = [ProductAddEditViewController new];
//                productViewController.data = @{
//                                               kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
//                                               DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_ADD),
//                                               };
//                [nav.navigationController pushViewController:productViewController animated:YES];
//                break;
//            }
//            
//            if(_auth) {
//                // Favorite shop action
//                [self configureFavoriteRestkit];
//                [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
//                [self setButtonFav];
//                
//            } else {
//                UINavigationController *navigationController = [[UINavigationController alloc] init];
//                navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
//                navigationController.navigationBar.translucent = NO;
//                navigationController.navigationBar.tintColor = [UIColor whiteColor];
//                
//                
//                LoginViewController *controller = [LoginViewController new];
//                controller.delegate = self;
//                controller.isPresentedViewController = YES;
//                controller.redirectViewController = self;
//                navigationController.viewControllers = @[controller];
//                
//                [nav.navigationController presentViewController:navigationController animated:YES completion:nil];
//            }
            
            
            break;
        }
            
        case 16: {
//            [self configureFavoriteRestkit];
//            
//            [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
//            
//            _rightButton.tag = 15;
//            [_rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
//            [_rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
//            [_rightButton.layer setBorderWidth:1];
////            self.rightButton.tintColor = [UIColor lightGrayColor];
//            [UIView animateWithDuration:0.3 animations:^(void) {
//                [_rightButton setBackgroundColor:[UIColor whiteColor]];
//                [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            }];
        }
            
        default:
            break;
    }
}

#pragma mark - Login Delegate
- (void)redirectViewController:(id)viewController {
    
}

@end
