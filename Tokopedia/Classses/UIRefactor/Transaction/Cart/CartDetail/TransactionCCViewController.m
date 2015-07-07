//
//  TransactionCCViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCCViewController.h"
#import "TransactionCCDetailViewController.h"
#import "RequestCart.h"
#import "string_transaction.h"

@interface TransactionCCViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableCells;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *postCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *provinceTextField;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation TransactionCCViewController
{
    UITextField *_activeTextField;
    UITextView *_activeTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableCells = [NSArray sortViewsWithTagInArray:_tableCells];
    
    self.title = @"Informasi Tagihan";
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Lanjut" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [_informationLabel setCustomAttributedText:_informationLabel.text];
    
    [self setTextFieldData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.backBarButtonItem = backBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableCells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = _tableCells[indexPath.row];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UITableViewCell*)_tableCells[indexPath.row]).frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
            [_firstNameTextField becomeFirstResponder];
            break;
        case 2:
            [_lastNameTextField becomeFirstResponder];
            break;
        case 3:
            [_phoneTextField becomeFirstResponder];
            break;
        case 4:
            [_postCodeTextField becomeFirstResponder];
            break;
        case 5:
            [_cityTextField becomeFirstResponder];
            break;
        case 6:
            [_provinceTextField becomeFirstResponder];
            break;
        case 7:
            [_addressTextView becomeFirstResponder];
            break;
        default:
            break;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextView = nil;
    _activeTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeTextField = nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeTextField = nil;
    _activeTextView = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _activeTextView = nil;
}

#pragma mark - Methods

-(void)setTextFieldData
{
    _firstNameTextField.text = _ccData.first_name?:@"";
    _lastNameTextField.text = _ccData.last_name?:@"";
    _phoneTextField.text = _ccData.phone?:@"";
    _postCodeTextField.text = _ccData.postal_code?:@"";
    _cityTextField.text = _ccData.city?:@"";
    _provinceTextField.text = _ccData.state?:@"";
    _addressTextView.text = _ccData.address?:@"";
}

-(IBAction)nextButton:(id)sender
{
    _activeTextField = nil;
    
    if ([self isValidInput]) {
        TransactionCCDetailViewController *vc = [TransactionCCDetailViewController new];
        vc.data = @{API_CC_FIRST_NAME_KEY :_firstNameTextField.text,
                     API_CC_LAST_NAME_KEY :_lastNameTextField.text,
                     API_CC_CITY_KEY :_cityTextField.text,
                     API_CC_POSTAL_CODE_KEY :_postCodeTextField.text,
                     API_CC_ADDRESS_KEY :_addressTextView.text,
                     API_CC_PHONE_KEY :_phoneTextField.text,
                     API_CC_STATE_KEY :_provinceTextField.text,
                    };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_firstNameTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Nama depan harus diisi."];
    }
    if ([_lastNameTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Nama belakang harus diisi."];
    }
    if ([_phoneTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Telepon harus diisi."];
    }
    if ([_postCodeTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Kode pos harus diisi."];
    }
    if ([_cityTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Kota harus diisi."];
    }
    if ([_provinceTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Provinsi harus diisi."];
    }
    if ([_addressTextView.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessage addObject:@"Alamat harus diisi."];
    }

    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValid;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableview.contentInset = contentInsets;
    _tableview.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _firstNameTextField) {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _lastNameTextField)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _phoneTextField)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _postCodeTextField)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _cityTextField)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _provinceTextField)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextView == _addressTextView)
    {
        [_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableview.contentInset = contentInsets;
                         _tableview.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
