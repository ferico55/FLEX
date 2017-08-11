//
//  SettingNotificationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "ProfileSettings.h"
#import "NotificationForm.h"

#import "SettingNotificationViewController.h"
#import "SettingNotificationCell.h"

@interface SettingNotificationViewController () <SettingNotificationCellDelegate>

@property BOOL isnodata;

@property (strong, nonatomic) NSArray *listMenu;
@property (strong, nonatomic) NSArray *listDescription;
@property (strong, nonatomic) NSMutableArray *listSwitchStatus;

@property (strong, nonatomic) NSMutableDictionary *parameters;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation SettingNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Notifikasi";

    self.navigationItem.rightBarButtonItem = self.saveBarButton;
    
    self.listMenu = @[@"Buletin", @"Review", @"Diskusi Produk", @"Pesan Pribadi", @"Pesan Pribadi dari Admin"];
    self.listDescription = @[@"Setiap promosi, tips & tricks, informasi update seputar Tokopedia",
                             @"Setiap Review dan Komentar yang saya terima",
                             @"Setiap Diskusi Produk dan Komentar yang saya terima",
                             @"Setiap pesan pribadi yang saya terima",
                             @"Setiap pesan pribadi dari admin yang saya terima"];
    self.listSwitchStatus = [NSMutableArray new];

    self.parameters = [NSMutableDictionary new];
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    [self request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Setting Notification Page"];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)saveBarButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTapSaveButton:)];
    return saveButton;
}

- (UIBarButtonItem *)loadingBarButton {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *loadingButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return loadingButton;
}

#pragma mark - Attrbutes 

- (NSDictionary *)textAttributes {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.0;
    NSDictionary *attributes = @{
        NSFontAttributeName            : [UIFont microTheme],
        NSParagraphStyleAttributeName  : style,
        NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1],
    };
    return attributes;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Action

- (void)didTapSaveButton:(id)sender {
    [self requestAction];
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kTKPDSETTINGNOTIFICATIONCELL_IDENTIFIER];
    if (cell == nil) {
        cell = [SettingNotificationCell newcell];
        cell.delegate = self;
    }
    cell.indexPath = indexPath;
    
    cell.notificationName.text = self.listMenu[indexPath.row];
    
    NSString *description = self.listDescription[indexPath.row];
    cell.notificationDetail.attributedText = [[NSAttributedString alloc] initWithString:description attributes:self.textAttributes];

    if (self.listSwitchStatus.count > 0) {
        cell.settingSwitch.on = [self.listSwitchStatus[indexPath.row] boolValue];
        [self SettingNotificationCell: cell withIndexPath:indexPath];
    } else {
        cell.settingSwitch.on = YES;
        [self SettingNotificationCell: cell withIndexPath:indexPath];
    }
    return cell;
}

- (void)SettingNotificationCell:(SettingNotificationCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    NSString *isOn = cell.settingSwitch.on? @"1": @"0";
    if (indexPath.row == 0) {
        [self.parameters setObject:isOn forKey:@"flag_newsletter"];
    } else if (indexPath.row == 1) {
        [self.parameters setObject:isOn forKey:@"flag_review"];
    } else if (indexPath.row == 2) {
        [self.parameters setObject:isOn forKey:@"flag_talk_product"];
    } else if (indexPath.row == 3) {
        [self.parameters setObject:isOn forKey:@"flag_message"];
    } else if (indexPath.row == 4) {
        [self.parameters setObject:isOn forKey:@"flag_admin_message"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

#pragma mark - Request + Mapping

- (void)request {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/people/get_notification.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[NotificationForm mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      weakSelf.navigationItem.rightBarButtonItem = self.saveBarButton;
                                      [weakSelf didReceiveMappingResult:mappingResult];
                                  } onFailure:^(NSError *errorResult) {
                                      [weakSelf didReceiverErrorMessage:errorResult.localizedDescription];
                                  }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    NotificationForm *response = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [response.status isEqualToString:@"OK"];
    if (status) {
        if (response.message_error) {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
            [alert show];
        } else {
            NotificationFormNotif *notification = response.result.notification;
            [self.listSwitchStatus addObject:notification.flag_newsletter];
            [self.listSwitchStatus addObject:notification.flag_review];
            [self.listSwitchStatus addObject:notification.flag_talk_product];
            [self.listSwitchStatus addObject:notification.flag_message];
            [self.listSwitchStatus addObject:notification.flag_admin_message];
            
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiverErrorMessage:(NSString *)errorMessage {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark Request Action

- (void)requestAction {
    self.navigationItem.rightBarButtonItem = self.loadingBarButton;
    __weak typeof(self) weakSelf = self;
    self.networkManager.timeInterval = 100.0;
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/action/people/edit_notification.pl"
                                     method:RKRequestMethodPOST
                                  parameter:self.parameters
                                    mapping:[ProfileSettings mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      weakSelf.navigationItem.rightBarButtonItem = self.saveBarButton;
                                      [weakSelf didReceiveActionMappingResult:mappingResult];
                                  } onFailure:^(NSError *errorResult) {
                                      weakSelf.navigationItem.rightBarButtonItem = self.saveBarButton;
                                      [weakSelf didReceiverErrorMessage:errorResult.localizedDescription];
                                  }];
}

- (void)didReceiveActionMappingResult:(RKMappingResult *)mappingResult {
    ProfileSettings *response = [mappingResult.dictionary objectForKey:@""];
    if (response.message_status) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:response.message_status
                                                                         delegate:self];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (response.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error
                                                                       delegate:self];
        [alert show];
    }
}

@end
