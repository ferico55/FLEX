//
//  ShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShipmentConfirmationViewController.h"
#import "SalesOrderCell.h"
#import "Order.h"
#import "OrderTransaction.h"
#import "string_order.h"
#import "TKPDSecureStorage.h"

@interface ShipmentConfirmationViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    SalesOrderCellDelegate,
    UIAlertViewDelegate
>
{
    NSMutableArray *_transactions;
    NSMutableDictionary *_paging;
    NSInteger _page;
    NSInteger _limit;
    NSInteger _requestCount;
    NSTimer *_timer;
    NSString *_uriNext;
    
    BOOL _isNoData;
    BOOL _isRefreshView;

    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    UIRefreshControl *_refreshControl;
    
    Order *_order;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@end

@implementation ShipmentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Konfirmasi Pengiriman";
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.tableHeaderView = _headerView;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:11],
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_alertLabel.text
                                                                                    attributes:attributes];
    _alertLabel.attributedText = productNameAttributedText;
    
    _objectManager =  [RKObjectManager sharedClient];
    _operationQueue = [NSOperationQueue new];
    
    _transactions = [NSMutableArray new];
    
    [self configureRestKit];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef NO_DATE_ENABLE
    return _isNoData ? 1 : _transactions.count;
#else
    return _isNoData ? 0 : _transactions.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"SalesOrderCell";
    SalesOrderCell *cell = (SalesOrderCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SalesOrderCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
    }
 
    OrderTransaction *transaction = [_transactions objectAtIndex:indexPath.row];
    
    cell.invoiceNumberLabel.text = transaction.order_detail.detail_invoice;
    
    if (transaction.order_payment.payment_process_day_left == 1) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:145.0/255.0
                                                                   blue:0.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Besok";
        
    } else if (transaction.order_payment.payment_process_day_left == 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:59.0/255.0
                                                                   blue:48.0/255.0
                                                                  alpha:1];
        cell.remainingDaysLabel.text = @"Hari ini";
        
    } else if (transaction.order_payment.payment_process_day_left < 0) {
        
        cell.remainingDaysLabel.backgroundColor = [UIColor colorWithRed:158.0/255.0
                                                                  green:158.0/255.0
                                                                   blue:158.0/255.0
                                                                  alpha:1];
        
        cell.automaticallyCanceledLabel.hidden = YES;
        
        cell.remainingDaysLabel.text = @"Expired";
        
        CGRect frame = cell.remainingDaysLabel.frame;
        frame.origin.y = 17;
        cell.remainingDaysLabel.frame = frame;
        
    } else {
        
        cell.remainingDaysLabel.text = [NSString stringWithFormat:@"%d Hari lagi", (int)transaction.order_payment.payment_process_day_left];
        
    }
    
    cell.userNameLabel.text = transaction.order_customer.customer_name;
    cell.purchaseDateLabel.text = transaction.order_payment.payment_verify_date;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:transaction.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [cell.userImageView setImage:image];
                                       } failure:nil];
    
    cell.paymentAmountLabel.text = transaction.order_detail.detail_open_amount_idr;
    cell.dueDateLabel.text = [NSString stringWithFormat:@"Batas Respon : %@", transaction.order_payment.payment_process_due_date];
    
    [cell.rejectButton setTitle:@"Batal" forState:UIControlStateNormal];
    [cell.acceptButton setTitle:@"Konfirmasi" forState:UIControlStateNormal];
 
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            
            _tableView.tableFooterView = _footerView;
            [_activityIndicator startAnimating];
            
            [self request];
            
        } else {
            _tableView.tableFooterView = nil;
        }
    }
}

#pragma mark - Cell delegate

- (void)tableViewCell:(UITableViewCell *)cell acceptOrderAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableViewCell:(UITableViewCell *)cell rejectOrderAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Reskit methods

- (void)configureRestKit
{
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Order class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY : kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[OrderResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{
                                                        API_PAGING_URI_NEXT     : API_PAGING_URI_NEXT,
                                                        API_PAGING_URI_PREVIOUS : API_PAGING_URI_PREVIOUS,
                                                        }];
    
    RKObjectMapping *orderMapping = [RKObjectMapping mappingForClass:[OrderOrder class]];
    [orderMapping addAttributeMappingsFromDictionary:@{
                                                       API_PAGING_URI_NEXT      : API_PAGING_URI_NEXT,
                                                       API_PAGING_URI_PREVIOUS  : API_PAGING_URI_PREVIOUS,
                                                       }];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[OrderTransaction class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 API_LIST_ORDER_JOB_STATUS,
                                                 API_LIST_ORDER_AUTO_RESI,
                                                 API_LIST_ORDER_AUTO_AWB,
                                                 ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:listMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PAGING_KEY
                                                                                  toKeyPath:API_PAGING_KEY
                                                                                withMapping:pagingMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_KEY
                                                                                  toKeyPath:API_ORDER_KEY
                                                                                withMapping:orderMapping]];
    

    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:API_NEW_ORDER_PATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary* param = @{
                            API_GET_NEW_ORDER_KEY   : API_GET_NEW_ORDER_PROCESS_KEY,
                            API_USER_ID_KEY         : [auth objectForKey:API_USER_ID_KEY],
                            @"enc_dec"              : @"off",
                            };
    
    _tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:API_NEW_ORDER_PATH
                                                                parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        _tableView.hidden = NO;
        _isRefreshView = NO;
        
        [_timer invalidate];
        _timer = nil;
        
        [_activityIndicator stopAnimating];
        [_refreshControl endRefreshing];
        
        _tableView.tableFooterView = nil;
        
        [self requestSuccess:mappingResult withOperation:operation];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        _isRefreshView = NO;
        
        [_timer invalidate];
        _timer = nil;
        
        [_activityIndicator stopAnimating];
        [_refreshControl endRefreshing];
        
        [self requestFailure:error];

    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    _order = [result objectForKey:@""];
    BOOL status = [_order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
}

- (void)requestFailure:(id)object
{
    
}

- (void)requestTimeout
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    
}

@end
