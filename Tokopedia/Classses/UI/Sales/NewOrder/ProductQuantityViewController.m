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

@interface ProductQuantityViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate
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

    self.title = @"Konfirmasi";
    
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
    
    return cell;
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
        if (button.tag == 2) {
            [self.delegate didUpdateProductQuantity:_productQuantity explanation:_explanationTextView.text];            
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
