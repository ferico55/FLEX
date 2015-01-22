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

@interface TransactionCartResultViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_list;
    BOOL _isnodata;
    TransactionBuyResult *_cartBuy;
}
@property (weak, nonatomic) IBOutlet UIButton *confirmPaymentButton;
@property (weak, nonatomic) IBOutlet UILabel *listPaymentTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *tableTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (strong, nonatomic) IBOutlet UIView *viewConfirmPayment;

@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (strong, nonatomic) IBOutlet UIView *headerPaymentListView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation TransactionCartResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    
    _cartBuy = [_data objectForKey:DATA_CART_RESULT_KEY];
    [_list addObjectsFromArray:_cartBuy.system_bank];
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:14];
    
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
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_tableTitleLabel.text
                                                                               attributes:attributes];
    _tableTitleLabel.attributedText = attributedText;
    _confirmPaymentButton.layer.cornerRadius = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isnodata ? 1 : 1;
#else
    return _isnodata ? 0 : _list.count+1;
#endif
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef TRANSACTION_SHIPMENT_ISNODATA_ENABLE
    return _isnodata ? 1 : 1;
#else
    return _isnodata ? 0 : 1;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        if (indexPath.section == 0)
            cell = _totalPaymentCell;
        else if (indexPath.section <= _list.count)
            cell = [self cellPaymentAtIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = TRANSACTION_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = TRANSACTION_NODATACELLTITLE;
        cell.detailTextLabel.text = TRANSACTION_NODATACELLDESCS;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==1)return _headerPaymentListView;
    else return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == _list.count) {
        return _viewConfirmPayment;
    }
    else return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return _headerPaymentListView.frame.size.height;
    }
    else return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _totalPaymentCell.frame.size.height;
    }
    else if (indexPath.section <=_list.count)
    {
        return  120;
    }
    else
        return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == _list.count) {
        return _viewConfirmPayment.frame.size.height;
    }
    else return 20;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - methods Cell
-(UITableViewCell*)cellPaymentAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_CART_RESULT_CELL_IDENTIFIER;
    
    UITableViewCell *cell = (TransactionCartResultCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartResultCell newcell];
    }
    
    TransactionSystemBank *list = _list[indexPath.section-1];
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
        [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    return cell;
}

@end
