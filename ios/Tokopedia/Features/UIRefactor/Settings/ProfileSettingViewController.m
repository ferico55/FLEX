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
#import "SettingUserProfileViewController.h"
#import "Tokopedia-Swift.h"

#pragma mark - Profile Setting View Controller
@interface ProfileSettingViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_listMenu;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ProfileSettingViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = TITLE_SETTING_PROFILE_MENU;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _listMenu = @[@[@"Ubah Kata Sandi"],
                  @[@"Biodata Diri" ,
                    @"Daftar Alamat",
                    @"Akun Bank",
                    @"Pembayaran",
                    @"Notifikasi"],
                  @[[NSString authenticationType]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Profile Settings Page"];
}

#pragma mark - TableView Data Source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (![[TouchIDHelper sharedInstance] isTouchIDAvailable]) {
        return _listMenu.count - 1;
    }
    return _listMenu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listMenuPerSection = _listMenu[section];
    return listMenuPerSection.count;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 3) {
        cell.detailTextLabel.text = @"BARU";
        cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:33.0/255.0 blue:45.0/255.0 alpha:1];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont microThemeMedium];
        cell.detailTextLabel.layer.cornerRadius = 5;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
    UITableViewCell* cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgView.image = [UIImage imageNamed:@"icon_lock_grey.png"];
        cell.imageView.image = imgView.image;
    }
    
    cell.textLabel.font = [UIFont title2Theme];
    cell.textLabel.text = _listMenu[indexPath.section][indexPath.row];
    cell.textLabel.textColor = [UIColor tpSecondaryBlackText];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

#pragma mark - TableView Delegeta
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        SettingPasswordViewController *vc = [SettingPasswordViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [AnalyticsManager trackEventName:@"clickProfile" category:@"Profile Setting" action:GA_EVENT_ACTION_CLICK label:@"Touch ID"];
        
        //Touch ID settings
        SettingTouchIDViewController *vc = [SettingTouchIDViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        switch (indexPath.row) {
            case 0: {
                //button edit profile action
                SettingUserProfileViewController *vc = [SettingUserProfileViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1: {
                //address list
                SettingAddressViewController *vc = [SettingAddressViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2: {
                //bank account
                SettingBankAccountViewController *vc = [SettingBankAccountViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 3: {
                //Pembayaran
                PaymentViewController *vc = [PaymentViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 4: {
                //notification
                SettingNotificationViewController *vc = [SettingNotificationViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

@end
