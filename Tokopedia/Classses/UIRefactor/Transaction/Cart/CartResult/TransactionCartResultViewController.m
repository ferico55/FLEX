//
//  TransactionCartResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "TransactionBuyResult.h"
#import "TransactionCartResultViewController.h"
#import "TransactionCartResultCell.h"
#import "TransactionCartResultPaymentCell.h"

#import "TxOrderTabViewController.h"

@interface TransactionCartResultViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_listSystemBank;
    NSMutableArray *_listTotalPayment;
    BOOL _isnodata;
    TransactionBuyResult *_cartBuy;
}
@property (weak, nonatomic) IBOutlet UIButton *confirmPaymentButton;
@property (weak, nonatomic) IBOutlet UILabel *listPaymentTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *tableTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (strong, nonatomic) IBOutlet UIView *viewConfirmPayment;

@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (strong, nonatomic) IBOutlet UIView *headerPaymentListView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (strong, nonatomic) IBOutlet UIView *paymentStatusView;
@property (weak, nonatomic) IBOutlet UIButton *paymentStatusButton;

@end

@implementation TransactionCartResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listSystemBank = [NSMutableArray new];
    _listTotalPayment = [NSMutableArray new];
    
    _cartBuy = [_data objectForKey:DATA_CART_RESULT_KEY];
    //TODO::
    if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TRANSFER_BANK)]) {
        [_listSystemBank addObjectsFromArray:_cartBuy.system_bank];
    }

    if ([_cartBuy.transaction.deposit_amount integerValue]>0) {
        if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)]) {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_JUMLAH_YANG_SUDAH_DIBAYAR,
                                         DATA_VALUE_KEY : _cartBuy.transaction.deposit_amount_idr
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
        else
        {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_TOTAL_TAGIHAN ,
                                         DATA_VALUE_KEY : _cartBuy.transaction.grand_total_idr
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
        
        NSArray *detailPaymentIfUsingSaldo = @[
                                               @{DATA_NAME_KEY : STRING_SALDO_TOKOPEDIA_TERPAKAI,
                                                 DATA_VALUE_KEY : _cartBuy.transaction.deposit_amount_idr
                                                 },
                                               @{DATA_NAME_KEY : STRING_SALDO_TOKOPEDIA_TERSISA,
                                                 DATA_VALUE_KEY : _cartBuy.transaction.deposit_left
                                             },
                                           ];
        [_listTotalPayment addObjectsFromArray:detailPaymentIfUsingSaldo];
    }
    if ([_cartBuy.transaction.payment_left integerValue]>0) {
        NSArray *detailPayment = @[
                                   @{DATA_NAME_KEY : STRING_JUMLAH_YANG_HARUS_DIBAYAR,
                                     DATA_VALUE_KEY : _cartBuy.transaction.payment_left_idr
                                     },
                                   ];
        [_listTotalPayment addObjectsFromArray:detailPayment];
    }

    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:158.0f/255 green:158.0f/255 blue:158.0f/255 alpha:1],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *footerAttributedText = [[NSAttributedString alloc] initWithString:_footerLabel.text
                                                                                    attributes:attributes];
    NSAttributedString *headerAttributedText = [[NSAttributedString alloc] initWithString:_listPaymentTitleLabel.text
                                                                               attributes:attributes];
    
    _listPaymentTitleLabel.attributedText = headerAttributedText;
    _footerLabel.attributedText = footerAttributedText;
    
    attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSString *tableTitleLabel = [NSString stringWithFormat:FORMAT_SUCCESS_BUY,_cartBuy.transaction.gateway_name];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:tableTitleLabel
                                                                               attributes:attributes];

    
    _tableView.tableHeaderView = _tableHeaderView;
    _tableTitleLabel.attributedText = attributedText;
    _tableTitleLabel.textAlignment = NSTextAlignmentCenter;
    _confirmPaymentButton.layer.cornerRadius = 2;
    _paymentStatusButton.layer.cornerRadius = 2;
    
    [_totalPaymentLabel setText:_cartBuy.transaction.payment_left_idr animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _listSystemBank.count+_listTotalPayment.count;
    return sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (indexPath.section < _listTotalPayment.count)
        cell = [self cellDetailPaymentAtIndexPath:indexPath];
    else
        cell = [self cellPaymentAtIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == _listTotalPayment.count + _listSystemBank.count-1) {
        return ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA)?_paymentStatusView:_viewConfirmPayment;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == _listTotalPayment.count) {
        return _headerPaymentListView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == _listTotalPayment.count) {
        return _headerPaymentListView.frame.size.height;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _listTotalPayment.count)
        return _totalPaymentCell.frame.size.height;
    else
        return  130;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == _listTotalPayment.count + _listSystemBank.count-1) {
        return ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA)?_paymentStatusView.frame.size.height:_viewConfirmPayment.frame.size.height;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    TxOrderTabViewController *vc = [TxOrderTabViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - methods Cell
-(UITableViewCell*)cellPaymentAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section < _listTotalPayment.count) {
        NSString *cellid = TRANSACTION_CART_PAYMENT_CELL_IDENTIDIER;
        cell = (TransactionCartResultPaymentCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [TransactionCartResultPaymentCell newcell];
        }
        
        ((TransactionCartResultPaymentCell*)cell).detailPaymentLabel.text = [_listTotalPayment[indexPath.section] objectForKey:DATA_NAME_KEY];
        ((TransactionCartResultPaymentCell*)cell).totalPaymentLabel.text = [_listTotalPayment[indexPath.section] objectForKey:DATA_VALUE_KEY];
    }
    else{
        NSString *cellid = TRANSACTION_CART_RESULT_CELL_IDENTIFIER;

        cell = (TransactionCartResultCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [TransactionCartResultCell newcell];
        }
        
        TransactionSystemBank *list = _listSystemBank[indexPath.section-_listTotalPayment.count];
        [((TransactionCartResultCell*)cell).bankNameLabel setText:[NSString stringWithFormat:@"Bank %@",list.sb_bank_name] animated:YES];
        [((TransactionCartResultCell*)cell).bankBranchLabel setText:[NSString stringWithFormat:@"Cab. %@",list.sb_bank_cabang] animated:YES];
        [((TransactionCartResultCell*)cell).accountNameLabel setText:[NSString stringWithFormat:@"a/n %@",list.sb_account_name] animated:YES];
        [((TransactionCartResultCell*)cell).accountNumberLabel setText:list.sb_account_no animated:YES];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.sb_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = ((TransactionCartResultCell*)cell).logoBankImageView;
        thumb.image = nil;
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
    #pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
    return cell;
}

-(UITableViewCell*)cellDetailPaymentAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_CART_PAYMENT_CELL_IDENTIDIER;
    
    UITableViewCell *cell = (TransactionCartResultPaymentCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartResultPaymentCell newcell];
    }
    
    NSString *detail = [_listTotalPayment[indexPath.section] objectForKey:DATA_NAME_KEY];
    NSString *totalPayment =  [_listTotalPayment[indexPath.section] objectForKey:DATA_VALUE_KEY];
    [((TransactionCartResultPaymentCell*)cell).detailPaymentLabel setText:detail animated:YES];
    [((TransactionCartResultPaymentCell*)cell).totalPaymentLabel setText:totalPayment animated:YES];
    cell.backgroundColor = ([detail isEqualToString:STRING_JUMLAH_YANG_HARUS_DIBAYAR])?[UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:229.f/255.f alpha:1]:[UIColor colorWithRed:238.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1];
    
    return cell;
}
@end
