//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import "UserPageHeader.h"
#import "ShopDescriptionView.h"
#import "ShopStatView.h"
#import "detail.h"
#import "string_product.h"
#import "UserAuthentificationManager.h"
#import "ShopSettingViewController.h"
#import "SendMessageViewController.h"
#import "ProductAddEditViewController.h"

#import "LoginViewController.h"



@interface UserPageHeader () <UIScrollViewDelegate, UISearchBarDelegate, LoginViewDelegate> {
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

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avatarIndicator;
@property (weak, nonatomic) IBOutlet UIView *manipulatedView;
@property (weak, nonatomic) IBOutlet UIView *shopClosedView;
@property (weak, nonatomic) IBOutlet UILabel *shopClosedReason;
@property (weak, nonatomic) IBOutlet UILabel *shopClosedUntil;


@end




@implementation UserPageHeader

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
                                             selector:@selector(setHeaderProfilePage:)
                                                 name:@"setHeaderProfilePage"
                                               object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _userManager = [UserAuthentificationManager new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self initNotificationCenter];
    _userManager = [UserAuthentificationManager new];
    
    
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
    //set shop image
    NSURLRequest* requestAvatar = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profile.result.user_info.user_image ?:@""]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_avatarIndicator startAnimating];
    [_profileImage setImageWithURLRequest:requestAvatar placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        _profileImage.image = image;
        _profileImage.hidden = NO;
        
        _profileImage.layer.cornerRadius = _profileImage.frame.size.height /2;
        _profileImage.layer.masksToBounds = YES;
        _profileImage.layer.borderWidth = 0;
#pragma clang diagnostic pop
    } failure:nil];
    
    [_userNameLabel setText:_profile.result.user_info.user_name];
    [_userNameLabel setHidden:NO];
}

- (void)setHeaderProfilePage:(NSNotification*)notification {
    id userinfo = notification.userInfo;
    
    _profile = userinfo;
    [self.delegate didReceiveProfile:_profile];
    if(_profile) {
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
