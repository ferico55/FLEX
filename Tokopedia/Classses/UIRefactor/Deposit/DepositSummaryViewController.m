//
//  DepositSummaryViewController.m
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "DepositSummaryViewController.h"
#import "DepositSummary.h"
#import "DepositSummaryCell.h"
#import "string_deposit.h"
#import "DepositFormViewController.h"
#import "AlertDatePickerView.h"
#import "NoResult.h"

@interface DepositSummaryViewController () <UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate> {
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSTimer *_timer;
    
    NSMutableArray *_depositSummary;
    
    NSString *_useableSaldoIDR;
    NSString *_useableSaldo;
    
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_uriNext;
    NSDate *_now;
    NSDate *_oneMonthBeforeNow;
    
    NSString *_currentStartDate;
    NSString *_currentEndDate;
    
    BOOL _isRefreshView;
    BOOL _isNoData;
    NoResult *_noResult;
}

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *saldoLabel;
@property (strong, nonatomic) IBOutlet UIButton *withdrawalButton;
@property (strong, nonatomic) IBOutlet UIButton *startDateButton;
@property (strong, nonatomic) IBOutlet UIButton *endDateButton;
@property (strong, nonatomic) IBOutlet UIButton *filterDateButton;

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail:(id)object;
- (void)requestTimeout;

@end

@implementation DepositSummaryViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Detil Saldo";
    self.hidesBottomBarWhenPushed = YES;
    
    if (self) {
        _isRefreshView = NO;
        _isNoData = YES;
    }
    return self;
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadListDeposit:)
                                                 name:@"reloadListDeposit" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableButtonWithdraw:)
                                                 name:@"removeButtonWithdraw" object:nil];
}

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _depositSummary = [NSMutableArray new];
    _noResult = [NoResult new];
    
    _table.delegate = self;
    _table.dataSource = self;
//    _table.tableHeaderView = _header;
    _filterDateButton.layer.cornerRadius = 3.0;
    _withdrawalButton.layer.cornerRadius = 3.0;
    _saldoLabel.text = [_data objectForKey:@"total_saldo"];
//    _withdrawalButton.backgroundColor = [UIColor colorWithRed:(231.0/255.0) green:(231.0/255.0) blue:(231.0/255.0) alpha:1.0];
    
    _page = 1;
    [self disableButtonWithdraw];
    
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@" dd/MM/yyyy"];
    
    _now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:-1];
    _oneMonthBeforeNow = [calendar dateByAddingComponents:components
                                                        toDate:_now
                                                       options:0];
    
    [_startDateButton setTitle:[dateFormat stringFromDate:_oneMonthBeforeNow] forState:UIControlStateNormal];
    [_endDateButton setTitle:[dateFormat stringFromDate:_now] forState:UIControlStateNormal];
    
    [self initNotificationCenter];
    
    [self configureRestkit];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - DataSource Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        NSString *cellid = @"DepositSummaryCellIdentifier";
        
        cell = (DepositSummaryCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [DepositSummaryCell newcell];
        }
        
        if (_depositSummary.count > indexPath.row) {
            
            DepositSummaryList *depositList = _depositSummary[indexPath.row];
            ((DepositSummaryCell*)cell).indexpath = indexPath;
            
//            NSString *timeLabel = [depositList.deposit_date_full substringFromIndex:MAX((int)[depositList.deposit_date_full length]-5, 0)];
            
            [((DepositSummaryCell*)cell).currentSaldo setText:depositList.deposit_saldo_idr];
            if([depositList.deposit_type isEqualToString:@"1"]) {
                [((DepositSummaryCell*)cell).depositAmount setTextColor:[UIColor greenColor]];
            } else {
                [((DepositSummaryCell*)cell).depositAmount setTextColor:[UIColor redColor]];
            }
            [((DepositSummaryCell*)cell).depositAmount setText:depositList.deposit_amount_idr];
            [((DepositSummaryCell*)cell).depositNotes setText:depositList.deposit_notes];
            [((DepositSummaryCell*)cell).withdrawalTime setText:depositList.deposit_date_full];
            
            [((DepositSummaryCell*)cell).depositNotes sizeToFit];

            ((DepositSummaryCell*)cell).depositNotes.numberOfLines = 0;
        } else {

        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    #ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
        return _isNoData ? 1 : _depositSummary.count;
    #else
        return _isNoData ? 0 : _depositSummary.count;
    #endif
        
}

#pragma mark - Tableview Delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_page && _page != 0) {
            [self configureRestkit];
            [self loadData];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[DepositSummary class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DepositSummaryResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"end_date" : @"end_date", @"start_date" : @"start_date"}];
    
    RKObjectMapping *summaryDetailMapping = [RKObjectMapping mappingForClass:[DepositSummaryDetail class]];
    [summaryDetailMapping addAttributeMappingsFromDictionary:@{
                                                               API_SUMMARY_HOLD_DEPOSIT_IDR:API_SUMMARY_HOLD_DEPOSIT_IDR,
                                                               API_SUMMARY_TOTAL_DEPOSIT_IDR:API_SUMMARY_TOTAL_DEPOSIT_IDR,
                                                               API_SUMMARY_TOTAL_DEPOSIT:API_SUMMARY_TOTAL_DEPOSIT,
                                                               API_SUMMARY_DEPOSIT_HOLD_TX_1DAY:API_SUMMARY_DEPOSIT_HOLD_TX_1DAY,
                                                               API_SUMMARY_TODAY_TRIES:API_SUMMARY_TODAY_TRIES,
                                                               API_SUMMARY_USEABLE_DEPOSIT_IDR:API_SUMMARY_USEABLE_DEPOSIT_IDR,
                                                               API_SUMMARY_USEABLE_DEPOSIT:API_SUMMARY_USEABLE_DEPOSIT,
                                                               API_SUMMARY_DEPOSIT_HOLD_TX_1DAY_IDR:API_SUMMARY_DEPOSIT_HOLD_TX_1DAY_IDR,
                                                               API_SUMMARY_HOLD_DEPOSIT:API_SUMMARY_HOLD_DEPOSIT,
                                                               API_SUMMARY_DAILY_TRIES:API_SUMMARY_DAILY_TRIES,
                                                               API_SUMMARY_DEPOSIT_HOLD_BY_CS:API_SUMMARY_DEPOSIT_HOLD_BY_CS,
                                                               API_SUMMARY_DEPOSIT_HOLD_BY_CS_IDR:API_SUMMARY_DEPOSIT_HOLD_BY_CS_IDR
                                                               }];
    
    RKObjectMapping *listDepositMapping = [RKObjectMapping mappingForClass:[DepositSummaryList class]];
    [listDepositMapping addAttributeMappingsFromArray:@[API_DEPOSIT_ID,
                                                        API_DEPOSIT_SALDO_IDR,
                                                        API_DEPOSIT_DATE_FULL,
                                                        API_DEPOSIT_AMOUNT,
                                                        API_DEPOSIT_AMOUNT_IDR,
                                                        API_DEPOSIT_TYPE,
                                                        API_DEPOSIT_DATE,
                                                        API_DEPOSIT_WITHDRAW_DATE,
                                                        API_DEPOSIT_WITHDRAW_STATUS,
                                                        API_DEPOSIT_STATUS]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listDepositMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *summaryDetailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"summary" toKeyPath:@"summary" withMapping:summaryDetailMapping];
    [resultMapping addPropertyMapping:summaryDetailRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"deposit.pl" keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
}

- (void)loadData {
    if(_request.isExecuting) return;
    _requestCount++;
    
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
    
    NSDateFormatter *dateFormatStr = [NSDateFormatter new];
    [dateFormatStr setDateFormat:@"yyyyMMdd"];
    
    NSDictionary *param = @{
                            @"action" : @"get_summary",
                            @"page"   :   @(_page),
                            @"limit"  :   @(20),
                            @"start_date" : _currentStartDate?:[dateFormatStr stringFromDate:_oneMonthBeforeNow],
                            @"end_date" : _currentEndDate?:[dateFormatStr stringFromDate:_now]
                            };
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"deposit.pl" parameters:[param encrypt]];
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        _withdrawalButton.backgroundColor = [UIColor colorWithRed:(18.0/255.0) green:(199.0/255.0) blue:(0.0/255.0) alpha:1.0];
        [self requestSuccess:mappingResult withOperation:operation];
        
        [_table reloadData];
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFail:error];
        
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    DepositSummary *depositSummary = info;
    BOOL status = [depositSummary.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestProceed:object];
    }
}

- (void)requestProceed:(id)object {
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        DepositSummary *depositsummary = stat;
        BOOL status = [depositsummary.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            [_depositSummary addObjectsFromArray: depositsummary.result.list];
            _useableSaldo = depositsummary.result.summary.summary_useable_deposit;
            _useableSaldoIDR = depositsummary.result.summary.summary_useable_deposit_idr;
            
            if([depositsummary.result.summary.summary_today_tries integerValue] < [depositsummary.result.summary.summary_daily_tries integerValue]) {
                [self enableButtonWithdraw];
            }
            
            if (_depositSummary.count >0) {
                _isNoData = NO;
                _uriNext =  depositsummary.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_uriNext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:@"page"] integerValue];
            } else {
                _isNoData = YES;
                _table.tableFooterView = _noResult;
                
            }
        }
        else{
            
            [self cancelCurrentAction];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestkit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = _noResult;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = _noResult;
            }
            
        }
    }
    
    _table.tableHeaderView = nil;
}

- (void)requestFail:(id)error {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}



#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
            case 10:
            {
//                if(!_request.isExecuting) {
                    DepositFormViewController *formViewController = [DepositFormViewController new];
//                    formViewController.data = @{@"summary_useable_deposit_idr":_useableSaldoIDR, @"summary_useable_deposit":_useableSaldo};
                
//                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:formViewController];
//                    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                    [nav.navigationBar setTranslucent:NO];
//                    
//                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    [self.navigationController pushViewController:formViewController animated:YES];
//                }
                
                break;
            }
                
            case 11 : {
                AlertDatePickerView *datePicker = [AlertDatePickerView new];
                
                NSString *start = [_startDateButton titleForState:UIControlStateNormal];
                NSDateFormatter *dateFormat = [NSDateFormatter new];
                [dateFormat setDateFormat:@" dd/MM/yyyy"];
                NSDate *date = [dateFormat dateFromString:start];
                
                datePicker.delegate = self;
                datePicker.tag = 1;
                datePicker.currentdate = date;
                
                
                
                [datePicker show];
                
                break;
            }
                
            case 12 : {
                AlertDatePickerView *datePicker = [AlertDatePickerView new];
                
                NSString *start = [_endDateButton titleForState:UIControlStateNormal];
                NSDateFormatter *dateFormat = [NSDateFormatter new];
                [dateFormat setDateFormat:@" dd/MM/yyyy"];
                NSDate *date = [dateFormat dateFromString:start];
                
                datePicker.delegate = self;
                datePicker.tag = 2;
                datePicker.currentdate = date;

                [datePicker show];
                break;
            }
                
            case 13 : {
                [_depositSummary removeAllObjects];
                [_table reloadData];
                _table.tableFooterView = _footer;
                _page = 1;
                [self configureRestkit];
                [self loadData];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Memory Manage
- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TKPD Alert date picker delegate

- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertDatePickerView *datePicker = (AlertDatePickerView *)alertView;
    NSDate *date = [datePicker.data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@" dd/MM/yyyy"];
    
    NSDateFormatter *dateFormatStr = [NSDateFormatter new];
    [dateFormatStr setDateFormat:@"yyyyMMdd"];

    if (datePicker.tag == 1) {
        [_startDateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
        _currentStartDate = [dateFormatStr stringFromDate:date];
    } else {
        [_endDateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
        _currentEndDate = [dateFormatStr stringFromDate:date];
    }
}

#pragma mark - Notification Action
- (void)reloadListDeposit:(NSNotification*)notification  {
    _table.tableHeaderView = _footer;
    _page = 1;
    [self configureRestkit];
    [self loadData];
}


- (void)disableButtonWithdraw {
    _withdrawalButton.enabled = NO;
    [_withdrawalButton setAlpha:0.5];
}

- (void)enableButtonWithdraw {
    _withdrawalButton.enabled = YES;
    [_withdrawalButton setAlpha:1];
}

@end
