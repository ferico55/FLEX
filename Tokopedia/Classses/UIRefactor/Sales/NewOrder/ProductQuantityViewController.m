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
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *explanationTextView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ProductQuantityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Terima Sebagian";
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    backBarButton.tag = 1;
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _tableView.contentInset = UIEdgeInsetsMake(22, 0, 0, 0);
    _tableView.tableFooterView = _footerView;
    
    _productQuantity = [NSMutableArray new];
    for (OrderProduct *product in _products) {
        [_productQuantity addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"order_detail_id"    : product.order_detail_id,
                                                                                    @"product_quantity"   : [NSString stringWithFormat:@"%ld", (long)product.product_quantity],
                                                                                    }]];
    }

    [_explanationTextView setText:@"Terima sebagian"];
    _explanationTextView.delegate = self;
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
    DetailProductViewController *controller = [DetailProductViewController new];
    controller.data = @{@"product_id":product.product_id};
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Text field method

- (void)textFieldDidChange:(UITextField *)textField
{
    [[_productQuantity objectAtIndex:textField.tag] setObject:textField.text forKey:@"product_quantity"];
}

#pragma mark - Text view delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [textView setPlaceholder:@"Keterangan"];
    }
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
    for (OrderProduct *product in _products) {
        for (NSDictionary *dict in _productQuantity) {
            if ([dict objectForKey:@"order_detail_id"] == product.order_detail_id) {
                if ([[dict objectForKey:@"product_quantity"] integerValue] > product.product_quantity) {
                    valid = NO;
                }
            }
        }
    }
    if (valid) {
        [self.delegate didUpdateProductQuantity:_productQuantity explanation:_explanationTextView.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSString *errorMessage = @"Anda memasukkan jumlah terlalu banyak";
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorMessage] delegate:self];
        [alert show];
    }
}

@end
