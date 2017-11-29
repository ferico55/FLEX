//
//  SettingAddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_settings.h"
#import "profile.h"
#import "AddressForm.h"
#import "ProfileSettings.h"
#import "GeneralList1GestureCell.h"
#import "GeneralCheckmarkCell.h"
#import "LoadingView.h"
#import "SettingAddressViewController.h"
#import "SettingAddressDetailViewController.h"
#import "SettingAddressEditViewController.h"
#import "SettingAddressExpandedCell.h"
#import "TokopediaNetworkManager.h"

#import "MGSwipeButton.h"

#import "RequestObject.h"
#import "Tokopedia-Swift.h"

@interface SettingAddressViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    MGSwipeTableCellDelegate,
    SettingAddressEditViewControllerDelegate,
    LoadingViewDelegate
>
{
    NSInteger _page;
    
    NSString *_urinext;
    
    BOOL _ismanualsetdefault;
    
    NSIndexPath *_selectedIndexPath;
    AddressFormList *selectedAddress;
    
    UIRefreshControl *_refreshControl;
    
    NSMutableDictionary *_datainput;
        
    BOOL _isaddressexpanded;
    
    UIBarButtonItem *_doneBarButtonItem;
    UIBarButtonItem *_cancelBarButtonItem;
    LoadingView *loadingView;
    NSIndexPath *_indexPath;
    
    NSString *_searchKeyword;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *searchBarView;
@property (strong, nonatomic) IBOutlet UIView *addNewAddressView;

@end

@implementation SettingAddressViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _ismanualsetdefault = NO;
        self.title = TITLE_LIST_ADDRESS;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 40;
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PROFILE_ATC|| type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO || type == TYPE_ADD_EDIT_PROFILE_ADD_RESO) {
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                              style:UIBarButtonItemStylePlain
                                                             target:(self)
                                                             action:@selector(tapDoneBarButtonItem:)];
        self.navigationItem.rightBarButtonItem = _doneBarButtonItem;

        [self.view addSubview:_addNewAddressView];
        _table.contentInset = UIEdgeInsetsMake(_addNewAddressView.frame.size.height, 0, 0, 0);
        
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Cari Alamat";
        _searchBar.userInteractionEnabled = YES;
        
    } else {
        
        UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                      target:self
                                                                                      action:@selector(tapAddBarButtonItem:)];
        self.navigationItem.rightBarButtonItem = addBarButton;
        
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:nil];
        backBarButton.tag = 10;
        self.navigationItem.backBarButtonItem = backBarButton;
        
        //_table.tableHeaderView = _searchBarView;
        [self.view addSubview:_searchBarView];
        _table.contentInset = UIEdgeInsetsMake(_searchBarView.frame.size.height, 0, 0, 0);
    }

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_table setTableHeaderView:_refreshControl];
    _table.scrollIndicatorInsets = UIEdgeInsetsMake(_refreshControl.frame.size.height - 15, 0, 0, 0);
    _table.delaysContentTouches = YES;
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    [_datainput addEntriesFromDictionary:_data];
    
    _page = 1;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didEditAddress:) name:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY object:nil];

    _selectedIndexPath = [_data objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    [self request];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Setting Address Page"];
}

-(void)viewDidLayoutSubviews {
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _searchBarView.frame;
    frame.size.width = screenWidth;
    _searchBarView.frame = frame;
    
    frame = _addNewAddressView.frame;
    frame.size.width = screenWidth;
    _addNewAddressView.frame = frame;
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (indexPath.row == 0) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
        
        if (type == TYPE_ADD_EDIT_PROFILE_ATC|| type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO || type == TYPE_ADD_EDIT_PROFILE_ADD_RESO) {
            static NSString *CellIdentifier = GENERAL_CHECKMARK_CELL_IDENTIFIER;
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [GeneralCheckmarkCell newcell];
            }
            AddressFormList *list = _list[indexPath.section];
            ((GeneralCheckmarkCell*)cell).cellLabel.text = list.address_name;
            
            if (_list.count > indexPath.row) {
                AddressFormList *addressSelected = [_datainput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                if (addressSelected.address_id != list.address_id) {
                    ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = YES;
                }
                else
                    ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = NO;
            }
            
            if ([list.longitude integerValue]  == 0 && [list.latitude integerValue] == 0)
            {
                ((GeneralCheckmarkCell*)cell).cellLableLeadingConstraint.constant = 14;
                ((GeneralCheckmarkCell*)cell).iconPinPoint.hidden = YES;
            }
            else {
                ((GeneralCheckmarkCell*)cell).cellLableLeadingConstraint.constant = 45;
                ((GeneralCheckmarkCell*)cell).iconPinPoint.hidden = NO;
            }
        }
        else
        {
            NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
            
            cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [GeneralList1GestureCell newcell];
                ((GeneralList1GestureCell*)cell).delegate = self;
            }
            
            if (_list.count > indexPath.section) {
                AddressFormList *list = _list[indexPath.section];
                
                ((GeneralList1GestureCell*)cell).textLabel.text = list.address_name;
                ((GeneralList1GestureCell*)cell).indexpath = indexPath;
                
                if (indexPath.section == 0) {
                    ((GeneralList1GestureCell*)cell).detailTextLabel.text = @"Alamat Utama";
                }
                else
                {
                    ((GeneralList1GestureCell*)cell).detailTextLabel.text = @" ";
                }

                if (![_searchKeyword isEqualToString:@""] && _searchKeyword != nil) {
                    ((GeneralList1GestureCell*)cell).detailTextLabel.text = (list.address_status == 2)?@"Alamat Utama":@" ";
                }
                
                if ([list.longitude integerValue]== 0 && [list.latitude integerValue] == 0)
                {
                    cell.imageView.image = nil;
                }
                else {
                    cell.imageView.image = [UIImage imageNamed:@"icon_pinpoin_toped.png"];
                }
            }
            
        }
    } else {
        NSString *cellid = kTKPDSETTINGADDRESSEXPANDEDCELL_IDENTIFIER;
        
        cell = (SettingAddressExpandedCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [SettingAddressExpandedCell newcell];
        }
        
        if (_list.count > indexPath.section) {
            AddressFormList *list = _list[indexPath.section];
            ((SettingAddressExpandedCell*)cell).recieverNameLabel.text = list.receiver_name;
            NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %@",
                                 [NSString convertHTML:list.address_street], list.district_name, list.city_name,
                                 list.province_name, list.country_name, list.postal_code];
            ((SettingAddressExpandedCell*)cell).addressLabel.text = address;
            ((SettingAddressExpandedCell*)cell).addressLabel.font = [UIFont largeTheme];
            ((SettingAddressExpandedCell*)cell).phoneLabel.text = list.receiver_phone;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isdefault;
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PROFILE_ATC|| type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO || type == TYPE_ADD_EDIT_PROFILE_ADD_RESO) {
         AddressFormList *address = _list[indexPath.section];
        [_datainput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
        [_table reloadData];
    }
    else
    {
        AddressFormList *list = _list[indexPath.section]; //
        if (_ismanualsetdefault) {
            isdefault = (indexPath.section == 0)?YES:NO;
        } else {
            isdefault = (list.address_status == 2)?YES:NO;
        }
        list.isDefaultAddress = isdefault;
        
        SettingAddressDetailViewController *vc = [SettingAddressDetailViewController new];
        vc.address = _list[indexPath.section];
        [vc getSuccessSetDefaultAddress:^(AddressFormList *address) {
            [_list removeObject:address];
            [_list insertObject:address atIndex:0];
            [_table reloadData];
        }];
        [vc getSuccessDeleteAddress:^(AddressFormList *address) {
            [_list removeObject:address];
            [_table reloadData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = _list.count - 1;
	if (section == indexPath.section) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ([_searchKeyword isEqualToString:@""] || _searchKeyword == nil)) {
            [self request];
        }
	}
}

-(void)tableView:(UITableView *)tableView moveSection:(NSUInteger)sourceSection toIndexPath:(NSUInteger)destinationSection
{
    id dataObject = [_list objectAtIndex:sourceSection];
    [_list removeObjectAtIndex:sourceSection];
    [_list insertObject:dataObject atIndex:destinationSection];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id dataObject = [_list objectAtIndex:sourceIndexPath.section]; //
    [_list removeObjectAtIndex:sourceIndexPath.section]; //
    [_list insertObject:dataObject atIndex:destinationIndexPath.section]; //
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[_table reloadData];
}

-(void)reloadTableData
{
    [_table reloadData];
}


#pragma mark - Memory Management
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Request
-(void)request
{
    NSInteger nextPage = [[TokopediaNetworkManager getPageFromUri:_urinext] integerValue];
    if(nextPage == _page) return;
    
    _page = nextPage;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    if (_page <= 1) _doneBarButtonItem.enabled = NO;
    [AddressRequest fetchListAddressPage: nextPage query:_searchKeyword onSuccess:^(AddressFormResult * data) {
        [self successRequestListAddress:data.list];
        _urinext =  data.paging.uri_next;
        
        [_act stopAnimating];
        [_refreshControl endRefreshing];
        
    } onFailure:^{
        [_act stopAnimating];
        [_refreshControl endRefreshing];
    }];
}

-(void)successRequestListAddress:(NSArray<AddressFormList*> *)listAddress{
    if (_page <= 1) {
        [_list removeAllObjects];
    }
    
    [_list addObjectsFromArray:listAddress];
    
    if (_list.count >0) {
        _doneBarButtonItem.enabled = YES;
        _table.tableFooterView = nil;
    } else {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.table.tableFooterView = noResultView;
    }

    [_table reloadData];

}

#pragma mark Request Action
-(void)requestActionSetDefault:(AddressFormList*)address {
    
    [AddressRequest fetchSetDefaultAddressID:address.address_id onSuccess:^(ProfileSettingsResult * data) {
        
    } onFailure:^{
        [self cancelSetAsDefault];
    }];

}

-(void)requestActionDelete:(AddressFormList*)address {
    
    [AddressRequest fetchDeleteAddressID:address.address_id onSuccess:^(ProfileSettingsResult * data) {
        
    } onFailure:^{
        [self cancelDeleteRow];
    }];
    
}

#pragma mark - View Action
-(void)tapDoneBarButtonItem:(UIBarButtonItem*)sender{
    AddressFormList *address = [_datainput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    NSDictionary* userInfo = @{
                               DATA_ADDRESS_DETAIL_KEY:address,
                               DATA_INDEXPATH_KEY:_selectedIndexPath
                               };
    [_delegate SettingAddressViewController:self withUserInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)tapAddBarButtonItem:(UIBarButtonItem*)sender{
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    
    if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
        [AnalyticsManager trackEventName:@"clickATC" category:GA_EVENT_CATEGORY_ATC action:GA_EVENT_ACTION_CLICK label:@"Add Address"];
    }
    
    NSInteger typeAddAddress = (type == TYPE_ADD_EDIT_PROFILE_ATC || type == TYPE_ADD_EDIT_PROFILE_ADD_RESO || type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO)?type:TYPE_ADD_EDIT_PROFILE_ADD_NEW;
    SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
    vc.data = @{
                kTKPDPROFILE_DATAEDITTYPEKEY : @(typeAddAddress)
                };
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Methods

-(void)setAsDefaultAddress:(AddressFormList*)address
{
    _ismanualsetdefault = YES;
    [self requestActionSetDefault:address];
    [_list removeObject:address];
    [_list insertObject:address atIndex:0];
    
    [self.table reloadData];
}
-(void)cancelSetAsDefault
{
    _ismanualsetdefault = NO;
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
    [_table moveSection:indexpath1.section toSection:indexpath.section];
    [_table reloadData];
}

-(void)deleteAddress:(AddressFormList*)address atIndexPath:(NSIndexPath*)indexPath {
    [_datainput setObject:_list[indexPath.section] forKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    [_list removeObject:address];
    [_table beginUpdates];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    [indexSet addIndex:indexPath.section];
    [_table deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self requestActionDelete:address];
    [_datainput setObject:indexPath forKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.section]; //
    [_table reloadData];
}

-(void)refreshView {
    _page = 1;
    _urinext = nil;
    [self request];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];

    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    _searchKeyword = searchBar.text;
    
    [self refreshView];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


#pragma mark - Notification
- (void)didEditAddress:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    [_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]?:@(0) forKey:kTKPDPROFILE_DATAEDITTYPEKEY];
    [self refreshView];
}

#pragma mark - Add / Edit Address Delegate
-(void)SettingAddressEditViewController:(SettingAddressEditViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    if (_delegate && [_delegate respondsToSelector:@selector(SettingAddressViewController:withUserInfo:)]) {
        [_delegate SettingAddressViewController:self withUserInfo:userInfo];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexpath = ((GeneralList1GestureCell*) cell).indexpath;
        AddressFormList *list = _list[indexpath.section];
        [_datainput setObject:list.address_id forKey:kTKPDPROFILESETTING_APIADDRESSIDKEY];
        
        UIColor *redColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton *trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                              backgroundColor:redColor
                                                      padding:padding
                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                         [self deleteAddress:list atIndexPath: indexpath];
            return YES;
        }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];
        
        UIColor *blueColor = [UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0];
        MGSwipeButton *flag = [MGSwipeButton buttonWithTitle:@"Jadikan\nUtama"
                                             backgroundColor:blueColor
                                                     padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self setAsDefaultAddress:list];
            return YES;
        }];
        flag.titleLabel.font = [UIFont fontWithName:flag.titleLabel.font.fontName size:12];
        
        return @[trash, flag];
    }
    return nil;
}

#pragma mark - Method
- (LoadingView *)getLoadView:(int)tag
{
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    loadingView.tag = tag;
    
    return loadingView;
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
        _table.tableFooterView = _footer;
        [_act startAnimating];
        [self request];
}

#pragma mark - Address add delegate

- (void)successAddAddress:(AddressFormList*)address
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PROFILE_ATC) {
        [self.navigationController popViewControllerAnimated:YES];
        [_delegate SettingAddressViewController:self withUserInfo:@{DATA_ADDRESS_DETAIL_KEY: address}];
    }
    
    [self refreshView];
}

@end
