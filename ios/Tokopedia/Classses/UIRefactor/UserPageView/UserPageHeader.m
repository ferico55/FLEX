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



@interface UserPageHeader () <UIScrollViewDelegate, UISearchBarDelegate> {
    ShopDescriptionView *_descriptionView;
    ShopStatView *_statView;
    UserAuthentificationManager *_userManager;
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _userManager = [UserAuthentificationManager new];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _userManager = [UserAuthentificationManager new];
    
    
    _descriptionView = [ShopDescriptionView newView];
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    [self.scrollView addSubview:_statView];
    
 
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
    
    [self.scrollView setContentSize:CGSizeMake(640, 77)];
    _profileImage = [UIImageView circleimageview:_profileImage];
    
    //Set icon rate
    btnRate.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfilePicture:)
                                                 name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeaderData {
    NSURL *userImageURL = [NSURL URLWithString:_profile.result.user_info.user_image];
    
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

    if(_profile.result.user_info.user_reputation.no_reputation!=nil && [_profile.result.user_info.user_reputation.no_reputation isEqualToString:@"1"]) {
        [btnRate setImage:[UIImage imageNamed:@"icon_neutral_smile_small"] forState:UIControlStateNormal];
        [btnRate setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [btnRate setImage:[UIImage imageNamed:@"icon_smile_small"] forState:UIControlStateNormal];
        [btnRate setTitle:[NSString stringWithFormat:@"%@%% Positif", _profile.result.user_info.user_reputation.positive_percentage] forState:UIControlStateNormal];
    }
//    CGSize tempSize = [btnRate sizeThatFits:CGSizeMake(self.view.bounds.size.width-20, btnRate.bounds.size.height)];
//    btnRate.frame = CGRectMake((self.view.bounds.size.width-tempSize.width)/2.0f, btnRate.frame.origin.y, tempSize.width+5, btnRate.bounds.size.height);
    btnRate.contentEdgeInsets = UIEdgeInsetsMake(0, -btnRate.imageView.image.size.width/4.0f, 0, 0);
}

- (void)setHeaderProfile:(ProfileInfo *) profile {
    _profile = profile;
    [self.delegate didReceiveProfile: _profile];
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

#pragma mark - Change profile pic notif
- (void)updateProfilePicture:(NSNotification *)notification
{
    NSString *strAvatar = [notification.userInfo objectForKey:@"file_th"]?:@"";
    _profile.result.user_info.user_image = strAvatar;
    [self setHeaderData];
}

@end
