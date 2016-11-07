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
#import "LoadingView.h"
#import "NoResultReusableView.h"
#import "TokopediaNetworkManager.h"
#import "DepositRequest.h"
#import "WebViewController.h"

@interface DepositSummaryViewController () <UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate, LoadingViewDelegate> {
    NSOperationQueue *_operationQueue;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    
    NSMutableArray *_depositSummary;
    
    NSString *_useableSaldoIDR;
    NSString *_useableSaldo;
    NSString *_totalSaldoTokopedia;
    NSString *_holdDepositByCsIDR;
    NSString *_holdDepositByTokopedia;
    
    NSString *_reviewedSaldoIDR;
    
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_uriNext;
    NSDate *_now;
    NSDate *_oneMonthBeforeNow;
    
    NSString *_currentStartDate;
    NSString *_currentEndDate;
    
    BOOL _isRefreshView;
    BOOL _isNoData;
    
    UIBarButtonItem *_barbuttonleft;
    UIBarButtonItem *_barbuttonright;
    LoadingView *loadingView;
    
    DepositRequest *_depositRequest;
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
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *topUpButton;

@property (strong, nonatomic) IBOutlet UIView *infoReviewSaldo;
@property (strong, nonatomic) IBOutlet UIView *filterDateArea;
@property (strong, nonatomic) IBOutlet UILabel *reviewSaldo;
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail:(id)object;
- (void)requestTimeout;

@end

@implementation DepositSummaryViewController{
    NoResultReusableView *_noResultView;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Detil Saldo";
    self.hidesBottomBarWhenPushed = YES;
    
    if (self) {
        _isRefreshView = NO;
        _isNoData = YES;
    }
    return self;
}

- (void)initBarButton {
    UIImage *infoImage = [UIImage imageNamed:@"icon_info_white.png"];
    
    CGRect frame = CGRectMake(0, 0, 20, 20);
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:infoImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchDown];
    [button setTag:14];
    
    _barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonright setCustomView:button];
    [_barbuttonright setEnabled:NO];
    self.navigationItem.rightBarButtonItem = _barbuttonright;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [_noResultView generateAllElements:nil
                                 title:@"Belum ada transaksi"
                                  desc:@""
                              btnTitle:nil];
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadListDeposit:)
                                                 name:@"reloadListDeposit" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableButtonWithdraw)
                                                 name:@"removeButtonWithdraw" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSaldoTokopedia:)
                                                 name:@"updateSaldoTokopedia" object:nil];
}

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _depositSummary = [NSMutableArray new];
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.estimatedRowHeight = 138.0;
    _table.rowHeight = UITableViewAutomaticDimension;
    
    _filterDateButton.layer.cornerRadius = 5.0;
    _withdrawalButton.layer.cornerRadius = 5.0;
    _saldoLabel.text = [_data objectForKey:@"total_saldo"];
    _reviewSaldo.text = @"";
    
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
    
    _depositRequest = [DepositRequest new];
    
    self.contentView  = self.view;
    [self initNoResultView];
    
    [self initNotificationCenter];
    [self initBarButton];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Deposit Summary Page"];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
            
            [((DepositSummaryCell*)cell).currentSaldo setText:depositList.deposit_saldo_idr];
            if([depositList.deposit_amount integerValue] > 0) {
                [((DepositSummaryCell*)cell).depositAmount setTextColor:[UIColor colorWithRed:(10.0/255.0) green:(126.0/255.0) blue:(7.0/255.0) alpha:(1.0)]];
            } else {
                [((DepositSummaryCell*)cell).depositAmount setTextColor:[UIColor redColor]];
            }
            [((DepositSummaryCell*)cell).depositAmount setText:depositList.deposit_amount_idr];
            [((DepositSummaryCell*)cell).withdrawalTime setText:depositList.deposit_date_full];
            
            
            UIFont *font = [UIFont smallTheme];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6.0;
            
            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                         NSFontAttributeName: font,
                                         NSParagraphStyleAttributeName: style,
                                         };
            
            NSAttributedString *depositNotesText = [[NSAttributedString alloc] initWithString:[NSString convertHTML:depositList.deposit_notes]
                                                                                   attributes:attributes];
            
            ((DepositSummaryCell*)cell).depositNotes.attributedText = depositNotesText;
            
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
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_page && _page != 0) {
            [self loadData];
        } else {
            _table.tableFooterView = [UIView new];
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
- (void)loadData {
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = [UIView new];
        [_act stopAnimating];
    }
    
    NSDateFormatter *dateFormatStr = [NSDateFormatter new];
    [dateFormatStr setDateFormat:@"yyyyMMdd"];
    
    [_depositRequest requestGetDepositSummaryWithStartDate:_currentStartDate?:[dateFormatStr stringFromDate:_oneMonthBeforeNow]
                                                   endDate:_currentEndDate?:[dateFormatStr stringFromDate:_now]
                                                      page:_page
                                                   perPage:20
                                                 onSuccess:^(DepositSummaryResult *result) {
                                                     [self loadTableDataWithResult:result];
                                                 }
                                                 onFailure:^(NSError *errorResult) {
                                                     _table.tableFooterView = [self getLoadView].view;
                                                 }];
    
}

- (void)loadTableDataWithResult:(DepositSummaryResult*)result {
    [_barbuttonright setEnabled:YES];
    [_depositSummary addObjectsFromArray:result.list];
    _useableSaldo = result.summary.summary_useable_deposit;
    _useableSaldoIDR = result.summary.summary_useable_deposit_idr;
    
    _saldoLabel.text = _useableSaldoIDR;
    _totalSaldoTokopedia = result.summary.summary_total_deposit_idr;
    _holdDepositByCsIDR = result.summary.summary_deposit_hold_by_cs_idr;
    _holdDepositByTokopedia = result.summary.summary_hold_deposit_idr;
    
    if([result.summary.summary_hold_deposit integerValue] > 0) {
        _infoReviewSaldo.tag = 121;
        
        if(! [_withdrawalButton viewWithTag:121]) {
            [_reviewSaldo setText:_holdDepositByTokopedia];
            CGRect newFrame2 = _filterDateArea.frame;
            newFrame2.origin.y += 40;
            _filterDateArea.frame = newFrame2;
            
            CGRect newFrame3 = _table.frame;
            newFrame3.origin.y += 40;
            _table.frame = newFrame3;
            
            [_withdrawalButton addSubview:_infoReviewSaldo];
            CGRect newFrame4 = _infoReviewSaldo.frame;
            newFrame4.origin.y += 47;
            newFrame4.size.width = _header.frame.size.width;
            newFrame4.origin.x = -_withdrawalButton.frame.origin.x;
            _infoReviewSaldo.frame = newFrame4;
            
            constraintHeightSuperHeader.constant = constraintHeightSuperHeader.constant+_infoReviewSaldo.frame.size.height-2;
            constraintHeightHeader.constant = constraintHeightHeader.constant +_infoReviewSaldo.frame.size.height-2;
        }
    }
    
    if([result.summary.summary_today_tries integerValue] < [result.summary.summary_daily_tries integerValue] && [result.summary.summary_useable_deposit integerValue] > 0) {
        [self enableButtonWithdraw];
    }
    
    if (_depositSummary.count > 0) {
        _isNoData = NO;
        _uriNext =  result.paging.uri_next;
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
        
        if(result.error_date) {
            [_noResultView setNoResultTitle:kTKPDMESSAGE_ERRORMESSAGEDATEKEY];
        }
        _table.tableFooterView = _noResultView;
        
    }
    
    _table.tableHeaderView = nil;
    
    [_table reloadData];
    _isRefreshView = NO;
    [_refreshControl endRefreshing];
}

#pragma mark - IBAction
- (IBAction)topUpSaldoButtonTapped:(id)sender {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *userID = [auth getUserId];
    NSString *deviceID = [auth getMyDeviceToken];
    NSString *pulsaURL = @"https://pulsa.tokopedia.com/saldo/";
    NSString *jsURL = @"https://js.tokopedia.com/wvlogin?uid=";
    NSString *url = [[[[[jsURL stringByAppendingString:userID] stringByAppendingString:@"&token="] stringByAppendingString:deviceID] stringByAppendingString:@"&url="] stringByAppendingString:pulsaURL];
    WebViewController *controller = [WebViewController new];
    controller.strURL = url;
    controller.strTitle = @"Top Up Saldo";
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info Saldo Tokopedia" message:
                                          [NSString stringWithFormat: @"-%@ %@\n\n-%@ %@\n\n-%@\n\n-%@",
                                           @"Total Saldo Anda",
                                           _useableSaldoIDR,
                                           @"Saldo Tokopedia yang dapat Anda tarik",
                                           _useableSaldoIDR,
                                           @"Anda hanya dapat melakukan penarikan dana sebanyak 1x dalam 1 hari",
                                           @"Untuk hari ini Anda dapat melakukan penarikan dana sebanyak 1x lagi"
                                           ]
                                          
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
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
                DepositFormViewController *formViewController = [DepositFormViewController new];
                [self.navigationController pushViewController:formViewController animated:YES];
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
                [self loadData];
                break;
            }
                
            case 14 :  {
                NSMutableString *infoSaldo = [NSMutableString stringWithFormat:@"\n -%@ %@", @" Total Saldo Tokopedia Anda adalah", _totalSaldoTokopedia];
                
                if (![_holdDepositByTokopedia isEqualToString:@"Rp 0"]) {
                    [infoSaldo appendString:[NSString stringWithFormat:@"\n\n-%@\n%@\n%@", @" Saldo Tokopedia Anda sejumlah",_holdDepositByTokopedia, @"sedang kami review.\nJika review melebihi 1x24 jam, silakan hubungi Customer Service kami untuk penjelasan lebih lanjut. Terima kasih."]];
                }
                
                [infoSaldo appendString:[NSString stringWithFormat:@"\n\n-%@ %@", @" Saldo Tokopedia yang dapat Anda tarik sebesar", _useableSaldoIDR]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info Saldo Tokopedia"
                                                                    message:infoSaldo
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                break;
            }
                
            case 15 : {
                
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Memory Manage
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TKPD Alert date picker delegate

- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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


#pragma mark - Method
- (LoadingView *)getLoadView {
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

#pragma mark - Notification Action
- (void)reloadListDeposit:(NSNotification*)notification  {
    _table.tableHeaderView = _footer;
    _page = 1;
    [_depositSummary removeAllObjects];
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

#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    [self loadData];
}

- (void)updateSaldoTokopedia:(NSNotification*)notification {
    [self loadData];
    
}
@end
