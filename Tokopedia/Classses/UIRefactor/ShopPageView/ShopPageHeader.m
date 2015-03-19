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

#import "LoginViewController.h"

#import "FavoriteShopAction.h"

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
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;


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
    self.leftButton.layer.cornerRadius = 3;
    self.leftButton.layer.borderWidth = 1;
    self.leftButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.borderWidth = 1;
    self.rightButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    
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
            self.rightButton.tintColor = [UIColor lightGrayColor];
        }
    } else {
        [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
        
        [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
        self.rightButton.tintColor = [UIColor lightGrayColor];
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
    [super viewDidLoad];
    _userManager = [UserAuthentificationManager new];
    
    [self initNotificationCenter];
    [self initButton];
    
    _descriptionView = [ShopDescriptionView newView];
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    [self.scrollView addSubview:_statView];
    
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
    _operationQueue = [NSOperationQueue new];
    
    [self.scrollView setContentSize:CGSizeMake(640, 77)];
    
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
    
    _descriptionView.nameLabel.text = _shop.result.info.shop_name;
    [_descriptionView.nameLabel sizeToFit];
    
    if (_shop.result.info.shop_is_gold == 1) {
        _descriptionView.badgeImageView.hidden = NO;
    }
    
    if(_shop.result.info.shop_already_favorited == 1) {
        [self setButtonFav];
    }
    
//    self.title = _shop.result.info.shop_name;
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:15];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };

    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_shop.result.info.shop_description?:@""
                                                                                    attributes:attributes];
    _descriptionView.descriptionLabel.attributedText = productNameAttributedText;
    _descriptionView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    _statView.locationLabel.text = [NSString stringWithFormat:@"     %@", _shop.result.info.shop_location?:@""];
    UIImageView *iconLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location.png"]];
    iconLocation.frame = CGRectMake(0, 0, 20, 20);
    [_statView.locationLabel addSubview:iconLocation];
    
    _statView.openStatusLabel.text = [NSString stringWithFormat:@"Last Online : %@", _shop.result.info.shop_owner_last_login?:@""];
    
    UIFont *boldFont = [UIFont fontWithName:@"GothamMedium" size:15];
    
    NSString *stats = [NSString stringWithFormat:@"%@ Favorited %@ Sold Items",
                       _shop.result.info.shop_total_favorit,
                       _shop.result.stats.shop_item_sold];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:stats];
    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [_shop.result.info.shop_total_favorit length])];
    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange([_shop.result.info.shop_total_favorit length] + 11, [_shop.result.stats.shop_item_sold length])];
    
    [_statView.statLabel setAttributedText:attributedText];
    // Set cover image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        
        _coverImageView.image = image;
        _coverImageView.hidden = NO;

        
#pragma clang diagnostic pop
    } failure:nil];
    
    //set shop image
    NSURLRequest* requestAvatar = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
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
            
            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] == [[auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {
                ProductAddEditViewController *productViewController = [ProductAddEditViewController new];
                productViewController.data = @{
                                               kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                               DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_ADD),
                                               };
                [nav.navigationController pushViewController:productViewController animated:YES];
                break;
            }
            
            if(_auth) {
                // Favorite shop action
                [self configureFavoriteRestkit];
                [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
                [self setButtonFav];
                
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
            
        case 16: {
            [self configureFavoriteRestkit];
            
            [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
            
            _rightButton.tag = 15;
            [_rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            [_rightButton.layer setBorderWidth:1];
            self.rightButton.tintColor = [UIColor lightGrayColor];
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_rightButton setBackgroundColor:[UIColor whiteColor]];
                [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }];
        }
            
        default:
            break;
    }
}

#pragma mark - Request and mapping favorite action

-(void)configureFavoriteRestkit {
    
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                        @"is_success":@"is_success"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/favorite-shop.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)setButtonFav {
    _rightButton.tag = 16;
    [_rightButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
    [_rightButton.layer setBorderWidth:0];
    _rightButton.tintColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_rightButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];

}


-(void)favoriteShop:(NSString*)shop_id sender:(UIButton*)btn
{
    if (_request.isExecuting) return;
    
    _requestCount ++;
    
    NSDictionary *param = @{kTKPDDETAIL_ACTIONKEY   :   @"fav_shop",
                            @"shop_id"              :   shop_id};
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"action/favorite-shop.pl"
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestFavoriteResult:mappingResult withOperation:operation];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFavoriteError:error];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestFavoriteResult:(id)mappingResult withOperation:(NSOperationQueue *)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void)requestFavoriteError:(id)object {
    
}

#pragma mark - Login Delegate
- (void)redirectViewController:(id)viewController {
    
}

@end
