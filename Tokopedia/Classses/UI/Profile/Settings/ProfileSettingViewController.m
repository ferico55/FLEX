//
//  ProfileSettingViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "ProfileSettingViewController.h"

#import "SettingPasswordViewController.h"
#import "SettingAddressViewController.h"
#import "SettingBankAccountViewController.h"
#import "SettingPrivacyViewController.h"
#import "SettingNotificationViewController.h"

#pragma mark - Profile Setting View Controller
@interface ProfileSettingViewController ()

- (IBAction)tap:(id)sender;
@end

@implementation ProfileSettingViewController

#pragma mark - Initialization
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
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTING_TITLE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_white.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    backBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
        switch (btn.tag) {
            case 10:
            {    //change password
                SettingPasswordViewController *vc = [SettingPasswordViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                //address list
                SettingAddressViewController *vc = [SettingAddressViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                //bank account
                SettingBankAccountViewController *vc = [SettingBankAccountViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 13:
            {
                //notification
                SettingNotificationViewController *vc = [SettingNotificationViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 14:
            {
                //privacy settings
                SettingPrivacyViewController *vc = [SettingPrivacyViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        NSLog(@"\n\n\n\nasdsadsdsdasdsadas\n\n\n\n");
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
