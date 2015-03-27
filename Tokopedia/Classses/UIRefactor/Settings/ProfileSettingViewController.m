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
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    _listMenu = ARRAY_LIST_MENU_SETTING_PROFILE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
                //ubah profil
//                SettingPrivacyViewController *vc = [SettingPrivacyViewController new];
//                vc.data = @{kTKPD_AUTHKEY : auth};
                SettingUserProfileViewController *vc = [SettingUserProfileViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TableView Data Source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listMenu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listMenuPerSection = _listMenu[section];
    return listMenuPerSection.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
    UITableViewCell* cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgView.image = [UIImage imageNamed:@"icon_lock_grey.png"];
        cell.imageView.image = imgView.image;
    }
    
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    cell.textLabel.text = _listMenu[indexPath.section][indexPath.row];
    
    return cell;
}

#pragma mark - TableView Delegeta
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    if (indexPath.section == 0 && indexPath.row == 0) {
        SettingPasswordViewController *vc = [SettingPasswordViewController new];
        vc.data = @{kTKPD_AUTHKEY : auth};
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        switch (indexPath.row) {
            case 0:
            {
                //address list
                SettingAddressViewController *vc = [SettingAddressViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1:
            {
                //bank account
                SettingBankAccountViewController *vc = [SettingBankAccountViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2:
            {
                //notification
                SettingNotificationViewController *vc = [SettingNotificationViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 3:
            {
                //privacy settings
                SettingUserProfileViewController *vc = [SettingUserProfileViewController new];
                vc.data = @{kTKPD_AUTHKEY : auth};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

@end
