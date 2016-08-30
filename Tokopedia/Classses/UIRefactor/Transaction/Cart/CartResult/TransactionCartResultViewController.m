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

#import "NavigateViewController.h"

#import "WebViewController.h"

#import "TxOrderTabViewController.h"
#import <AppsFlyer/AppsFlyer.h>
#import "GalleryViewController.h"

#import "Localytics.h"
#import "TTTAttributedLabel.h"

@interface TransactionCartResultViewController ()<UITableViewDataSource, UITableViewDelegate,GalleryViewControllerDelegate,GalleryPhotoDelegate, PaymentCellDelegate, TTTAttributedLabelDelegate>
{
    NSMutableArray *_listSystemBank;
    NSMutableArray *_listTotalPayment;
    BOOL _isnodata;
    TransactionBuyResult *_cartBuy;
    NavigateViewController *_navigate;
    NSMutableParagraphStyle *paragraphStyle;
    
    BOOL _isWillApearFromGallery;
    BOOL _isExpanding;
    
    URLCacheConnection *_cacheConnection;
    URLCacheController *_cacheController;
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
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contactUsLabel;
@property (strong, nonatomic) IBOutlet UIView *indomaretStepsView;
@property (weak, nonatomic) IBOutlet UITextView *footerNotes;
@property (strong, nonatomic) IBOutlet UIView *headerViewIndomaret;
@property (strong, nonatomic) IBOutlet UIView *klikBCAStepsView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *klikBCAStepsLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *indomaretNotes;
@property (weak, nonatomic) IBOutlet UILabel *IndomaretCodeLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *klikBCAImages;
@property (strong, nonatomic) IBOutlet UITableViewCell *cashbackCell;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *klikBCAImagesSteps;
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
    
    _klikBCAImages = [NSArray sortViewsWithTagInArray:_klikBCAImages];
    
    _navigate = [NavigateViewController new];
    
    _listSystemBank = [NSMutableArray new];
    _listTotalPayment = [NSMutableArray new];
    
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    paragraphStyle.lineSpacing = 6.0;
    
    [self adjustFooterPaymentConfirmation];
    [self adjustFooterPurchaseStatus];
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_isWillApearFromGallery) {
        _tableView.contentOffset = CGPointZero;
        _isExpanding = NO;
    }
    else
    {
        _isWillApearFromGallery = NO;
    }
    
    [self setDataDefault];
    [_tableView reloadData];
    
    TransactionBuyResult *result = [_data objectForKey:DATA_CART_RESULT_KEY];
    NSString *voucherCode = [_data objectForKey:API_VOUCHER_CODE_KEY];
    [TPAnalytics trackPurchaseID:result.transaction.payment_id carts:result.transaction.carts coupon:voucherCode];
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
    NSInteger sectionCount = _listSystemBank.count+_listTotalPayment.count+1;
    return sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (indexPath.section < _listTotalPayment.count)
        cell = [self cellDetailPaymentAtIndexPath:indexPath];
    else if (indexPath.section == _listTotalPayment.count)
    {
        cell = _cashbackCell;
        cell.detailTextLabel.text = _cartBuy.transaction.cashback_idr?:@"Rp 0";
    }
    else
        cell = [self cellPaymentAtIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == _listTotalPayment.count -1 && section > 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableHeaderView.frame.size.width, 10)];
        view.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:229.f/255.f alpha:1];
        return view;
    }
    else if (section == _listTotalPayment.count + _listSystemBank.count) {
        if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)] ||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_CLICK_PAY)] ||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)] ||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CC)]||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INSTALLMENT)]||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BRI_EPAY)]
            ){
            return _paymentStatusView;
        }
        else if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_BCA_KLIK_BCA) {
            return _klikBCAStepsView;
        }
        else if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_INDOMARET) {
            return _indomaretStepsView;
        }
        else
            return _viewConfirmPayment;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < _listTotalPayment.count && section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableHeaderView.frame.size.width, 10)];
        view.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:229.f/255.f alpha:1];
        return view;
    }
    if (section == _listTotalPayment.count+1) {
        return _headerPaymentListView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < _listTotalPayment.count && section == 1) {
        if (!_isExpanding) {
            return 0.001f;
        }
        return 7;
    }
    else if (section == _listTotalPayment.count && _cartBuy.transaction.cashback >= 0) {
        return 10;
    }
    else if (section == _listTotalPayment.count+1) {
        return _headerPaymentListView.frame.size.height;
    }
    return 0.001f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section < _listTotalPayment.count)
    {
        if (indexPath.section == 0) {
            return 164;
        }
        else
        {
            if (!_isExpanding) {
                return 0;
            }
            return 30;
        }
    }
    else if (indexPath.section == _listTotalPayment.count)
    {
        if ([_cartBuy.transaction.cashback integerValue] == 0)
            return 0;
        else
        return 44;
    }
    else
        return 130;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section <  _listTotalPayment.count-1 )
    {
        return 0.001f;
    }
    else if (section == _listTotalPayment.count-1 && section > 0)
    {
        if (!_isExpanding) {
            return 0.001f;
        }
        return 7;
    }
    else if (section == _listTotalPayment.count + _listSystemBank.count) {
        if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)] ||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_CLICK_PAY)] ||
            [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)]){
                return _paymentStatusView.frame.size.height;
        }
        else if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_BCA_KLIK_BCA) {
            return 1168;
        }
        else if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_INDOMARET) {
            return 600;
        }
        else
            return _viewConfirmPayment.frame.size.height;
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
}

- (IBAction)gestureKlikBCAStepsImages:(UITapGestureRecognizer*)sender {
    _isWillApearFromGallery = YES;
    GalleryViewController *gallery = [GalleryViewController new];
    gallery.canDownload = NO;
    [gallery initWithPhotoSource:self withStartingIndex:sender.view.tag];
    [self.navigationController presentViewController:gallery animated:YES completion:nil];
}
- (IBAction)gestureGuideLabel:(id)sender {
    WebViewController *webViewController = [WebViewController new];
    webViewController.strURL = @"https://m.tokopedia.com/bantuan/pembayaran/klikbca";
    webViewController.strTitle = @"Pembayaran KlikBCA";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - GalleryPhoto Delegate
- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery
{
    return 4;
}

- (NSString*)photoGallery:(GalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSArray *BCASteps = @[
                          @"1.  Masuk ke situs www.klikbca.com. Masukkan User ID dan password Anda",
                          @"2.  Pilih pembayaran e-Commerce. Pilih Kategori Marketplace. Pilih Tokopedia",
                          @"3.  Masukkan KeyBCA Token untuk memproses transaksi",
                          @"4.  Anda tidak perlu melakukan konfirmasi pembayaran Tokopedia otomatis memverifikasi pembayaran Anda"
                          ];
    if(((int) index) < 0)
        return BCASteps[0];
    else if(((int)index) > BCASteps.count-1)
        return [BCASteps objectAtIndex:BCASteps.count-1];
    
    return [BCASteps objectAtIndex:index];
}

- (UIImage *)photoGallery:(NSUInteger)index {
    if(((int) index) < 0)
        return ((UIImageView *) [_klikBCAImages objectAtIndex:0]).image;
    else if(((int)index) > _klikBCAImages.count-1)
        return ((UIImageView *) [_klikBCAImages objectAtIndex:_klikBCAImages.count-1]).image;
    return ((UIImageView *) [_klikBCAImages objectAtIndex:index]).image;
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
        
        TransactionSystemBank *list = _listSystemBank[(indexPath.section-_listTotalPayment.count)-1];
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
    
    UITableViewCell *cell = nil;
    
    NSString *detail = [_listTotalPayment[indexPath.section] objectForKey:DATA_NAME_KEY];
    NSString *totalPayment =  [_listTotalPayment[indexPath.section] objectForKey:DATA_VALUE_KEY];
    
    if (indexPath.section == 0) {
        cell = (TransactionCartResultPaymentCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [TransactionCartResultPaymentCell newcell];
        }
        [((TransactionCartResultPaymentCell*)cell).detailPaymentLabel setText:detail animated:YES];
        [((TransactionCartResultPaymentCell*)cell).totalPaymentLabel setText:totalPayment animated:YES];
//        cell.backgroundColor = ([detail isEqualToString:STRING_JUMLAH_YANG_HARUS_DIBAYAR])?[UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:229.f/255.f alpha:1]:[UIColor colorWithRed:238.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1, _tableHeaderView.frame.size.width,1)];
        lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
        ((TransactionCartResultPaymentCell*)cell).delegate = self;
        [cell addSubview:lineView];
        UIImage *image = (_isExpanding)?[UIImage imageNamed:@"icon_arrow_up.png"]:[UIImage imageNamed:@"icon_arrow_down.png"];
        [((TransactionCartResultPaymentCell*)cell).expandingButton setImage:image forState:UIControlStateNormal];
    }
    else
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
        }
        cell.textLabel.text = detail;
        cell.detailTextLabel.text = totalPayment;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont title2Theme];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = [UIFont title2Theme];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:229.f/255.f alpha:1];
    cell.clipsToBounds = YES;
    
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
    
     if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)]) {
         
         [TPAnalytics trackScreenName:@"Thank you page - Saldo Tokopedia"];
         self.screenName = @"Thank you page - Saldo Tokopedia";
         
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
     else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TRANSFER_BANK)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_KLIK_BCA)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INDOMARET)]) {
         
        if([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_TRANSFER_BANK)]) {
        
            [TPAnalytics trackScreenName:@"Thank you page - Transfer Bank"];
            self.screenName = @"Thank you page - Transfer Bank";
            
        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_KLIK_BCA)]) {

            [TPAnalytics trackScreenName:@"Thank you page - KlikBCA"];
            self.screenName = @"Thank you page - KlikBCA";

        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INDOMARET)]) {
        
            [TPAnalytics trackScreenName:@"Thank you page - Indomaret"];
            self.screenName = @"Thank you page - Indomaret";

        }
        
        if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INDOMARET)]) {
            _cartBuy.transaction.payment_left_idr = _cartBuy.transaction.indomaret.total_charge_real_idr;
        }
        
        if(![_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_KLIK_BCA)] ||
           ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_KLIK_BCA)] &&
            ([_cartBuy.transaction.deposit_amount integerValue]>0 ||
             [_cartBuy.transaction.voucher_amount integerValue]>0)
            )
           ) {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_JUMLAH_YANG_HARUS_DIBAYAR,
                                         DATA_VALUE_KEY : _cartBuy.transaction.payment_left_idr?:@""
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
        
        if([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_KLIK_BCA)]||
           [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INDOMARET)])
        {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_TOTAL_TAGIHAN,
                                         DATA_VALUE_KEY : _cartBuy.transaction.grand_total_idr?:@""
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
        
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
        
        
        if([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INDOMARET)]) {
            NSArray *detailPayment = @[
                                       @{DATA_NAME_KEY : STRING_BIAYA_ADMINISTRASI_INDOMARET,
                                         DATA_VALUE_KEY : _cartBuy.transaction.indomaret.charge_real_idr?:@""
                                         },
                                       ];
            [_listTotalPayment addObjectsFromArray:detailPayment];
        }
    }
    else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)] ||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_CLICK_PAY)] ||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CC)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INSTALLMENT)]||
             [_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BRI_EPAY)]) {
        
        if([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_E_CASH)]) {

            [TPAnalytics trackScreenName:@"Thank you page - Mandiri eCash"];
            self.screenName = @"Thank you page - Mandiri eCash";
            
        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_MANDIRI_CLICK_PAY)]) {

            [TPAnalytics trackScreenName:@"Thank you page - Mandiri ClickPay"];
            self.screenName = @"Thank you page - Mandiri ClickPay";

        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BCA_CLICK_PAY)]) {
            
            [TPAnalytics trackScreenName:@"Thank you page - KlikBCA"];
            self.screenName = @"Thank you page - KlikBCA";

        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_CC)]) {
        
            [TPAnalytics trackScreenName:@"Thank you page - Credit Card"];
            self.screenName = @"Thank you page - Credit Card";

        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_INSTALLMENT)]) {

            [TPAnalytics trackScreenName:@"Thank you page - Installment"];
            self.screenName = @"Thank you page - Installment";

        } else if ([_cartBuy.transaction.gateway isEqual:@(TYPE_GATEWAY_BRI_EPAY)]) {
            
            [TPAnalytics trackScreenName:@"Thank you page - BRI E-PAY"];
            self.screenName = @"Thank you page - BRI E-PAY";
            
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
    if ([_cartBuy.transaction.lp_amount integerValue] > 0) {
        NSArray *detailPayment = @[
                                   @{DATA_NAME_KEY : STRING_LOYALTY_POINT,
                                     DATA_VALUE_KEY : [NSString stringWithFormat:@"(%@)",_cartBuy.transaction.lp_amount_idr?:@"Rp 0"]
                                     },
                                   ];
        [_listTotalPayment addObjectsFromArray:detailPayment];
    }
    
    
    NSDictionary *metodePembayaran =
                               @{DATA_NAME_KEY : STRING_METODE_PEMBAYARAN,
                                 DATA_VALUE_KEY : _cartBuy.transaction.gateway_name?:@""
                                 };
    [_listTotalPayment insertObject:metodePembayaran atIndex:1];
    
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{
                                                                              AFEventParamRevenue : _cartBuy.transaction.grand_total_before_fee,
                                                                              }];
        
    NSString *paymentMethod = _cartBuy.transaction.gateway_name;
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *paymentTotal = [[_cartBuy.transaction.grand_total_before_fee componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];

    NSDictionary *attributes = @{
        @"Payment Method" : paymentMethod,
        @"Total Transaction" : paymentTotal,
        @"Total Quantity" : @"",
        @"Total Shipping Fee" : @""
    };
    
    NSInteger totalPayment = 0;
    
    [Localytics tagEvent:@"Event : Finished Transaction"
              attributes:attributes
   customerValueIncrease:[NSNumber numberWithInteger:totalPayment]];

    NSString *profileAttribute = @"Profile : Total Transaction";
    
    [Localytics incrementValueBy:totalPayment
             forProfileAttribute:profileAttribute
                       withScope:LLProfileScopeApplication];
    
    [_footerLabel setCustomAttributedText:_footerLabel.text];
    [_listPaymentTitleLabel setCustomAttributedText:_listPaymentTitleLabel.text];
    
    NSString *tableTitleLabel = @"";
    
    [_tableTitleLabel setCustomAttributedText:tableTitleLabel];

    if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_BCA_KLIK_BCA) {
        
        tableTitleLabel = [NSString stringWithFormat:@"User ID KlikBCA Anda: %@",_cartBuy.transaction.klikbca_user];
        
        NSMutableAttributedString *attibutestring = [[NSMutableAttributedString alloc]initWithString:tableTitleLabel];
        
        // font
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:NSMakeRange(0, attibutestring.length)];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[tableTitleLabel rangeOfString:[NSString stringWithFormat:@"User ID KlikBCA Anda: %@",_cartBuy.transaction.klikbca_user ]]];
        
        [attibutestring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attibutestring.length)];
        
        _tableTitleLabel.attributedText = attibutestring;
    }
    
    if ([_cartBuy.transaction.gateway integerValue] == TYPE_GATEWAY_INDOMARET) {
        _IndomaretCodeLabel.text = _cartBuy.transaction.indomaret.payment_code;
        _tableView.tableHeaderView = _headerViewIndomaret;
    }
    else
       _tableView.tableHeaderView = _tableHeaderView;
    
    _tableTitleLabel.textAlignment = NSTextAlignmentCenter;
    _confirmPaymentButton.layer.cornerRadius = 2;
    _paymentStatusButton.layer.cornerRadius = 2;
    
    [_totalPaymentLabel setText:_cartBuy.transaction.payment_left_idr?:@"" animated:YES];
    
    [self adjustFooterIndomaret];
    [self adjustFooterKlikBCA];
    
}

#pragma mark - Footer View Methods
-(void)adjustFooterPurchaseStatus
{
    _contactUsLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _contactUsLabel.delegate = self;
    
    _contactUsLabel.text = @"Silakan menghubungi kami apabila Anda mengalami kesulitan.";
    NSRange range = [_contactUsLabel.text rangeOfString:@"menghubungi kami"];
    _contactUsLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName : [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1], NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    [_contactUsLabel addLinkToURL:[NSURL URLWithString:kTKPDMORE_HELP_URL] withRange:range];
}

-(void)adjustFooterPaymentConfirmation
{
    NSString *string1 = _footerLabel1.text;
    
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc]initWithString:string1];
    [title1 addAttribute:NSFontAttributeName value:[UIFont microTheme] range:NSMakeRange(0, title1.length)];
    
    //add color
    [title1 addAttribute:NSForegroundColorAttributeName
                   value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                   range:[string1 rangeOfString:@"Konfirmasi Pembayaran"]];
    
    //add alignment
    [title1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title1.length)];
    
    _footerLabel1.attributedText = title1;
}

-(void)adjustFooterIndomaret
{
    for (UILabel *label in _indomaretNotes) {
        
        label.numberOfLines = 0;
        
        switch (label.tag) {
            case 1:
                label.text = [NSString stringWithFormat:@"Catat dan simpan kode pembayaran Indomaret Anda, yaitu %@",_cartBuy.transaction.indomaret.payment_code];
                break;
            case 2:
                label.text = [NSString stringWithFormat:@"Tunjukkan kode pembayaran ke kasir Indomaret terdekat, dan lakukan pembayaran senilai %@",_cartBuy.transaction.indomaret.total_charge_real_idr];
                break;
            case 5:
                label.text = [NSString stringWithFormat:@"Jumlah yang harus Anda bayar sudah termasuk biaya administrasi Indomaret sebesar %@",_cartBuy.transaction.indomaret.charge_real_idr];
                break;
            default:
                break;
        }
        
        NSMutableAttributedString *attibutestring = [[NSMutableAttributedString alloc]initWithString:label.text];
        // font
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:NSMakeRange(0, attibutestring.length)];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[label.text rangeOfString:@"Silahkan ikuti langkah-langkah berikut untuk menyelesaikan pembayaran"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[label.text rangeOfString:[NSString stringWithFormat:@"%@",_cartBuy.transaction.indomaret.payment_code]]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[label.text rangeOfString:[NSString stringWithFormat:@"%@",_cartBuy.transaction.indomaret.charge_real_idr]]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[label.text rangeOfString:@"kode pembayaran Indomaret"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont smallTheme]
                               range:[label.text rangeOfString:@"Tunjukkan kode pembayaran"]];
        [attibutestring addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1]
                               range:[label.text rangeOfString:[NSString stringWithFormat:@"%@",_cartBuy.transaction.indomaret.total_charge_real_idr]]];
        if (label.tag != 3) {
            [attibutestring addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor colorWithRed:200.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1]
                                   range:[label.text rangeOfString:@"otomatis"]];
        }
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"KeyBCA Token"]];
        
        //add alignment
        [attibutestring addAttribute:NSParagraphStyleAttributeName
                               value:paragraphStyle
                               range:NSMakeRange(0, attibutestring.length)];
        
        label.attributedText = attibutestring;
        
    }
    
//    NSString *htmlString = [NSString stringWithFormat: @"<h1><strong>Silahkan ikuti langkah-langkah berikut untuk menyelesaikan pembayaran:</strong></h1><ol><li>Catat dan simpan <strong>kode pembayaran Indomaret</strong> Anda, yaitu <strong>%@</strong>.</li><li><strong>Tunjukkan kode pembayaran </strong>ke kasir Indomaret terdekat, dan lakukan pembayaran senilai <span style='color:#ff0000;'>%@</span>.</li><li>Setelah mendapatkan bukti pembayaran, pembayaran secara otomatis akan diverivikasi oleh Tokopedia.</li><li>Simpan bukti pembayaran yang sewaktu-waktu diperlukan jika terjadi kendala transaksi.</li></ol><p>&nbsp;</p><p><strong>Catatan</strong></p><ul><li>Jumlah yang harus Anda bayar sudah termasuk biaya administrasi Indomaret sebesar <span style='color:#ff0000;'>%@</span>.</li><li>Pesanan akan <span style='color:#ff0000;'>otomatis</span> dibatalkan apabila tidak melakukan pembayaran lebih dari 2 hari setelah kode pembayaran diberikan.</li></ul>",_cartBuy.transaction.indomaret.payment_code,_cartBuy.transaction.indomaret.total_charge_real_idr,_cartBuy.transaction.indomaret.charge_real_idr];
//    
//    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//
//    
//    _footerNotes.attributedText = attributedString;
}



-(void)adjustFooterKlikBCA
{
    for (UILabel *label in _klikBCAStepsLabels) {
        
        NSMutableAttributedString *attibutestring = [[NSMutableAttributedString alloc]initWithString:label.text];
        
        // font
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:NSMakeRange(0, attibutestring.length)];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"www.klikbca.com"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"e-Commerce"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"Marketplace"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"Tokopedia"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"KeyBCA Token"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"Tokopedia otomatis memverifikasi pembayaran Anda"]];
        [attibutestring addAttribute:NSFontAttributeName
                               value:[UIFont microTheme]
                               range:[label.text rangeOfString:@"disini"]];
        
        //add color
        [attibutestring addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1]
                               range:[label.text rangeOfString:@"disini"]];
        
        //add alignment
        [attibutestring addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attibutestring.length)];
        
        label.attributedText = attibutestring;
    }
}

-(void)didExpand
{
    _isExpanding = !_isExpanding;
    
    [_tableView reloadData];
}

# pragma mark - TTTAttributedLabel Delegate 

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString  isEqual: kTKPDMORE_HELP_URL]) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strURL = kTKPDMORE_HELP_URL;
        webViewController.strTitle = kTKPDMORE_HELP_TITLE;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

@end
