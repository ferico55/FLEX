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
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // add notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:TKPD_SETUSERINFODATANOTIFICATIONNAME object:nil];
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
