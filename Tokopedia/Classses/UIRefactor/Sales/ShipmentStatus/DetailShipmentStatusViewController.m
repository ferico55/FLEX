//
//  DetailShipmentStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_order.h"

#import "ActionOrder.h"

#import "DetailShipmentStatusViewController.h"
#import "DetailShipmentStatusCell.h"
#import "OrderDetailViewController.h"
#import "ChangeReceiptNumberViewController.h"

#import "StickyAlertView.h"

@interface DetailShipmentStatusViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    OrderDetailDelegate,
    ChangeReceiptNumberDelegate
>
{
    __weak RKObjectManager *_actionObjectManager;
    __weak RKManagedObjectRequestOperation *_actionRequest;
    RKResponseDescriptor *_responseActionDescriptorStatus;
    
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTransactionDetail;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiptNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeReceiptButton;
@property (weak, nonatomic) IBOutlet UIView *receiptNumberView;

@end

@implementation DetailShipmentStatusViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:nil
                                                                 action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;

    _buttonTransactionDetail.layer.cornerRadius = 2;
    
    _tableView.tableHeaderView = _topView;
    
    _invoiceNumberLabel.text = _order.order_detail.detail_invoice;
    _paymentMethodLabel.text = _order.order_payment.payment_gateway_name;
    _receiptNumberLabel.text = _order.order_detail.detail_ship_ref_num;
    
    _operationQueue = [NSOperationQueue new];

    
    if (_is_allow_manage_tx && _order.order_detail.detail_ship_ref_num) {
        if (_order.order_detail.detail_order_status == ORDER_SHIPPING ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_WAITING ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_TRACKER_INVALID ||
            _order.order_detail.detail_order_status == ORDER_SHIPPING_REF_NUM_EDITED) {
            _changeReceiptButton.enabled = YES;
        } else {
            _changeReceiptButton.enabled = NO;
            _changeReceiptButton.layer.opacity = 0.5;
        }
    } else {
        _changeReceiptButton.enabled = NO;
        _changeReceiptButton.layer.opacity = 0.5;
    }
    
    if (_is_allow_manage_tx && _order.order_detail.detail_ship_ref_num) {
        if (_order.order_detail.detail_order_status >= ORDER_SHIPPING &&
            _order.order_detail.detail_order_status <= ORDER_SHIPPING_REF_NUM_EDITED) {
            _changeReceiptButton.enabled = YES;
        } else {
            _changeReceiptButton.enabled = NO;
        }
    } else {
        _changeReceiptButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Detail Status";

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
        
            self.title = @"";
            OrderDetailViewController *controller = [OrderDetailViewController new];
            controller.transaction = _order;
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];

        } else if (button.tag == 2) {

            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];

            ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
            controller.delegate = self;
            controller.order = _order;
            navigationController.viewControllers = @[controller];
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
        } else if (button.tag == 3) {
            
            NSURL *desktopURL = [NSURL URLWithString:_order.order_detail.detail_pdf_uri];
            
            NSString *pdf = [[[[[desktopURL query] componentsSeparatedByString:@"&"] objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
            NSString *invoiceID = [[[[[desktopURL query] componentsSeparatedByString:@"&"] objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
            
            UserAuthentificationManager *authManager = [UserAuthentificationManager new];
            NSString *userID = authManager.getUserId;
            
            NSString *url = [NSString stringWithFormat:@"%@/invoice.pl?invoice_pdf=%@&id=%@&user_id=%@",
                             kTkpdBaseURLString, pdf, invoiceID, userID];
            
            UIWebView *webView = [[UIWebView alloc] initWithFrame:[self.view bounds]];
            webView.scalesPageToFit = YES;
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
            UIViewController *controller = [UIViewController new];
            controller.title = _order.order_detail.detail_invoice;
            [controller.view addSubview:webView];
            [self.navigationController pushViewController:controller animated:YES];
            
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_order.order_history count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderHistory *history = [_order.order_history objectAtIndex:indexPath.row];
    NSString *status;
    if ([history.history_action_by isEqualToString:@"Buyer"]) {
        status = history.history_buyer_status;
    } else {
        status = history.history_seller_status;
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@", history.history_comments]];
    }
    CGSize messageSize = [DetailShipmentStatusCell messageSize:status];
    return messageSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"DetailShipmentStatusCell";
    DetailShipmentStatusCell *cell = (DetailShipmentStatusCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailShipmentStatusCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    OrderHistory *history = [_order.order_history objectAtIndex:indexPath.row];
    
    [cell setSubjectLabelText:history.history_action_by];
    cell.dateLabel.text = history.history_status_date_full;
    
    NSString *status;
    if ([history.history_action_by isEqualToString:@"Buyer"]) {
        status = history.history_buyer_status;
    } else {
        status = history.history_seller_status;
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@", history.history_comments]];
    }
    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    if (indexPath.row == (_order.order_history.count-1)) {
        [cell hideLine];
    }
    
    return cell;
}

#pragma mark - Reskit action methods

- (void)configureActionReskit
{
    _actionObjectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ActionOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY              : kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY   : kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY       : kTKPD_APISTATUSMESSAGEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ActionOrderResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY : kTKPD_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *actionResponseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:API_NEW_ORDER_ACTION_PATH
                                                                                                       keyPath:@""
                                                                                                   statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_actionObjectManager addResponseDescriptor:actionResponseDescriptorStatus];
}

- (void)requestChangeReceiptNumber:(NSString *)receiptNumber
{
    [self configureActionReskit];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    
    NSDictionary *param = @{
                            API_ACTION_KEY              : API_EDIT_SHIPPING_REF,
                            API_USER_ID_KEY             : [auth objectForKey:API_USER_ID_KEY],
                            API_ORDER_ID_KEY            : _order.order_detail.detail_order_id,
                            API_SHIPMENT_REF_KEY        : receiptNumber,
                            };
    
    _actionRequest = [_actionObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:API_NEW_ORDER_ACTION_PATH
                                                                            parameters:[param encrypt]];
    [_operationQueue addOperation:_actionRequest];
    
    [_actionRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSDictionary *result = ((RKMappingResult *) mappingResult).dictionary;
        ActionOrder *actionOrder = [result objectForKey:@""];
        BOOL status = [actionOrder.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status && [actionOrder.result.is_success boolValue]) {
            
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil merubah nomor resi."] delegate:self];
            [alert show];
            
            _order.order_detail.detail_ship_ref_num = receiptNumber;
            _receiptNumberLabel.text = receiptNumber;
            
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah sesi gagal."] delegate:self];
            [alert show];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah sesi gagal."] delegate:self];
        [alert show];
        
    }];
}

#pragma mark - Change receipt number delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber
{
    [self requestChangeReceiptNumber:receiptNumber];
}

@end
