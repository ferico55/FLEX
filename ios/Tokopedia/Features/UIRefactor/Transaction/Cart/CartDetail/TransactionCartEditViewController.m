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
#import "MMNumberKeyboard.h"
#import "Tokopedia-Swift.h"

@interface TransactionCartEditViewController ()<UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, MMNumberKeyboardDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    UIBarButtonItem *_barButtonSave;
    UITextView *_activeTextView;
    
    DelayedActionManager *quantityDelayedActionManager;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    CGSize _scrollviewContentSize;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet RSKPlaceholderTextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UILabel *labelCounter;
@property (strong, nonatomic) IBOutlet UIView *headerView;
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
    _barButtonSave.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = _barButtonSave;
    
    _scrollView.delegate = self;
    
    _remarkTextView.delegate = self;
    [self setDefaultData:_data];
    
    UIEdgeInsets inset = _remarkTextView.textContainerInset;
    inset.left = 15;
    _remarkTextView.textContainerInset = inset;
    
    quantityDelayedActionManager = [DelayedActionManager new];
    
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = NO;
    keyboard.delegate = self;
    _quantityTextField.inputView = keyboard;
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
- (IBAction)quantityStepperValueChanged:(UIStepper *)sender {
    NSInteger qty = [_quantityTextField.text integerValue];
    qty += (int)sender.value;
    
    //set min and max value
    qty = fmin([ProductDetail maximumPurchaseQuantity], qty);
    _quantityTextField.text = [NSString stringWithFormat: @"%d", (int)qty];
    
    [self alertAndResetIfQtyTextFieldBelowMin];
    
    sender.value = 0;
}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        [_dataInput addEntriesFromDictionary:_data];
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 6.0;
        
        NSDictionary *textAttributes = @{
                                        NSFontAttributeName            : [UIFont title2Theme],
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextView = nil;
}

- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text {
    NSString *amount = _quantityTextField.text;
    amount = [amount stringByAppendingString:text];
    
    __weak typeof(self) weakSelf = self;
    
    [quantityDelayedActionManager whenNotCalledFor:2
                                          doAction:^{
                                              [weakSelf alertAndResetIfQtyTextFieldBelowMin];
                                          }];
    
    return [amount isNumber] && [amount intValue] <= [ProductDetail maximumPurchaseQuantity];
}

-(void)alertAndResetIfQtyTextFieldBelowMin
{
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    
    if ([_quantityTextField.text integerValue] <[product.product_min_order integerValue]) {
        _quantityTextField.text = product.product_min_order;
        
        NSArray *errorMessages = @[[NSString stringWithFormat: @"%@%@%@", @"Minimum pembelian adalah ", product.product_min_order, @" barang"]];
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
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

@end
