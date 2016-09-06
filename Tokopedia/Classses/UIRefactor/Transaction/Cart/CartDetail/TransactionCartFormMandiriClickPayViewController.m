//
//  TransactionCartFormMandiriClickPayViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "TransactionSummaryDetail.h"
#import "TransactionCartFormMandiriClickPayViewController.h"

@interface TransactionCartFormMandiriClickPayViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UITextField *_activeTextField;
    NSMutableDictionary *_dataInput;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *numberCreditCardTextField;
@property (strong, nonatomic) IBOutlet UITextField *tokenResponseTextField;
@property (weak, nonatomic) IBOutlet UILabel *stepsToGetTokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *getTokenApplyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNumberDebitCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UILabel *step4Label;
@property (strong, nonatomic) IBOutlet UIView *section1HeaderView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1CellCollection;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2CellCollection;


@end

@implementation TransactionCartFormMandiriClickPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TITLE_FORM_MANDIRI_CLICK_PAY;
    
    _section1CellCollection = [NSArray sortViewsWithTagInArray:_section1CellCollection];
    _section2CellCollection = [NSArray sortViewsWithTagInArray:_section2CellCollection];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _dataInput = [NSMutableDictionary new];
    //TODO::
    NSString *stepsToGetToken1 = @"Masukkan APPLI ke dalam token";
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc]  initWithString:stepsToGetToken1];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont microTheme] range:[stepsToGetToken1 rangeOfString:@"APPLI"]];
    NSString *stepsToGetToken2 = @"Masukkan 10 angka terakhir kartu ke dalam token";
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc]  initWithString:stepsToGetToken2];
    [attributedString2 addAttribute:NSFontAttributeName value:[UIFont microTheme] range:[stepsToGetToken2 rangeOfString:@"10 angka terakhir"]];
    NSString *stepsToGetToken3 = @"Masukkan harga transaksi ke dalam token";
    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc]  initWithString:stepsToGetToken3];
    [attributedString3 addAttribute:NSFontAttributeName value:[UIFont microTheme] range:[stepsToGetToken3 rangeOfString:@"harga transaksi"]];
    NSString *stepsToGetToken4 = @"Masukkan nomor transaksi ke dalam token";
    NSMutableAttributedString *attributedString4 = [[NSMutableAttributedString alloc]  initWithString:stepsToGetToken4];
    [attributedString4 addAttribute:NSFontAttributeName value:[UIFont microTheme] range:[stepsToGetToken4 rangeOfString:@"nomor transaksi"]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,10)];
    [attributedString2 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,10)];
    [attributedString3 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,10)];
    [attributedString4 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,10)];

    _step1Label.attributedText = attributedString1;
    _step2Label.attributedText = attributedString2;
    _step3Label.attributedText = attributedString3;
    _step4Label.attributedText = attributedString4;
    
    [_dataInput addEntriesFromDictionary:[_data objectForKey:DATA_KEY]];
    //NSString *mandiriToken = [_dataInput objectForKey:API_MANDIRI_TOKEN_KEY]?:@"";
    //NSString *cardNumber = [_dataInput objectForKey:API_CARD_NUMBER_KEY]?:@"";
    
    TransactionSummaryDetail *cart = [_data objectForKey:DATA_CART_SUMMARY_KEY];
    
    //_numberCreditCardTextField.text = cardNumber;
    //_tokenResponseTextField.text = mandiriToken;
    
    NSString *price = cart.payment_left;
    _priceLabel.text = price;
    
    NSString *transactionNumber = cart.payment_id;
    _transactionNumberLabel.text = transactionNumber;
    
    if (_numberCreditCardTextField.text.length==16) {
        _lastNumberDebitCardLabel.text = [_numberCreditCardTextField.text substringFromIndex:_numberCreditCardTextField.text.length - 10];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_dataInput removeObjectForKey:API_MANDIRI_TOKEN_KEY];
    [_dataInput removeObjectForKey:API_CARD_NUMBER_KEY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == TAG_BAR_BUTTON_TRANSACTION_BACK) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSDictionary *userInfo = _dataInput;
            [_delegate TransactionCartMandiriClickPayForm:self withUserInfo:userInfo];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        if (textField == _numberCreditCardTextField) {
        _lastNumberDebitCardLabel.text = [_numberCreditCardTextField.text substringFromIndex:_numberCreditCardTextField.text.length - 10];
            [_dataInput setObject:textField.text forKey:API_CARD_NUMBER_KEY];
        }
        else
        {
            [_dataInput setObject:textField.text forKey:API_MANDIRI_TOKEN_KEY];
        }
    }
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _numberCreditCardTextField) {
        if (range.location==15) {
            NSString *stringText = [NSString stringWithFormat:@"%@%@",textField.text,string];
            _lastNumberDebitCardLabel.text = [stringText substringFromIndex: [textField.text length] - 9];
        }
        else if(range.location==16)
            return NO;
        else _lastNumberDebitCardLabel.text = @"";
    }
    return YES;
}


#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section == 0)?_section1CellCollection.count:_section2CellCollection.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    cell = (indexPath.section == 0)?_section1CellCollection[indexPath.row]:_section2CellCollection[indexPath.row];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return _section1HeaderView.frame.size.height;
    }
    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return _section1HeaderView;
    }
    else return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0)?((UITableViewCell*)[_section1CellCollection firstObject]).frame.size.height:((UITableViewCell*)[_section2CellCollection firstObject]).frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row == 0)
            [_numberCreditCardTextField becomeFirstResponder];
        else
            [_tokenResponseTextField becomeFirstResponder];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
}
@end
