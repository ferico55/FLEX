//
//  ProfileContactView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileInfo.h"
#import "ProfileContactViewController.h"
#import "UserPageHeader.h"

@interface ProfileContactViewController() <UserPageHeaderDelegate> {
    UserPageHeader *_userHeader;
    ProfileInfo *_profile;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;

@end

@implementation ProfileContactViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(updateView:) name:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil];
        //[nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY object:nil];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add notification
    _userHeader = [UserPageHeader new];
    _userHeader.delegate = self;
    _userHeader.data = _data;
    
    _header = _userHeader.view;
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = _header.frame.size.height;
    self.view.frame = newFrame;
    
    [self.view addSubview:_header];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - Notification
- (void)updateView:(NSNotification *)notification
{
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UserPageHeader Delegate
- (void)didReceiveProfile:(ProfileInfo *)profile {
    _profile = profile;
    
    _labelemail.text = _profile.result.user_info.user_email?:@"-";
    _labelmesseger.text = _profile.result.user_info.user_messenger?:@"-";
    _labelmobile.text = _profile.result.user_info.user_phone?:@"-";
}

- (void)didLoadImage:(UIImage *)image {
    
}

- (id)didReceiveNavigationController {
    return nil;
}

-(void) setHeaderData: (ProfileInfo*) profile {
    _profile = profile;
    [_userHeader setHeaderProfile:_profile];
}

@end
