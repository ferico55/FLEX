//
//  ChooseProductViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ChooseProductViewController.h"
#import "ChooseProductCell.h"
#import "OrderProduct.h"

@interface ChooseProductViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_selectedProducts;
    NSInteger _numberOfSelectedProduct;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;

@end

@implementation ChooseProductViewController

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
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    _selectedProducts = [[NSMutableArray alloc] initWithArray:_products];
    _numberOfSelectedProduct = _selectedProducts.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tabel data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_products count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    label.text = @"Pilihlah barang yang tidak memiliki persediaan";
    label.font = [UIFont fontWithName:@"GothamBook" size:13];
    label.textColor = [UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;

    [view addSubview:label];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"ChooseProductCell";
    ChooseProductCell *cell = (ChooseProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
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
    } failure:nil];
    
    if ([[_selectedProducts objectAtIndex:indexPath.row] isEqual:[NSNull null]]) {
        cell.checkBoxImageView.image = nil;
        cell.checkBoxImageView.layer.borderWidth = 1;
    } else {
        cell.checkBoxImageView.image = [UIImage imageNamed:@"icon_checkmark.png"];
        cell.checkBoxImageView.layer.borderWidth = 0;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChooseProductCell *cell = (ChooseProductCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([[_selectedProducts objectAtIndex:indexPath.row] isEqual:[NSNull null]]) {
        cell.checkBoxImageView.image = [UIImage imageNamed:@"icon_checkmark.png"];
        cell.checkBoxImageView.layer.borderWidth = 0;
        [_selectedProducts replaceObjectAtIndex:indexPath.row withObject:[_products objectAtIndex:indexPath.row]];
        _numberOfSelectedProduct++;
    } else {
        cell.checkBoxImageView.image = nil;
        cell.checkBoxImageView.layer.borderWidth = 1;
        [_selectedProducts replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
        _numberOfSelectedProduct--;
    }
    
    if (_numberOfSelectedProduct == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            if (_numberOfSelectedProduct > 0) {
                [self.delegate didSelectProducts:_selectedProducts];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if ([button.titleLabel.text isEqualToString:@"Select All"]) {
            [button setTitle:@"Deselect All" forState:UIControlStateNormal];
            _selectedProducts = [NSMutableArray arrayWithArray:_products];
            _numberOfSelectedProduct = _selectedProducts.count;
        } else {
            [button setTitle:@"Select All" forState:UIControlStateNormal];
            for (int i = 0; i < _selectedProducts.count; i++) {
                [_selectedProducts replaceObjectAtIndex:i withObject:[NSNull null]];
                _numberOfSelectedProduct = 0;
            }
        }
        [self.tableView reloadData];
    }
}

@end
