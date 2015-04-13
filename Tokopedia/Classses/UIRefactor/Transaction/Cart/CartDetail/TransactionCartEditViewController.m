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
@property (weak, nonatomic) IBOutlet UILabel *labelCounter;


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
    
    if ([_remarkTextView.text isEqualToString:@""]) {
        [_remarkTextView setPlaceholder:@"Tulis keterangan"];
    }
    
    [self setDefaultData:_data];
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

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_DONE:
            {
                ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
                product.product_notes = _remarkTextView.text;
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
        _quantityStepper.minimumValue= [product.product_min_order integerValue];
        _remarkTextView.text = product.product_notes;
        
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

#pragma mark - TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger counter = 144 - (textView.text.length + (text.length - range.length));
    _labelCounter.text = [NSString stringWithFormat:@"%zd",(counter<0)?0:counter];
    return textView.text.length + (text.length - range.length) <= 144;
}

@end
