//
//  TxOrderConfirmedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedViewController.h"
#import "TxOrderObjectMapping.h"
#import "TxOrderConfirmedCell.h"
#import "TxOrderConfirmedBankCell.h"
#import "TxOrderConfirmedButtonArrowCell.h"
#import "TxOrderConfirmedButtonCell.h"

#import "TxOrderConfirmedBankViewController.h"

#import "string_tx_order.h"

@interface TxOrderConfirmedViewController ()<UITableViewDelegate, UITableViewDataSource,TxOrderConfirmedButtonCellDelegate,TxOrderConfirmedCellDelegate>
{
    BOOL _isNodata;
    NSMutableArray *_list;
    NSMutableArray *_isExpandedCell;
    NSString *_URINext;
    
    NSInteger _page;
    UIRefreshControl *_refreshControl;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    TxOrderObjectMapping *_mapping;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TxOrderConfirmedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _isNodata = NO;
    _list = [NSMutableArray new];
    _mapping = [TxOrderObjectMapping new];
    _isExpandedCell = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    
    [self configureRestKit];
    [self request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isNodata ? 0 : _list.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    switch (indexPath.row) {
        case 0:
            cell = [self cellConfirmedAtIndexPath:indexPath];
            break;
        case 1:
            cell = (isShowBank)?[self cellConfirmedBankAtIndexPath:indexPath]:[self cellButtonArrowAtIndexPath:indexPath];
            break;
        case 2:
            cell = [self cellButtonAtIndexPath:indexPath];
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    if (indexPath.row == 0) {
        return 124;
    }
    else if (indexPath.row == 1)
        return isShowBank?181:44;
    else
        return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isShowBank = [_isExpandedCell[indexPath.section] boolValue];
    switch (indexPath.row) {
        case 1:
            isShowBank = !isShowBank;
            [_isExpandedCell replaceObjectAtIndex:indexPath.section withObject:@(isShowBank)];
            break;
            
        default:
            break;
    }
    [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [self configureRestKit];
            [self request];
        }
    }
}

#pragma mark - Cell Delegate
-(void)editConfirmation:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    if (detailOrder.has_user_bank ==1) {
        TxOrderConfirmedBankViewController *vc = [TxOrderConfirmedBankViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)uploadProofAtIndexPath:(NSIndexPath *)indexPath
{

}

-(void)didTapInvoiceButton:(UIButton *)button atIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    //TODO:: Invoice
    //NSArray *buttonAlertTitle =
    //UIAlertView *invoiceAlert = [UIAlertView alloc]initWithTitle:ALERT_TITLE_INVOICE_LIST message:nil delegate:self cancelButtonTitle:@"Tutup" otherButtonTitles:@"", nil
}

#pragma mark - Cell
-(UITableViewCell*)cellConfirmedAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = CONFIRMED_CELL_IDENTIFIER;
    
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    TxOrderConfirmedCell *cell = (TxOrderConfirmedCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedCell newCell];
    }
    
    [cell.dateLabel setText:detailOrder.payment_date animated:YES];
    [cell.totalPaymentLabel setText:detailOrder.payment_amount animated:YES];
    [cell.totalInvoiceButton setTitle:[NSString stringWithFormat:@"%@ Invoice", detailOrder.order_count] forState:UIControlStateNormal];
    
    return cell;
}

-(UITableViewCell*)cellConfirmedBankAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BANK_CELL_IDENTIFIER;
 
    TxOrderConfirmedList *detailOrder = _list[indexPath.section];
    
    TxOrderConfirmedBankCell *cell = (TxOrderConfirmedBankCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedBankCell newCell];
    }
    
    [cell.userNameLabel setText:detailOrder.user_bank_name animated:YES];
    [cell.bankNameLabel setText:detailOrder.user_bank_name animated:YES];
    [cell.nomorRekLabel setText:detailOrder.user_account_no animated:YES];
    [cell.recieverNomorRekLabel setText:[NSString stringWithFormat:@"%@ - %@",detailOrder.bank_name,detailOrder.system_account_no] animated:YES];
    
    return cell;
}

-(UITableViewCell*)cellButtonAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BUTTON_CELL_IDENTIFIER;
    
    TxOrderConfirmedButtonCell *cell = (TxOrderConfirmedButtonCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedButtonCell newCell];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(UITableViewCell*)cellButtonArrowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = BUTTON_ARROW_CELL_IDENTIFIER;
    
    TxOrderConfirmedButtonArrowCell *cell = (TxOrderConfirmedButtonArrowCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmedButtonArrowCell newCell];
    }
    
    return cell;
}

#pragma mark - Request
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKit
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmed class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmedResult class]];
    RKObjectMapping *listMapping = [_mapping confirmedListMapping];
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:kTKPD_APILISTKEY
                                                                              withMapping:listMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:listRel];
 
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
}

-(void)request
{
    if (_request.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_TX_ORDER_PAYMENT_CONFIRMED};
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxOrderConfirmed *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    [self requestProcess:object];
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TxOrderConfirmed *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    if (_page == 1) {
                        [_list removeAllObjects];
                        [_isExpandedCell removeAllObjects];
                    }
                    
                    [_list addObjectsFromArray:order.result.list];
                    
                    if (_list.count >0) {
                        _isNodata = NO;
                        
                        for (int i =0; i<_list.count; i++) {
                            [_isExpandedCell addObject:@(NO)];
                        }
                    }
                    
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            [self cancel];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

@end
