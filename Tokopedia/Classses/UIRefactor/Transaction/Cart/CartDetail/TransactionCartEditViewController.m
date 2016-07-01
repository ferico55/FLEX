//
//  TransactionCartEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "string_product.h"
#import "detail.h"
#import "ProductDetail.h"
#import "TransactionAction.h"
#import "TransactionCartEditViewController.h"

@interface TransactionCartEditViewController ()<UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    UIBarButtonItem *_barButtonSave;
    UITextView *_activeTextView;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    CGSize _scrollviewContentSize;
}

@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UILabel *labelCounter;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintTextView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borders;

@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;

@end

@implementation TransactionCartEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(tap:)];
    [_barButtonSave setTintColor:[UIColor whiteColor]];
    _barButtonSave.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = _barButtonSave;
    
    _remarkTextView.delegate = self;
    [self setDefaultData:_data];
    [self setTextViewPlaceholder:@"Contoh: Warna Putih/Ukuran XL/Edisi ke-2"];
    
    [_remarkTextView becomeFirstResponder];
    
    UIEdgeInsets inset = _remarkTextView.textContainerInset;
    inset.left = 15;
    _remarkTextView.textContainerInset = inset;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Ubah Pesanan";
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    self.title = nil;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    [_quantityTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_DONE:
            {
                ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
                product.product_notes = _remarkTextView.text;
                [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
                product.product_quantity = _quantityTextField.text;
                [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
                [_delegate shouldEditCartWithUserInfo:_dataInput];
            }
            break;
            default:
                break;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *stepper = (UIStepper*)sender;
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",(NSInteger)stepper.value];
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        product.product_quantity = _quantityLabel.text;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
}


#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        [_dataInput addEntriesFromDictionary:_data];
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8.0;
        
        NSDictionary *textAttributes = @{
                                        NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                        NSParagraphStyleAttributeName  : style,
                                        NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                        };

        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:product.product_name
                                                                             attributes:textAttributes];
        _productNameLabel.attributedText = attributedText;
        _productPriceLabel.text = product.product_price_idr;
        _quantityStepper.value = [product.product_quantity integerValue];
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",(NSInteger)_quantityStepper.value];
        _quantityTextField.text = product.product_quantity;
        _quantityStepper.minimumValue= [product.product_min_order integerValue];
        _remarkTextView.text = product.product_notes;
        NSInteger counter = 144 - _remarkTextView.text.length;
        _labelCounter.text = [NSString stringWithFormat:@"%zd",(counter<0)?0:counter];
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = _productThumbImageView;
        thumb.image = nil;
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
#pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [_quantityTextField resignFirstResponder];
//    [_activeTextView resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];

    if ([_quantityTextField.text integerValue] < 1)
        _quantityTextField.text = product.product_min_order;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextView = nil;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)string
{
    NSString* newText;
    
    newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return [newText isNumber] && [newText intValue] < 1000;
}

#pragma mark - TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [_quantityTextField resignFirstResponder];
    _activeTextView = textView;
}

- (void)setTextViewPlaceholder:(NSString *)placeholderText
{
    UIEdgeInsets inset = _remarkTextView.textContainerInset;
    inset.left = 20;
    inset.top = _headerView.frame.size.height-12;
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset.left, 0, _remarkTextView.frame.size.width, 40)];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = [UIFont fontWithName:_remarkTextView.font.fontName size:_remarkTextView.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    placeholderLabel.hidden = (![_remarkTextView.text isEqualToString:@""] && _remarkTextView.text != nil);
    [_remarkTextView addSubview:placeholderLabel];
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger counter = 144 - (textView.text.length + (text.length - range.length));
    _labelCounter.text = [NSString stringWithFormat:@"%zd",(counter<0)?0:counter];
    return textView.text.length + (text.length - range.length) <= 144;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    _keyboardSize= [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    
    UIEdgeInsets inset = _remarkTextView.textContainerInset;
    inset.bottom = _keyboardSize.height;
    _remarkTextView.textContainerInset = inset;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    UIEdgeInsets inset = _remarkTextView.contentInset;
    inset.bottom = 0;
    inset.top = 0;
    [_remarkTextView setContentInset:inset];
    _bottomConstraintTextView.constant = 0;    
}


@end
