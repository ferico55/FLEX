//
//  SettingBankAccountViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountGetDefaultForm.h"
#import "ProfileSettings.h"
#import "GeneralList1GestureCell.h"
#import "GeneralCheckmarkCell.h"
#import "LoadingView.h"
#import "SettingBankDetailViewController.h"
#import "SettingBankEditViewController.h"
#import "SettingBankAccountViewController.h"
#import "BankAccountRequest.h"

#import "MGSwipeButton.h"
#define CTagRequest 2

#pragma mark - Setting Bank Account View Controller
@interface SettingBankAccountViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    SettingBankDetailViewControllerDelegate,
    MGSwipeTableCellDelegate,
    LoadingViewDelegate
>
{
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _ismanualsetdefault;
    
    LoadingView *loadingView;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    
    BOOL _isaddressexpanded;
    
    BankAccountRequest *_request;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *addNewRekeningView;

- (IBAction)tap:(id)sender;

@end

@implementation SettingBankAccountViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _ismanualsetdefault = NO;
        self.title =TITLE_LIST_BANK;
    }
    return self;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    _list = [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    
    _page = 1;
    _table.delegate = self;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didEditBankAccount:) name:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY object:nil];
    
    if (_delegate == nil) {
        _table.tableHeaderView = _addNewRekeningView;
    }
    
    NSArray *lists = [_data objectForKey:DATA_LIST_BANK_ACOUNT_KEY];
    if (lists.count>0) {
        _isnodata = NO;
        [_list addObjectsFromArray:lists];
    }
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self
                        action:@selector(refreshView:)
              forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _request = [BankAccountRequest new];
    
    if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
        [self getBankAccount];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TPAnalytics trackScreenName:@"Setting Bank Account Page"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_delegate !=nil) {
        [_delegate selectedObject:_selectedObject];
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    if (_list.count > indexPath.row) {
        if (_delegate ==nil) {
            NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
            
            cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [GeneralList1GestureCell newcell];
                ((GeneralList1GestureCell*)cell).delegate = self;
            }
            
            BankAccountFormList *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).textLabel.text = list.bank_account_name;
            ((GeneralList1GestureCell*)cell).detailTextLabel.text = list.bank_name;
            //            ((GeneralList1GestureCell*)cell).imageView.image = list.ban
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;
            
            if (indexPath.row == 0) {
                ((GeneralList1GestureCell*)cell).detailTextLabel.text = [NSString stringWithFormat:@"%@ (Utama)", list.bank_name];
                ((GeneralList1GestureCell*)cell).detailTextLabel.textColor = [UIColor redColor];
            } else {
                ((GeneralList1GestureCell*)cell).detailTextLabel.textColor = [UIColor grayColor];
            }
            
        }
        else
        {
            NSString *cellid = GENERAL_CHECKMARK_CELL_IDENTIFIER;
            
            cell = (GeneralCheckmarkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [GeneralCheckmarkCell newcell];
            }
            
            BankAccountFormList *list = _list[indexPath.row];
            ((GeneralCheckmarkCell*)cell).cellLabel.text = list.bank_account_name;
            ((GeneralCheckmarkCell*)cell).checkmarkImageView.hidden = !([_selectedObject isEqual:list]);
        }
    }
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate ==nil) {
        BOOL isdefault;
        BankAccountFormList *list = _list[indexPath.row];
        if (_ismanualsetdefault)
            isdefault = (indexPath.row == 0)?YES:NO;
        else
        {
            isdefault = (list.is_default_bank == 1)?YES:NO;
        }
        
        SettingBankDetailViewController *vc = [SettingBankDetailViewController new];
        vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                    kTKPDPROFILE_DATABANKKEY : _list[indexPath.row]?:[BankAccountFormList new],
                    kTKPDPROFILE_DATAINDEXPATHKEY : indexPath,
                    kTKPDPROFILE_DATAISDEFAULTKEY : @(isdefault)
                    };
        
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        _selectedObject = _list[indexPath.row];
        [_table reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self getBankAccount];
        }
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id dataObject = [_list objectAtIndex:sourceIndexPath.row];
    [_list removeObjectAtIndex:sourceIndexPath.row];
    [_list insertObject:dataObject atIndex:destinationIndexPath.row];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (button.tag == 11) {
            if (_list.count >= 10) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mohon maaf, maksimal 10 rekening bank yang dapat Anda masukkan.\nSilakan hapus terlebih dahulu rekening bank yang sudah tidak digunakan." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            SettingBankEditViewController *vc = [SettingBankEditViewController new];
            vc.data = [NSMutableDictionary dictionaryWithDictionary:@{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                                                      kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_ADD_NEW),
                                                                      }];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - delegate bank account detail
-(void)DidTapButton:(UIButton *)button withdata:(NSDictionary *)data
{
    BankAccountFormList *list = [data objectForKey:kTKPDPROFILE_DATABANKKEY];
    [_datainput setObject:list.bank_account_id forKey:API_BANK_ACCOUNT_ID_KEY];
    NSIndexPath *indexpath = [data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    switch (button.tag) {
        case 10:
        {
            //set as default
            //NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
            [self requestSetDefaultBankAccountAtIndexPath:indexpath];
            break;
        }
        case 11:
        {
            //delete
            [self requestDeleteBankAccountOnIndexPath:indexpath];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (LoadingView *)getLoadView:(int)tag
{
    if (loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

-(void)cancelSetAsDefault
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
    NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:0 inSection:indexpath.section];
    [self tableView:_table moveRowAtIndexPath:indexpath1 toIndexPath:indexpath];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    BankAccountFormList *deletedData = [_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    if (![_list containsObject:deletedData]) {
        [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
        [_table reloadData];
    }
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self getBankAccount];
}

#pragma mark - Requests

- (void)getBankAccount {
    __weak typeof(self) weakSelf = self;
    [_request requestGetBankAccountOnSuccess:^(BankAccountFormResult *result) {
        [weakSelf loadBankAccountData:result];
        
        [_act stopAnimating];
        [_table reloadData];
        [_refreshControl endRefreshing];
    }
    onFailure:^(NSError *error) {
        [_act stopAnimating];
        _table.tableFooterView = [weakSelf getLoadView:CTagRequest].view;
        [_refreshControl endRefreshing];
        _table.tableFooterView = loadingView.view;
    }];
}

- (void)loadBankAccountData:(BankAccountFormResult *)account {
    [_list removeAllObjects];
    [_list addObjectsFromArray:account.list];
    
    if (_list.count > 0) {
        _isnodata = NO;
        _urinext =  account.paging.uri_next;
        _page = [[TokopediaNetworkManager getPageFromUri:_urinext] integerValue];
        _table.tableFooterView = nil;
        
    } else {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.table.tableFooterView = noResultView;
    }
}

- (void)requestSetDefaultBankAccountAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    
    BankAccountFormList *bankAccount = _list[indexPath.row];
    [_datainput setObject:bankAccount.bank_account_id forKey:API_BANK_ACCOUNT_ID_KEY];
    
    [_request requestSetDefaultBankAccountWithAccountID:[_datainput objectForKey:API_BANK_ACCOUNT_ID_KEY]
                                              onSuccess:^(ProfileSettings *result) {
                                                  [weakSelf displayMessages:result];
                                                  [_refreshControl endRefreshing];
                                                  
                                                  NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                                                  [weakSelf tableView:_table moveRowAtIndexPath:indexPath toIndexPath:indexPath1];
                                                  
                                                  [_datainput setObject:indexPath forKey:kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY];
                                                  
                                                  [weakSelf getBankAccount];
                                              }
                                              onFailure:^(NSError *error) {
                                                  [weakSelf cancelSetAsDefault];
                                              }];
}

- (void)displayMessages:(ProfileSettings *)settings {
    if ([settings.status isEqualToString:@"OK"]) {
        if(settings.message_error) {
            NSArray *errorMessages = settings.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        
        if ([settings.data.is_success boolValue]) {
            NSArray *successMessages = settings.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
            [alert show];
            _ismanualsetdefault = NO;
        }
    }
}

- (void)requestDeleteBankAccountOnIndexPath:(NSIndexPath *)indexPath {
    [_datainput setObject:_list[indexPath.row] forKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexPath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    
    BankAccountFormList *deletedBankAccount = [_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY];
    
    __weak typeof(self) weakSelf = self;
    
    [_request requestDeleteBankAccountWithAccountID:deletedBankAccount.bank_account_id
                                          onSuccess:^(ProfileSettings *result) {
                                              [weakSelf deleteBankAccount:result];
                                              [_table reloadData];
                                              [_refreshControl endRefreshing];
                                          }
                                          onFailure:^(NSError *error) {
                                              [weakSelf cancelDeleteRow];
                                              [_refreshControl endRefreshing];
                                          }];
}

- (void)deleteBankAccount:(ProfileSettings *)settings {
    if(settings.message_error) {
        [self cancelDeleteRow];
        
        NSArray *errorMessages = settings.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
    
    if ([settings.data.is_success boolValue]) {
        NSArray *successMessages = settings.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages
                                                                         delegate:self];
        [alert show];
    } else {
        [self cancelDeleteRow];
    }
}

#pragma mark - Notification
- (void)didEditBankAccount:(NSNotification*)notification
{
    [self refreshView:nil];
}

#pragma mark - Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = ((GeneralList1GestureCell*) cell).indexpath;
        
        __weak typeof(self) weakSelf = self;
        
        UIColor *redColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                               backgroundColor:redColor
                                                       padding:padding
                                                      callback:^BOOL(MGSwipeTableCell *sender) {
                                                          [weakSelf requestDeleteBankAccountOnIndexPath:indexPath];
                                                          return YES;
                                                      }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];
        
        if (indexPath.row > 0) {
            MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Jadikan\nUtama"
                                                  backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0]
                                                          padding:padding
                                                         callback:^BOOL(MGSwipeTableCell *sender) {
                                                             //edit
                                                             [weakSelf requestSetDefaultBankAccountAtIndexPath:indexPath];
                                                             return YES;
                                                         }];
            flag.titleLabel.font = [UIFont fontWithName:flag.titleLabel.font.fontName size:12];
            
            return @[trash, flag];
        } else {
            return @[trash];
        }
    }
    
    return nil;
    
}

#pragma mark - Loading View Delegate
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [self getBankAccount];
}

@end
