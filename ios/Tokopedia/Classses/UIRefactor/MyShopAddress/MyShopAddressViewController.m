//
//  MyShopAddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "generalcell.h"
#import "SettingLocation.h"
#import "ShopSettings.h"
#import "MyShopAddressViewController.h"
#import "MyShopAddressDetailViewController.h"
#import "MyShopAddressEditViewController.h"
#import "GeneralList1GestureCell.h"
#import "MGSwipeButton.h"
#import "URLCacheController.h"

#import "UITableView+IndexPath.h"
#import "NSURL+Dictionary.h"

#import "NoResultReusableView.h"
#import "LoadingView.h"
#import "Tokopedia-Swift.h"

@interface MyShopAddressViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    MyShopAddressDetailViewControllerDelegate,
    UIScrollViewDelegate,
    MGSwipeTableCellDelegate,
    NoResultDelegate,
    LoadingViewDelegate
>

@property BOOL isManualSetDefault;
@property BOOL isManualDelete;
@property BOOL isNoData;
@property BOOL isAddressExpanded;

@property (strong, nonatomic) NSMutableDictionary *inputData;
@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NoResultReusableView *noResultView;
@property (strong, nonatomic) LoadingView *loadingView;

@end

@implementation MyShopAddressViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Lokasi Toko";
    self.navigationItem.backBarButtonItem = self.backButton;
    self.navigationItem.rightBarButtonItem = self.addLocationButton;
    
    _isNoData = YES;
    _isManualSetDefault = NO;
    _isManualDelete = NO;
    _list = [NSMutableArray new];
    _inputData = [NSMutableDictionary new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditAddress:) name:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY object:nil];
    
    [self.tableView addSubview:self.refreshControl];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    [self fetchShopAddress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop Address Setting Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Memory Management

- (void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Bar button items

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    return button;
}

- (UIBarButtonItem *)addLocationButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton:)];
    return button;
}

#pragma mark - Refresh control

- (UIRefreshControl *)refreshControl {
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
        [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

#pragma mark - Loading view

- (LoadingView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [LoadingView new];
        _loadingView.delegate = self;
    }
    return _loadingView;
}

#pragma mark - No result view

- (NoResultReusableView *)noResultView {
    if (_noResultView == nil) {
        _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
        _noResultView.delegate = self;
        [_noResultView generateAllElements:nil
                                     title:@"Tidak ada Lokasi Toko"
                                      desc:@"Segera tambahkan lokasi toko Anda!"
                                  btnTitle:@"Tambah Lokasi"];
    }
    return _noResultView;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
    GeneralList1GestureCell* cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralList1GestureCell newcell];
        cell.delegate = self;
    }
    if (_list.count > indexPath.row) {
        Address *list = _list[indexPath.row];
        cell.textLabel.text = list.location_address_name;
        cell.detailTextLabel.text = @"";
        cell.type = kTKPDGENERALCELL_DATATYPEONEBUTTONKEY;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isDefault;
    if (_isManualSetDefault) {
        isDefault = (indexPath.row == 0)? YES: NO;
    }
    
    MyShopAddressDetailViewController *controller = [MyShopAddressDetailViewController new];
    NSDictionary *data = @{
                           kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                           kTKPDDETAIL_DATAADDRESSKEY : _list[indexPath.row],
                           kTKPDDETAIL_DATAINDEXPATHKEY : indexPath,
                           kTKPDDETAIL_DATAISDEFAULTKEY : @(isDefault)
                           };
    controller.data = [NSMutableDictionary dictionaryWithDictionary:data];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteListAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id dataObject = [_list objectAtIndex:sourceIndexPath.row];
    [_list removeObjectAtIndex:sourceIndexPath.row];
    [_list insertObject:dataObject atIndex:destinationIndexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView reloadData];
}

#pragma mark - Restkit

- (void)fetchShopAddress {
    if (_refreshControl.isRefreshing == NO && self.list.count == 0) {
        [self.activityIndicatorView startAnimating];
        self.tableView.tableFooterView = _tableFooterView;
    }
    
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/myshop-address/get_location.pl";
    NSDictionary *parameters = @{@"action": @"get_location"};
    [_networkManager requestWithBaseUrl:baseURL
                                   path:path
                                 method:RKRequestMethodGET
                              parameter:parameters
                                mapping:[SettingLocation objectMapping]
                              onSuccess:^(RKMappingResult *mappingResult,
                                          RKObjectRequestOperation *operation) {
                                  SettingLocation *response = [mappingResult.dictionary objectForKey:@""];
                                  if (response.result.list.count > 0) {
                                      self.list = [NSMutableArray arrayWithArray:response.result.list];
                                      self.tableView.tableFooterView = nil;
                                  } else {
                                      self.tableView.tableFooterView = self.noResultView;
                                  }
                                  [self.tableView reloadData];
                              }
                              onFailure:^(NSError *errorResult) {
                                  self.tableView.tableFooterView = self.loadingView;
                                  [self.tableView reloadData];
                              }];
}

- (void)removeShopAddress {
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/myshop-address/delete_location.pl";
    Address *address = [_inputData objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    NSDictionary *parameters = @{@"location_address_id": address.location_address_id};

    NSInteger index = [_list indexOfObject:address];
    [_list removeObject:address];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

    [_networkManager requestWithBaseUrl:baseURL
                                   path:path
                                 method:RKRequestMethodGET
                              parameter:parameters
                                mapping:[ShopSettings mapping]
                              onSuccess:^(RKMappingResult *mappingResult,
                                          RKObjectRequestOperation *operation) {
                                  ShopSettings *response = [mappingResult.dictionary objectForKey:@""];
                                  if (response.result.is_success == 1) {
                                      NSString *message = @"Anda telah berhasil menghapus lokasi.";
                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
                                      [alert show];
                                      if (_list.count == 0) {
                                          self.tableView.tableFooterView = _noResultView;
                                      }
                                  } else {
                                      [_list insertObject:address atIndex:index];
                                      [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                  }
                                  if (response.message_error) {
                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
                                      [alert show];
                                  }
                              }
                              onFailure:^(NSError *error) {
                                  [_list insertObject:address atIndex:index];
                                  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                  StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                  [alert show];
                              }];
}


#pragma mark - View Action

- (IBAction)didTapAddButton:(id)sender {
    if (self.list.count == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Anda hanya bisa menambah sampai 3 alamat." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    MyShopAddressEditViewController *controller = [MyShopAddressEditViewController new];
    controller.data = @{
        kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY)
    };
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}


#pragma mark - Cell Delegate

-(void)GeneralList1GestureCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    BOOL isdefault;
    MyShopAddressDetailViewController *controller = [MyShopAddressDetailViewController new];
    controller.data = [NSMutableDictionary dictionaryWithDictionary:@{
        kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
        kTKPDDETAIL_DATAADDRESSKEY : _list[indexpath.row],
        kTKPDDETAIL_DATAINDEXPATHKEY : indexpath,
        kTKPDDETAIL_DATAISDEFAULTKEY : @(isdefault)
    }];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSArray *)swipeTableCell:(GeneralList1GestureCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1;
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        CGFloat padding = 15;
        UIColor *redColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton *trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                              backgroundColor:redColor
                                                      padding:padding
                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                         NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                                         [self deleteListAtIndexPath:indexPath];
                                                         return YES;
                                                     }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];
        return @[trash];
    }
    return nil;
}

#pragma mark - delegate address detail

-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data {
    NSIndexPath *indexPath = [data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [self deleteListAtIndexPath:indexPath];
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    [self fetchShopAddress];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath {
    self.isManualDelete = YES;
    [AnalyticsManager trackEventName:@"clickLocation" category:GA_EVENT_CATEGORY_SHOP_LOCATION action:GA_EVENT_ACTION_CLICK label:@"Delete"];
    [self.inputData setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [self.inputData setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [self removeShopAddress];
}

#pragma mark - Notification

- (void)didEditAddress:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_inputData setObject:[userinfo objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    [self refreshView:nil];
}

#pragma mark - No Result delegate

- (void)buttonDidTapped:(id)sender {
    [self didTapAddButton:self.navigationItem.rightBarButtonItem];
}

#pragma mark - Loading view delegate

- (void)pressRetryButton {
    [self fetchShopAddress];
}

@end
