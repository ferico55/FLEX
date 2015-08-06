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
    
    _profileImage = [UIImageView circleimageview:_profileImage];
    
    //Set icon rate
    btnRate.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnRate setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile20" ofType:@"png"]] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeaderData {
    NSURL *userImageURL;
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    if ([auth.getUserId isEqualToString:_profile.result.user_info.user_id]) {
        userImageURL = [NSURL URLWithString:[auth.getUserLoginData objectForKey:@"user_image"]];
    } else {
        userImageURL = [NSURL URLWithString:_profile.result.user_info.user_image];
    }
    
    NSURLRequest* requestAvatar = [[NSURLRequest alloc] initWithURL:userImageURL
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_avatarIndicator startAnimating];
    [_profileImage setImageWithURLRequest:requestAvatar
                         placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        _profileImage.image = image;
        _profileImage.hidden = NO;
    
#pragma clang diagnostic pop
    } failure:nil];
    
    [_userNameLabel setText:_profile.result.user_info.user_name];
    [_userNameLabel setHidden:NO];
    [btnRate setTitle:[NSString stringWithFormat:@"%@%% Positif", _profile.result.user_info.user_reputation.positive_percentage] forState:UIControlStateNormal];
//    CGSize tempSize = [btnRate sizeThatFits:CGSizeMake(self.view.bounds.size.width-20, btnRate.bounds.size.height)];
//    btnRate.frame = CGRectMake((self.view.bounds.size.width-tempSize.width)/2.0f, btnRate.frame.origin.y, tempSize.width+5, btnRate.bounds.size.height);
    btnRate.contentEdgeInsets = UIEdgeInsetsMake(0, -btnRate.imageView.image.size.width/4.0f, 0, 0);
}

- (void)setHeaderProfilePage:(NSNotification*)notification {
    id userinfo = notification.userInfo;
    
    _profile = [userinfo objectForKey:@"profile"];
    [self.delegate didReceiveProfile:_profile];
    if(_profile) {
        [self setHeaderData];
    }
}

#pragma mark - Setter Getter
- (UIView *)getManipulatedView
{
    return _manipulatedView;
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
    [_delegate didReceiveNavigationController];
}

#pragma mark - Login Delegate
- (void)redirectViewController:(id)viewController {
    
}



@end
