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
#import "UserContainerViewController.h"
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
    
    _listMenu = ARRAY_LIST_MENU_SETTING_PROFILE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Profile Settings Page"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {    //change password
                SettingPasswordViewController *vc = [SettingPasswordViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                //address list
                SettingAddressViewController *vc = [SettingAddressViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                //bank account
                SettingBankAccountViewController *vc = [SettingBankAccountViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 13:
            {
                //notification
                SettingNotificationViewController *vc = [SettingNotificationViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 14:
            {
                //ubah profil
                SettingUserProfileViewController *vc = [SettingUserProfileViewController new];
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

                if ([[self.navigationController.viewControllers objectAtIndex:1] isKindOfClass:[UserContainerViewController class]]) {
                    UserContainerViewController *userContainer = [self.navigationController.viewControllers objectAtIndex:1];
                    if ([userContainer conformsToProtocol:@protocol(SettingUserProfileDelegate) ]) {
                        vc.delegate = (id <SettingUserProfileDelegate>)userContainer;
                    }
                }
                
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
