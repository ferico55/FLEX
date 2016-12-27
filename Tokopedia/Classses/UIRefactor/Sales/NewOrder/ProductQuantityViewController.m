//
//  ProductQuantityViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductQuantityViewController.h"
#import "ProductQuantityCell.h"
#import "OrderProduct.h"
#import "UITextView+UITextView_Placeholder.h"
#import "DetailProductViewController.h"
#import "NavigateViewController.h"
#import "ActionOrder.h"
#import "Tokopedia-Swift.h"

@interface ProductQuantityViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    UIAlertViewDelegate
>
{
    NSMutableArray *_productQuantity;
    NavigateViewController *_TKPDNavigator;
    NSMutableArray *_originQuantity;
    NSMutableArray *_updateQuantity;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet RSKPlaceholderTextView *explanationTextView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ProductQuantityViewController{
    UIBarButtonItem *_doneButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Terima Sebagian";

    _TKPDNavigator = [NavigateViewController new];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;

    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    _doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = _doneButton;
    
    _tableView.contentInset = UIEdgeInsetsMake(22, 0, 0, 0);
    _tableView.tableFooterView = _footerView;
    
    _originQuantity = [NSMutableArray new];
    _updateQuantity = [NSMutableArray new];
    _productQuantity = [NSMutableArray new];
    for (OrderProduct *product in _products) {
        NSString *quantity = [NSString stringWithFormat:@"%ld", (long)product.product_quantity];
        [_originQuantity addObject:quantity];
        [_updateQuantity addObject:quantity];
        [_productQuantity addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"order_detail_id"    : product.order_detail_id,
                                                                                    @"product_quantity"   : quantity,
                                                                                    }]];
    }

    [_explanationTextView setText:@"Terima sebagian"];
    [_explanationTextView setPlaceholder:@"Tulis Keterangan"];
    _explanationTextView.delegate = self;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"ProductQuantityCell";
    ProductQuantityCell *cell = (ProductQuantityCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    OrderProduct *product = [_products objectAtIndex:indexPath.row];
    
    cell.productNameLabel.text = product.product_name;
    
    cell.productPriceLabel.text = product.product_price;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_picture]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [cell.productImageView setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              [cell.productImageView setImage:image];
                                              [cell.productImageView setContentMode:UIViewContentModeScaleAspectFill];
                                          } failure:nil];
    
    cell.productQuantityTextField.text = [[_productQuantity objectAtIndex:indexPath.row] objectForKey:@"product_quantity"];
    cell.productQuantityTextField.tag = indexPath.row;
    [cell.productQuantityTextField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderProduct *product = [_products objectAtIndex:indexPath.row];
    [_TKPDNavigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_picture withShopName:nil];
}

#pragma mark - Text field method

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint point = textField.frame.origin;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [[_productQuantity objectAtIndex:textField.tag] setObject:textField.text forKey:@"product_quantity"];
    [_updateQuantity replaceObjectAtIndex:textField.tag withObject:textField.text];
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *title = @"Konfirmasi Pemrosesan Barang";
            NSString *message = @"Apakah Anda yakin ingin menerima pesanan ini?\nUntuk penerimaan pesanan sebagian, produk dengan harga bersifat grosir tetap menggunakan harga produk yang tertulis di invoice";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Ok", nil];
            alertView.delegate = self;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self validateProductQuantity];
    }
}

- (void)validateProductQuantity {
    BOOL valid = YES;
    NSString *errorMessage;
    for (OrderProduct *product in _products) {
        for (NSDictionary *dict in _productQuantity) {
            if ([dict objectForKey:@"order_detail_id"] == product.order_detail_id) {
                if ([[dict objectForKey:@"product_quantity"] integerValue] == 0) {
                    valid = NO;
                    errorMessage = @"Jumlah barang yang akan dikirim harus diisi";
                }
                if ([[dict objectForKey:@"product_quantity"] integerValue] > product.product_quantity) {
                    valid = NO;
                    errorMessage = @"Anda memasukkan jumlah terlalu banyak";
                }
            }
        }
    }
    if ([_explanationTextView.text isEqualToString:@""]) {
        valid = NO;
        errorMessage = @"Keterangan harus diisi";
    }
    if ([_originQuantity isEqualToArray:_updateQuantity]) {
        valid = NO;
        errorMessage = @"Silahkan menggunakan pilihan 'Terima Pesanan' apabila Anda menerima semua barang.";
    }
    if (valid) {
        [self requestAcceptPartial];
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorMessage] delegate:self];
        [alert show];
    }
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSValue *keyboardFrameBegin = [[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(22, 0, keyboardFrameBeginRect.size.height + 15, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.tableView.contentInset = UIEdgeInsetsMake(22, 0, 0, 0);
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
    });
}

- (void)scrollToBottom {
    CGRect rect = [self.tableView convertRect:self.tableView.tableFooterView.bounds
                                     fromView:self.tableView.tableFooterView];
    [self.tableView scrollRectToVisible:rect animated:YES];
}

- (void)requestAcceptPartial{
    
    [_doneButton setEnabled:false];
    
    __weak typeof(self) wself = self;
    [RequestSales fetchAcceptOrderPartial:_products
                        productQuantities:_productQuantity
                                  orderID:_orderID
                             shippingLeft:_shippingLeft
                                   reason:_explanationTextView.text?:@""
                                onSuccess:^() {
                                    
                                    if (wself.didAcceptOrder) {
                                        wself.didAcceptOrder();
                                    }
                                    [wself dismissViewControllerAnimated:YES completion:nil];
                                    
                                } onFailure:^() {
                                    [_doneButton setEnabled:YES];
                                }];
}

@end
