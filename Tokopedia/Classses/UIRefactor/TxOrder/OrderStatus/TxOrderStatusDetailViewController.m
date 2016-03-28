//
//  TxOrderStatusDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_tx_order.h"

#import "TransactionAction.h"

#import "TxOrderStatusDetailViewController.h"

#import "NavigateViewController.h"

#import "TxOrderTransactionDetailViewController.h"
#import "TrackOrderViewController.h"

#import "DetailShipmentStatusCell.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "TransactionCartRootViewController.h"

#import "ResolutionCenterDetailViewController.h"

#import "RequestCancelResolution.h"

#define TAG_ALERT_REORDER 10
#define TAG_ALERT_COMPLAIN 11
#define TAG_ALERT_CONFIRMATION 12

@interface TxOrderStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate, ResolutionCenterDetailViewControllerDelegate>
{
    NavigateViewController *_navigate;
    RequestCancelResolution *_requestCancelComplain;
}

@property (strong, nonatomic) IBOutlet UIView *headerTwoButton;
@property (strong, nonatomic) IBOutlet UIView *headerOneButtonComplain;
@property (strong, nonatomic) IBOutlet UIView *headerOneButton;
@property (strong, nonatomic) IBOutlet UIView *headerViewWithoutButton;
@property (weak, nonatomic) IBOutlet UIButton *transactionDetailButton;
@property (strong, nonatomic) IBOutlet UIView *headerReorderView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *invoiceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TxOrderStatusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    self.title = @"Detail Status";
    
    switch (_buttonHeaderCount) {
        case 0:
            _tableView.tableHeaderView = _headerViewWithoutButton;
            break;
        case 1:
            _tableView.tableHeaderView = _headerOneButton;
            break;
        case 2:
            _tableView.tableHeaderView = _headerTwoButton;
            break;
        default:
            break;
    }
    if (_isComplain) {
        _tableView.tableHeaderView = _headerOneButtonComplain;
    }
    if (_reOrder) {
        _tableView.tableHeaderView = _headerReorderView;
    }
    
    [_invoiceLabel makeObjectsPerformSelector:@selector(setText:) withObject:_order.order_detail.detail_invoice];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    if (_buttonHeaderCount >0) {
        UIBarButtonItem *trackBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lacak" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [trackBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = trackBarButtonItem;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
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
        NSRange range = [history.history_seller_status rangeOfString:@"Pesanan telah dikirim"];
        if(range.location != NSNotFound){
            status = [NSString stringWithFormat:@"%@\n\n%@",history.history_seller_status, [self AWBString]];
        }
        else
            status = history.history_seller_status;
    }
    if (![history.history_comments isEqualToString:@"0"]) {
        status = [status stringByAppendingString:[NSString stringWithFormat:@"\n\nKeterangan: \n%@%@", history.history_comments,[self AWBString]]];
    }
    CGSize messageSize = [DetailShipmentStatusCell messageSize:status];
    return messageSize.height;
}

-(NSString*)AWBString
{
    NSString *shipRef = _order.order_detail.detail_ship_ref_num?:@"";
    NSLog(@"shipping resi :%@",shipRef);
    NSString *lastComment = _order.order_last.last_comments?:@"";
    
    NSMutableArray *comment = [NSMutableArray new];
    
    if (shipRef &&
        ![shipRef isEqualToString:@""] &&
        ![shipRef isEqualToString:@"0"])
    {
        [comment addObject:[NSString stringWithFormat:@"Nomor resi: %@", _order.order_last.last_shipping_ref_num]];
    }
    if (lastComment && ![lastComment isEqualToString:@"0"] && [lastComment isEqualToString:@""]) {
        [comment addObject:lastComment];
    }
    
    NSString *statusString = [[comment valueForKey:@"description"] componentsJoinedByString:@"\n"];
    return statusString;
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
        NSRange range = [history.history_seller_status rangeOfString:@"Pesanan telah dikirim"];
        if(range.location != NSNotFound){
            status = [NSString stringWithFormat:@"%@\n\n%@",history.history_seller_status, [self AWBString]];
        }
        else
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

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        TrackOrderViewController *vc = [TrackOrderViewController new];
        vc.orderID = [_order.order_detail.detail_order_id integerValue];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        UIButton *button = (UIButton *)sender;
        if (button.tag == 10) {
            //Confirm Delivery
            UIAlertView *alertConfirmation = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:ALERT_DELIVERY_CONFIRM_FORMAT,_order.order_shop.shop_name] message:@"Klik Selesai untuk menyelesaikan transaksi dan meneruskan dana ke penjual.\nKlik Komplain jika pesanan yang diterima berkendala (kurang/rusak/ lain-lain)." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Selesai",@"Komplain", nil];
            alertConfirmation.tag = TAG_ALERT_CONFIRMATION;
            [alertConfirmation show];
        }
        else if (button.tag == 11)
        {
            //Complain
            [self showAlertViewOpenComplain];
        }
        else if (button.tag == 12)
        {
            //lihat complain
            ResolutionCenterDetailViewController *vc = [ResolutionCenterDetailViewController new];
            NSDictionary *queries = [NSDictionary dictionaryFromURLString:_order.order_button.button_res_center_url];
            NSString *resolutionID = [queries objectForKey:@"id"];
            vc.resolutionID = resolutionID;
            vc.indexPath = _indexPath;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (button.tag == 13)
        {
            //Pesan ulang
            UIAlertView *alertConfirmation = [[UIAlertView alloc]initWithTitle:ALERT_REORDER_TITLE
                                                                       message:ALERT_REORDER_DESCRIPTION
                                                                      delegate:self
                                                             cancelButtonTitle:@"Tidak"
                                                             otherButtonTitles:@"Ya", nil];
            alertConfirmation.tag = TAG_ALERT_REORDER;
            [alertConfirmation show];
        }
        else{
            //Transaction Detail
            TxOrderTransactionDetailViewController *vc = [TxOrderTransactionDetailViewController new];
            vc.order = _order;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (IBAction)gesture:(id)sender {
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
}

-(void)showAlertViewOpenComplain
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Buka Komplain" message:@"Apakah Anda sudah menerima barang yang dipesan?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Tidak Terima", @"Terima", @"Batal", nil];
    alert.tag = TAG_ALERT_COMPLAIN;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_REORDER) {
        if (buttonIndex == 1) {
            [_delegate reOrder:_order atIndexPath:_indexPath];
            [_delegate delegateViewController:self];
        }
    }
    else if (alertView.tag == TAG_ALERT_COMPLAIN)
    {
        if (buttonIndex == 2) {
            return;
        }
        
        InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
        vc.controllerTitle = @"Buka Komplain";
        if (buttonIndex == 0) {
            //Tidak Terima Barang
            vc.isGotTheOrder = NO;
        }
        else if (buttonIndex ==1)
        {
            //Terima barang
            vc.isGotTheOrder = YES;
            
        }
        vc.order = _order;
        vc.isCanEditProblem = YES;
        vc.delegate = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (alertView.tag == TAG_ALERT_CONFIRMATION)
    {
        switch (buttonIndex) {
            case 1://Selesai
            {
                [_delegate confirmDelivery:_order atIndexPath:_indexPath];
                [_delegate delegateViewController:self];
            }
                break;
            case 2://Complain
            {
                [self showAlertViewOpenComplain];
            }
                break;
            default:
                break;
        }
    }
}

-(void)shouldCancelComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath *)indexPath
{
    [_delegate shouldCancelComplain:resolution atIndexPath:indexPath];
    [_delegate delegateViewController:self];

}

@end
