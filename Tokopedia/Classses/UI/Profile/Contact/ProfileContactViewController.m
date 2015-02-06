//
//  ProfileContactView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileInfo.h"
#import "ProfileContactViewController.h"

@interface ProfileContactViewController()

@end

@implementation ProfileContactViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(updateView:) name:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil];
        [nc addObserver:self selector:@selector(updateView:) name:kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY object:nil];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add notification
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - Notification
- (void)updateView:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    ProfileInfo *profileinfo = userinfo;
    _labelemail.text = profileinfo.result.user_info.user_email?:@"-";
    _labelmesseger.text = profileinfo.result.user_info.user_messenger?:@"-";
    _labelmobile.text = profileinfo.result.user_info.user_phone?:@"-";
    
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
