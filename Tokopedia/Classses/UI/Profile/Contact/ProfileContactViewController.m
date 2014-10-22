//
//  ProfileContactView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileInfo.h"
#import "ProfileContactViewController.h"

@interface ProfileContactViewController() {
    ProfileInfo *_profileinfo;
}

@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *labelmesseger;
@property (weak, nonatomic) IBOutlet UILabel *labelmobile;

@end

@implementation ProfileContactViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:TKPD_SETUSERINFODATANOTIFICATIONNAME object:nil];
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:TKPD_SETUSERINFODATANOTIFICATIONNAME object:nil];
    
    _labelemail.text = _profileinfo.result.user_info.user_email?:@"-";
    _labelmesseger.text = _profileinfo.result.user_info.user_messenger?:@"-";
    _labelmobile.text = _profileinfo.result.user_info.user_phone?:@"-";
}


#pragma mark - Notification
- (void)updateView:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    _profileinfo = userinfo;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
