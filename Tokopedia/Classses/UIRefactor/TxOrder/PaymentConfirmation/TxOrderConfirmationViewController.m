//
//  TxOrderConfirmationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmPaymentForm.h"
#import "TxOrderCancelPaymentForm.h"

#import "NoResult.h"
#import "string_tx_order.h"

#import "TxOrderConfirmationViewController.h"
#import "TxOrderConfirmationDetailViewController.h"
#import "TxOrderConfirmationCell.h"
#import "TxOrderPaymentViewController.h"

#import "TxOrderPaymentViewController.h"

#import "TransactionAction.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "RequestOrderData.h"

@interface TxOrderConfirmationViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate ,TxOrderConfirmationCellDelegate, TxOrderConfirmationDetailViewControllerDelegate, TokopediaNetworkManagerDelegate, TxOrderPaymentViewControllerDelegate, LoadingViewDelegate>
{
    NSInteger _page;
    NSMutableArray<TxOrderConfirmationList*>*_list;
    
    NSMutableDictionary *_dataInput;
    BOOL _isNodata;
    UIRefreshControl *_refreshControl;
    
    NSString *_URINext;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerCancelPayment;
    __weak RKManagedObjectRequestOperation *_requestCancelPayment;
    
    LoadingView *_loadingView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *multipleSelectFooter;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmationButton;

@end

@implementation TxOrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _page = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequest)
                                                 name:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME
                                               object:nil];
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    [self doRequestListconfirmation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = @"";
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Action
- (IBAction)tap:(UIButton*)button {
    NSMutableArray *selectedOrder = [NSMutableArray new];
    for (TxOrderConfirmationList *order in _list) {
        if (order.isSelectedPayment) {
            [selectedOrder addObject:order];
        }
    }
    switch (button.tag) {
        case 10:
        {

            if ([selectedOrder count]>0) {
                
                [self doRequestGetDataCancelConfirmation:[selectedOrder copy]];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Pilih Payment terlebih dahulu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }
            break;
        case 11:
        {
            if ([selectedOrder count]>0) {
                TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
                vc.delegate = self;
                NSMutableArray *confirmationIDs = [NSMutableArray new];
                for (TxOrderConfirmationList *order in [selectedOrder copy]) {
                    [confirmationIDs addObject:order.confirmation.confirmation_id];
                }
                vc.paymentID = confirmationIDs;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"Pilih Payment terlebih dahulu" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setIsMultipleSelection:(BOOL)isMultipleSelection
{
    _isMultipleSelection = isMultipleSelection;
    _multipleSelectFooter.hidden = !(_isMultipleSelection);
    if (!_isMultipleSelection) {
        _tableView.contentInset = UIEdgeInsetsZero;
        for (TxOrderConfirmationList *order in _list) {
            order.isSelectedPayment = NO;
        }
    }
    else _tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    [_tableView reloadData];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isNodata ? 1 : _list.count;
#else
    return _isNodata ? 0 : _list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TxOrderConfirmationCell* cell = nil;
    NSString *cellid = TRANSACTION_ORDER_CONFIRMATION_CELL_IDENTIFIER;
    
    cell = (TxOrderConfirmationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationCell newcell];
        cell.delegate = self;
    }
    TxOrderConfirmationList *detailOrder = _list[indexPath.row];
    cell.deadlineDateLabel.text = detailOrder.confirmation.pay_due_date?:@"";
    cell.transactionDateLabel.text = detailOrder.confirmation.create_time?:@"";
    cell.shopNameLabel.text = detailOrder.confirmation.shop_list?:@"";
    cell.totalInvoiceLabel.text = detailOrder.confirmation.left_amount?:@"";
    cell.indexPath = indexPath;
    cell.selectionButton.hidden = !(_isMultipleSelection);
    cell.frameView.hidden = !(_isMultipleSelection);
    
    UIColor *selectedColor =[UIColor colorWithRed:18.0f/255.0f green:199.0f/255.0f blue:0.0f/255.0f alpha:1];
    UIColor *unSelectColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1];
    UIColor *enableColor = [UIColor colorWithRed:117.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1];
    
    cell.cancelConfirmationButton.enabled = !(_isMultipleSelection);
    if (!cell.cancelConfirmationButton.enabled)
        [cell.cancelConfirmationButton setTitleColor:unSelectColor forState:UIControlStateNormal];
    else [cell.cancelConfirmationButton setTitleColor:enableColor forState:UIControlStateNormal];
    
    cell.confirmationButton.enabled = !(_isMultipleSelection);
    if (!cell.confirmationButton.enabled)
        [cell.confirmationButton setTitleColor:unSelectColor forState:UIControlStateNormal];
    else [cell.confirmationButton setTitleColor:enableColor forState:UIControlStateNormal];
    
    if (_isMultipleSelection)
    {
        cell.selectionButton.selected = detailOrder.isSelectedPayment;
        [cell.cancelConfirmationButton setTintColor:unSelectColor];
        [cell.frameView setBackgroundColor:detailOrder.isSelectedPayment?selectedColor:unSelectColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isMultipleSelection) {
        _list[indexPath.row].isSelectedPayment = YES;
        [_tableView reloadData];
    }
    else {
        TxOrderConfirmationDetailViewController *detailViewController = [TxOrderConfirmationDetailViewController new];
        detailViewController.indexPath = indexPath;
        detailViewController.data = @{DATA_SELECTED_ORDER_KEY:_list[indexPath.row]};
        detailViewController.delegate = self;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [self doRequestListconfirmation];
        }
    }
}

#pragma mark - Delegate

-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isMultipleSelection) {
        _list[indexPath.row].isSelectedPayment = YES;
        
        [self doRequestGetDataCancelConfirmation:@[_list[indexPath.row]]];
    }
}

-(void)didCancelOrder:(TxOrderConfirmationList *)order
{
    [_list removeObject:order];
    [_tableView reloadData];
}

-(void)shouldConfirmOrderAtIndexPath:(NSIndexPath *)indexPath
{
    _confirmationButton.enabled = YES;
    if (!_isMultipleSelection) {
        TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
        vc.paymentID = @[_list[indexPath.row].confirmation.confirmation_id]?:@[@""];
        vc.delegate  = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self doCancelPayments];
    }
}

#pragma mark - Request Get Transaction Order Payment Confirmation
-(void)doRequestListconfirmation{
    
    if(!_refreshControl.isRefreshing) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [RequestOrderData fetchListPaymentConfirmationPage:_page success:^(NSArray *list, NSInteger nextPage, NSString *uriNext) {
        [_act stopAnimating];

        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        
        if (_page == 1) {
            [_list removeAllObjects];
        }
        
        [_list addObjectsFromArray:list];
        
        if (_list.count >0) {
            _isNodata = NO;
            _URINext =  uriNext;
            _page = nextPage;
            
            for (int i = 0; i<_list.count; i++) {
                _list[i].isSelectedPayment = NO;
            }
        }
        else
        {
            _isNodata = YES;
            NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
            _tableView.tableFooterView = noResultView;
        }
        
        [_act stopAnimating];
        [_delegate isNodata:_isNodata];
        
        [_tableView reloadData];
    } failure:^(NSError *error) {
        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        [_act stopAnimating];
        _tableView.tableFooterView = _loadingView.view;
    }];
}

#pragma loading view delegate
-(void)pressRetryButton
{
    [_act startAnimating];
    _tableView.tableFooterView = _footer;
    [self doRequestListconfirmation];
}

#pragma mark - Request Cancel Payment Confirmation


-(void)doCancelPayments{
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    for (TxOrderConfirmationList *order in _list) {
        if (order.isSelectedPayment) {
            [confirmationIDs addObject:order.confirmation.confirmation_id];
        }
    }
        
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    [RequestOrderAction fetchCancelConfirmationID:confirmationID Success:^(TransactionAction *data) {
        NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(confirmationIDs.count)};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];
        [self refreshRequest];

    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Request Cancel Payment Form
-(void)doRequestGetDataCancelConfirmation:(NSArray*)objects{
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    
    for (TxOrderConfirmationList *order in objects) {
        [confirmationIDs addObject:order.confirmation.confirmation_id];
    }
    
    [_tableView reloadData];
    
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    [RequestOrderData fetchDataCancelConfirmationID:confirmationID Success:^(TxOrderCancelPaymentFormForm *data) {
        
        NSString *cancelAlertDesc;
        NSString *totalRefund = [data.total_refund stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@",-" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([totalRefund isEqualToString:@"0"])
            cancelAlertDesc = @"Apakah anda yakin membatalkan transaksi ini?";
        else
            cancelAlertDesc = [NSString stringWithFormat:ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION,data.total_refund];
        
        UIAlertView *cancelAlert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION
                                                             message:cancelAlertDesc
                                                            delegate:self
                                                   cancelButtonTitle:@"Tidak"
                                                   otherButtonTitles:@"Ya", nil];
        [cancelAlert show];
        NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(objects.count)};
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];

        [_refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [_refreshControl endRefreshing];
    }];
}

#pragma mark - Methods

-(void)showStickyAlertErrorMessage:(NSArray *)messages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:messages delegate:self];
    [alert show];
}

-(void)refreshRequest
{
    _page = 1;
    
    [self doRequestListconfirmation];
    [_act stopAnimating];
}

-(void)successConfirmPayment:(NSArray *)payment
{
    [_list removeObjectsInArray:payment];
    [_tableView reloadData];
}

- (void)shouldPopViewController {
    
}

-(void)failedOrCancelConfirmPayment:(NSArray *)payment
{

}

@end
