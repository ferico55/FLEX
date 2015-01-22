//
//  TransactionCartFormMandiriClickPayViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "TransactionCartFormMandiriClickPayViewController.h"

@interface TransactionCartFormMandiriClickPayViewController ()<UITextFieldDelegate>
{
    UITextField *_activeTextField;
    
    NSMutableDictionary *_dataInput;
}

@property (weak, nonatomic) IBOutlet UITextField *numberCreditCardTextField;
@property (strong, nonatomic) IBOutlet UITextField *tokenResponseTextField;
@property (weak, nonatomic) IBOutlet UILabel *stepsToGetTokenLabel;

@end

@implementation TransactionCartFormMandiriClickPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TITLE_FORM_MANDIRI_CLICK_PAY;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    _dataInput = [NSMutableDictionary new];
    //TODO::
    NSString *stepsToGetToken = @"Langkah-langkah mendapatkan token :\n1. Masukkan APPLI ke dalam token\n2. Masukkan 10 angka terakhir kartu ke dalam token\n3. Masukkan harga transaksi ke dalam token\n4. Masukkan nomor transaksi ke dalam token";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:stepsToGetToken];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_MEDIUM_12 range:[stepsToGetToken rangeOfString:@"Langkah-langkah mendapatkan token :"]];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_MEDIUM_12 range:[stepsToGetToken rangeOfString:@"APPLI"]];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_MEDIUM_12 range:[stepsToGetToken rangeOfString:@"10 angka terakhir"]];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_MEDIUM_12 range:[stepsToGetToken rangeOfString:@"harga transaksi"]];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_MEDIUM_12 range:[stepsToGetToken rangeOfString:@"nomor transaksi"]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,140)];

    _stepsToGetTokenLabel.attributedText = attributedString;
    
    [_dataInput addEntriesFromDictionary:[_data objectForKey:DATA_KEY]];
    NSString *mandiriToken = [_dataInput objectForKey:API_MANDIRI_TOKEN_KEY]?:@"";
    NSString *cardNumber = [_dataInput objectForKey:API_CARD_NUMBER_KEY]?:@"";
    
    _numberCreditCardTextField.text = cardNumber;
    _tokenResponseTextField.text = mandiriToken;
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
    [_activeTextField resignFirstResponder];
    _activeTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        if (textField == _numberCreditCardTextField) {
            [_dataInput setObject:textField.text forKey:API_CARD_NUMBER_KEY];
        }
        else
        {
            [_dataInput setObject:textField.text forKey:API_MANDIRI_TOKEN_KEY];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([_numberCreditCardTextField isFirstResponder]){
        
        [_tokenResponseTextField becomeFirstResponder];
    }
    else if ([_tokenResponseTextField isFirstResponder]){
        
        [_tokenResponseTextField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

@end
