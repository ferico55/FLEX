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
#import "LabelMenu.h"
#import "StickyAlertView.h"
#import "NavigateViewController.h"

@interface DetailShipmentStatusViewController ()
<
    LabelMenuDelegate,
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
    
    NSArray *_history;
    NSString *_currentReceiptNumber;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTransactionDetail;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
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
    _tableView.estimatedRowHeight = 125.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    _invoiceNumberLabel.text = _order.order_detail.detail_invoice;
    _paymentMethodLabel.text = _order.order_payment.payment_gateway_name;
    labelReceiptNumber.text = _order.order_detail.detail_ship_ref_num;
    labelReceiptNumber.userInteractionEnabled = YES;
    labelReceiptNumber.delegate = self;
    [labelReceiptNumber addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
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
    
    if (_order.order_shipment.shipment_id == 10) {
        _changeReceiptButton.hidden = YES;
    }
    
    _history = _order.order_history;
    _currentReceiptNumber = self.order.order_detail.detail_ship_ref_num;
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
            [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
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
    return _history.count;
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
    
    OrderHistory *history = [_history objectAtIndex:indexPath.row];
    
    [cell setSubjectLabelText:history.history_action_by];
    cell.dateLabel.text = history.history_status_date_full;
    
    NSString *status;
    if ([history.history_action_by isEqualToString:@"Buyer"]) {
        status = [history.history_buyer_status stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br><br>"];
    } else {
        status = [history.history_seller_status stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br><br>"];
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@",
                                                  history.history_comments]];
    }
    [cell setStatusLabelText:status];
    
    [cell setColorThemeForActionBy:history.history_action_by];
    
    if (indexPath.row == (_history.count-1)) {
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
                                                        kTKPD_APIERRORMESSAGEKEY        : kTKPD_APIERRORMESSAGEKEY
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
                            API_USER_ID_KEY             : [[auth objectForKey:API_USER_ID_KEY] stringValue],
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
            labelReceiptNumber.text = receiptNumber;
            
            if ([self.delegate respondsToSelector:@selector(successChangeReceiptWithOrderHistory:)]) {

                NSString *historyComments = [NSString stringWithFormat:@"Ubah dari %@ menjadi %@",
                                             _currentReceiptNumber,
                                             receiptNumber];

                NSDate *now = [NSDate date];
                
                NSDateFormatter *dateFormatFull = [[NSDateFormatter alloc] init];
                [dateFormatFull setDateFormat:@"d MM yyyy HH:mm"];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"d/MM/yyyy HH:mm"];
                
                OrderHistory *history = [OrderHistory new];
                history.history_status_date = [dateFormat stringFromDate:now];
                history.history_status_date_full = [dateFormatFull stringFromDate:now];
                history.history_order_status = @"530";
                history.history_comments = historyComments;
                history.history_action_by = @"Seller";
                history.history_buyer_status = @"Perubahan nomor resi pengiriman";
                history.history_seller_status = @"Perubahan nomor resi pengiriman";

                NSMutableArray *histories = [NSMutableArray arrayWithArray:_history];
                [histories insertObject:history atIndex:0];
                _history = histories;

                [self.tableView reloadData];

                [self.delegate successChangeReceiptWithOrderHistory:history];
                
                _currentReceiptNumber = receiptNumber;
            }
            
        } else if (actionOrder.message_error) {

            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:actionOrder.message_error
                                                                           delegate:self];
            [alert show];
            
        } else {
            
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah resi gagal."]
                                                                           delegate:self];
            [alert show];
        
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Proses rubah resi gagal."] delegate:self];
        [alert show];
        
    }];
}


#pragma mark - Method
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state==UIGestureRecognizerStateBegan) {
        UILabel *lblResi = (UILabel *)sender.view;
        [lblResi becomeFirstResponder];
        
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:lblResi.frame inView:lblResi.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}


#pragma mark - Change receipt number delegate

- (void)changeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)history
{
    [self requestChangeReceiptNumber:receiptNumber];
}


#pragma mark - LabelMenu Delegate
- (void)duplicate:(int)tag
{
    [UIPasteboard generalPasteboard].string = labelReceiptNumber.text;    
}
@end
