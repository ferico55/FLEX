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

@interface TransactionCartEditViewController ()<UITextViewDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    UIBarButtonItem *_barButtonSave;
    UITextView *_activeTextView;
}

@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;


@end

@implementation TransactionCartEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
//    _barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
//    [_barButtonSave setTintColor:[UIColor blackColor]];
//    _barButtonSave.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
//    self.navigationItem.rightBarButtonItem = _barButtonSave;
    
    [self setDefaultData:_data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [_delegate shouldEditCartWithUserInfo:_dataInput];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_BACK:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case TAG_BAR_BUTTON_TRANSACTION_DONE:
                
                break;
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *stepper = (UIStepper*)sender;
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",(NSInteger)stepper.value];
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        product.product_quantity = _quantityLabel.text;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
}


#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextView = textView;
    
    return YES;
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _remarkTextView) {
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        product.product_notes = textView.text;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
    return YES;
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        [_dataInput addEntriesFromDictionary:_data];
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        _productNameLabel.text = product.product_name;
        _productPriceLabel.text = product.product_price_idr;
        _quantityStepper.value = [product.product_quantity integerValue];
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",(NSInteger)_quantityStepper.value];
        _quantityStepper.minimumValue= [product.product_min_order integerValue];
        _remarkTextView.text = product.product_notes;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = _productThumbImageView;
        thumb.image = nil;
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
}

@end
