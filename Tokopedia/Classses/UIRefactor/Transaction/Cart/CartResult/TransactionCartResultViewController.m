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
#import "TxOrderStatusViewController.h"

#import "WebViewController.h"

#import "TxOrderTabViewController.h"
#import "AppsFlyerTracker.h"

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
@property (weak, nonatomic) IBOutlet UILabel *footerLabel1;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (strong, nonatomic) IBOutlet UIView *paymentStatusView;
@property (weak, nonatomic) IBOutlet UIButton *paymentStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *contactUsLabel;

@end

#define kTKPDMORE_PRIVACY_URL @"https://m.tokopedia.com/privacy.pl"
#define kTKPDMORE_HELP_URL @"https://www.tokopedia.com/bantuan"
#define kTKPDMORE_HELP_TITLE @"Bantuan"
#define kTKPDMORE_PRIVACY_TITLE @"Kebijakan Privasi"

@implementation TransactionCartResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listSystemBank = [NSMutableArray new];
    _listTotalPayment = [NSMutableArray new];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    paragraphStyle.lineSpacing = 6.0;
    
    NSString *string1 = _footerLabel1.text;
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc]initWithString:string1];
    [title1 addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_11 range:NSMakeRange(0, title1.length)];
    
    //add color
    [title1 addAttribute:NSForegroundColorAttributeName
                   value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                   range:[string1 rangeOfString:@"Konfirmasi Pembayaran"]];
    
    //add alignment
    [title1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title1.length)];
    
    _footerLabel1.attributedText = title1;
    
    NSString *string = @"Silahkan menghubungi kami apabila Anda mengalami kesulitan.";
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]initWithString:string];
    UIFont *font = FONT_GOTHAM_BOOK_11;
    [title addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
    
    //add color
    [title addAttribute:NSForegroundColorAttributeName
                  value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                  range:[string rangeOfString:@"menghubungi kami"]];
    
    //add alignment
    [title addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title.length)];
    
    _contactUsLabel.attributedText = title;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _tableView.contentOffset = CGPointZero;
    [self setDataDefault];
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        return ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)] ||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CLICK_BCA)] ||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)])
        ?_paymentStatusView:_viewConfirmPayment;
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
        return ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)] ||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CLICK_BCA)] ||
                [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)])
        ?_paymentStatusView.frame.size.height:
        _viewConfirmPayment.frame.size.height;
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
    UIButton *button = (UIButton*)sender;
    if (button == _confirmPaymentButton || button.tag == 10) {
        TxOrderTabViewController *vc = [TxOrderTabViewController new];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (button == _paymentStatusButton)
    {
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_status";
        vc.viewControllerTitle = @"Status Pemesanan";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strURL = kTKPDMORE_HELP_URL;
        webViewController.strTitle = kTKPDMORE_HELP_TITLE;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
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

-(void)setDataDefault
{
    [_listSystemBank removeAllObjects];
    [_listTotalPayment removeAllObjects];
    
    _cartBuy = [_data objectForKey:DATA_CART_RESULT_KEY];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"Rp ";
    formatter.currencyGroupingSeparator = @".";
    formatter.currencyDecimalSeparator = @",";
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    
    if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TRANSFER_BANK)]) {
        [_listSystemBank addObjectsFromArray:_cartBuy.system_bank];
    }
    
     if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)])
     {
         self.screenName = @"Thank you Page - Saldo Tokopedia";
         NSArray *detailPaymentIfUsingSaldo = @[
                                                @{DATA_NAME_KEY : STRING_SALDO_TOKOPEDIA_TERPAKAI,
                                                  DATA_VALUE_KEY : _cartBuy.transaction.deposit_amount_idr?:@""
                                                  }
                                                ];
         [_listTotalPayment addObjectsFromArray:detailPaymentIfUsingSaldo];
         
         if ([_cartBuy.transaction.voucher_amount integerValue]>0) {
             NSArray *detailPayment = @[
                                        @{DATA_NAME_KEY : STRING_PENGGUNAAN_KUPON,
                                          DATA_VALUE_KEY : _cartBuy.transaction.voucher_amount_idr?:@""
                                          },
                                        ];
             [_listTotalPayment addObjectsFromArray:detailPayment];
         }
     }
    else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TRANSFER_BANK)])
    {
        self.screenName = @"Thank you Page - Transfer Bank";
        if ([_cartBuy.transaction.voucher_amount integerValue]>0) {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_PENGGUNAAN_KUPON,
                                         DATA_VALUE_KEY : _cartBuy.transaction.voucher_amount_idr?:@""
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
        
        if ([_cartBuy.transaction.deposit_amount integerValue]>0) {
            NSArray *detailPaymentIfUsingSaldo = @[
                                                   @{DATA_NAME_KEY : STRING_SALDO_TOKOPEDIA_TERPAKAI,
                                                     DATA_VALUE_KEY : _cartBuy.transaction.deposit_amount_idr?:@""
                                                     }
                                                   ];
            [_listTotalPayment addObjectsFromArray:detailPaymentIfUsingSaldo];
        }
        NSArray *detailPayment = @[
                                   @{DATA_NAME_KEY : STRING_JUMLAH_YANG_HARUS_DIBAYAR,
                                     DATA_VALUE_KEY : _cartBuy.transaction.payment_left_idr?:@""
                                     },
                                   ];
        [_listTotalPayment addObjectsFromArray:detailPayment];
    }
    else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)] ||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CLICK_BCA)])
    {
        if([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)]) {
            self.screenName = @"Thank you Page - Mandiri eCash";
        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)]) {
            self.screenName = @"Thank you Page - Mandiri ClickPay";
        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CLICK_BCA)]) {
            self.screenName = @"Thank you Page - KlikBca";
        }
        NSArray *detailPaymentIfUsingSaldo = @[
                                               @{DATA_NAME_KEY : STRING_JUMLAH_YANG_SUDAH_DIBAYAR,
                                                 DATA_VALUE_KEY : _cartBuy.transaction.payment_left_idr?:@""
                                                 }
                                               ];
        [_listTotalPayment addObjectsFromArray:detailPaymentIfUsingSaldo];
        
        if ([_cartBuy.transaction.deposit_amount integerValue]>0) {
            NSArray *detailPaymentIfUsingSaldo = @[
                                                   @{DATA_NAME_KEY : STRING_SALDO_TOKOPEDIA_TERPAKAI,
                                                     DATA_VALUE_KEY : _cartBuy.transaction.deposit_amount_idr?:@""
                                                     }
                                                   ];
            [_listTotalPayment addObjectsFromArray:detailPaymentIfUsingSaldo];
        }
        
        if ([_cartBuy.transaction.voucher_amount integerValue]>0) {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_PENGGUNAAN_KUPON,
                                         DATA_VALUE_KEY : _cartBuy.transaction.voucher_amount_idr?:@""
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
    }
    
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{
                                                                              AFEventParamRevenue : _cartBuy.transaction.grand_total_before_fee,
                                                                              }];
    
    [_footerLabel setCustomAttributedText:_footerLabel.text];
    [_listPaymentTitleLabel setCustomAttributedText:_listPaymentTitleLabel.text];
    
    NSString *tableTitleLabel = [NSString stringWithFormat:FORMAT_SUCCESS_BUY,_cartBuy.transaction.gateway_name];
    [_tableTitleLabel setCustomAttributedText:tableTitleLabel];
    
    _tableView.tableHeaderView = _tableHeaderView;
    _tableTitleLabel.textAlignment = NSTextAlignmentCenter;
    _confirmPaymentButton.layer.cornerRadius = 2;
    _paymentStatusButton.layer.cornerRadius = 2;
    
    [_totalPaymentLabel setText:_cartBuy.transaction.payment_left_idr?:@"" animated:YES];
}
@end
