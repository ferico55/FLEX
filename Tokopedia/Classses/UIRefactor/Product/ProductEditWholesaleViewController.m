//
//  ProductEditWholesaleViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#pragma mark - Product Edit Wholesale View Controller

#import "ProductEditWholesaleViewController.h"
#import "ProductEditWholesaleCell.h"
#import "NSNumberFormatter+IDRFormater.h"

#import "Tokopedia-Swift.h"

#define PRICE_CURRENCY_ID_RUPIAH 1
#define MINIMUM_PRICE_RUPIAH 100
#define MAXIMUM_PRICE_RUPIAH 50000000

#define PRICE_CURRENCY_ID_USD 2
#define MINIMUM_PRICE_USD 1
#define MAXIMUM_PRICE_USD 4000

@interface ProductEditWholesaleViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

- (IBAction)tap:(id)sender;

@end

@implementation ProductEditWholesaleViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Harga Grosir";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [self setHeaderAppearance];
    if(_form.wholesale_price.count == 0)[self addWholesalePrice:@"" withQtyMin:@"" andQtyMax:@""];
}

-(void)setHeaderAppearance{
    CGFloat priceInteger = [_form.product.product_price floatValue];
    
    if ([_form.product.product_currency_id integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
        self.productPriceLabel.text = [[NSNumberFormatter IDRFormarterWithoutCurency] stringFromNumber:@(priceInteger)];
        self.currencyLabel.text = @"Rp";
    } else {
        self.productPriceLabel.text = [[NSNumberFormatter USDFormarter] stringFromNumber:@(priceInteger)];
        self.currencyLabel.text = @"US$";
    }
    _table.tableHeaderView = _headerView;
}

#pragma mark - View Gesture
- (IBAction)tap:(id)sender {

    if ([self isValidMaxWholesaleList] && [self isValidQuantityValue] && [self isValidWholesalePriceCompareNet] && [self isValidWholesalePrice]) {
        [self addWholesalePrice:@"" withQtyMin:@"" andQtyMax:@""];
        [_table reloadData];
        
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_form.wholesale_price.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)addWholesalePrice:(NSString*)price withQtyMin:(NSString*)min andQtyMax:(NSString*)max{
    WholesalePrice *wholesale = [WholesalePrice new];
    wholesale.wholesale_price = price;
    wholesale.wholesale_max = max;
    wholesale.wholesale_min = min;
    
    NSMutableArray *wholesales = [[NSMutableArray alloc]initWithArray:_form.wholesale_price];
    [wholesales addObject:wholesale];
    _form.wholesale_price = [wholesales copy];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _form.wholesale_price.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellid = PRODUCT_EDIT_WHOLESALE_CELL_IDENTIFIER;
    
    ProductEditWholesaleCell *cell = (ProductEditWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [ProductEditWholesaleCell newcell];
    }

    WholesalePrice *wholesale = _form.wholesale_price[indexPath.row];
    cell.wholesale = wholesale;
    cell.productPriceCurency = _form.product.product_currency_id;
    cell.deleteWholesaleButton.hidden = (indexPath.row == 0);
    
    __weak typeof(self) wself = self;
    __block ProductEditWholesaleCell *cellWholesale = cell;
    [cell setRemoveWholesale:^(WholesalePrice *wholesale) {
        [wself removeCell:cellWholesale atIndexPath:indexPath];
    }];
    
    [cell setEditWholesale:^(WholesalePrice *wholesale) {
        
    }];

    return cell;

}
-(void)removeCell:(ProductEditWholesaleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *wholesaleList = [[NSMutableArray alloc]initWithArray:_form.wholesale_price];

    NSMutableArray *deletedIndexPath = [NSMutableArray new];
    for (NSInteger i=_form.wholesale_price.count-1; i>=indexPath.row; i--) {
        [deletedIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [wholesaleList removeObject:_form.wholesale_price[i]];
    }
    _form.wholesale_price = [wholesaleList copy];
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:deletedIndexPath
                  withRowAnimation:UITableViewRowAnimationLeft];
    [_table endUpdates];
    [_table reloadData];
    
}

#pragma mark - Methods
-(void)setAppearance
{
    ProductEditDetail *product = _form.product;
    NSString *priceCurrencyID = product.product_currency_id;
    NSString *productPricePerProduct = product.product_price;

    CGFloat priceInteger = [productPricePerProduct floatValue];
    if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
        _productPriceLabel.text = (priceInteger>0)?[[NSNumberFormatter IDRFormarterWithoutCurency] stringFromNumber:@(priceInteger)]:@"";
        _currencyLabel.text = @"Rp";
    } else {
        _productPriceLabel.text = [[NSNumberFormatter USDFormarter] stringFromNumber:@(priceInteger)];
        _currencyLabel.text = @"US$";
    }

}

-(BOOL)isValidMaxWholesaleList
{
    if (_form.wholesale_price.count>=5) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Hanya boleh menambahkan 5 harga grosir"] delegate:self];
        [alert show];
        return NO;
    }
    return YES;
}

-(BOOL)isValidWholesalePriceCompareNet
{
    BOOL isValidWholesalePriceCompareNet = YES;
    
    if (_form.wholesale_price.count==0) {
        return isValidWholesalePriceCompareNet;
    }
    
    for (WholesalePrice *wholesale in _form.wholesale_price) {
        if ([wholesale.wholesale_price floatValue] >= [_form.product.product_price floatValue]) {
            isValidWholesalePriceCompareNet = NO;
            break;
        }
    }

    if (!isValidWholesalePriceCompareNet) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Harga grosir harus lebih murah dari harga pas"] delegate:self];
        [alert show];
    }
    
    return isValidWholesalePriceCompareNet;
}

-(BOOL)isValidQuantityValue
{
    BOOL isValidQuantityValue = YES;
    
    if (_form.wholesale_price.count==0) {
        return isValidQuantityValue;
    }
    
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    for (int i = 1; i<_form.wholesale_price.count; i++) {
        WholesalePrice *wholesale = _form.wholesale_price[i];
        NSInteger wholesaleMinQty = [wholesale.wholesale_min integerValue];
        NSInteger wholesaleMaxQty = [wholesale.wholesale_max integerValue];
        
        
        ProductEditDetail *product = _form.product;
        NSInteger minimumOrder = [ product.product_min_order integerValue]?:1;
        
        WholesalePrice *previousWholesale = _form.wholesale_price[i-1];
        NSInteger wholesaleMinQtyPrevious = [previousWholesale.wholesale_min integerValue];
        NSInteger wholesaleMaxQtyPrevious = [previousWholesale.wholesale_max integerValue];
        
        if (wholesaleMaxQty<=0) {
            isValidQuantityValue = NO;
            [errorMessage addObject:@"Jumlah maksimum harus diisi"];
        }
        if (wholesaleMinQty<=0) {
            isValidQuantityValue = NO;
            [errorMessage addObject:@"Jumlah minimum harus diisi"];
        }
        if (wholesaleMaxQty <= wholesaleMinQty){
            isValidQuantityValue = NO;
            [errorMessage addObject:@"Jumlah maksimum harus lebih besar dari jumlah minimum"];
        }
        if (wholesaleMinQty<=minimumOrder) {
            isValidQuantityValue = NO;
            [errorMessage addObject:@"Jumlah barang grosir harus lebih besar dari minimum pemesanan"];
        }
        
        if (wholesaleMaxQty < wholesaleMaxQtyPrevious || wholesaleMinQty < wholesaleMinQtyPrevious) {
            isValidQuantityValue = NO;
            [errorMessage addObject:@"Total produk tidak valid"];
        }
    }
    
    if (!isValidQuantityValue) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValidQuantityValue;
}

-(BOOL)isValidWholesalePrice
{
    BOOL isValidPrice = YES;
    
    if (_form.wholesale_price.count==0) {
        return isValidPrice;
    }
    
    NSString *errorMessage = @"";
    NSInteger wholesaleListIndex = _form.wholesale_price.count-1;
    
    WholesalePrice *wholesale = _form.wholesale_price[wholesaleListIndex];
    if (wholesaleListIndex < 0) {
        wholesaleListIndex = 0;
    }
    float wholesalePrice = [wholesale.wholesale_price floatValue];
    
    NSInteger productPriceCurrencyID = [_form.product.product_currency_id integerValue];
    
    if (!(wholesalePrice > 0)) {
        errorMessage = @"Harga harus diisi";
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_RUPIAH &&
             (wholesalePrice<MINIMUM_PRICE_RUPIAH || wholesalePrice>MAXIMUM_PRICE_RUPIAH)) {
        errorMessage = @"Rentang Harga 100 - 50000000";
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_USD && (wholesalePrice<MINIMUM_PRICE_USD || wholesalePrice>MAXIMUM_PRICE_USD)) {
        errorMessage = @"Rentang Harga 1 - 4000";
        isValidPrice = NO;
    }
    else if (_form.wholesale_price.count>=2) {
        WholesalePrice *wholesalePrevious = _form.wholesale_price[wholesaleListIndex-1];
        float wholesalePricePrevious = [wholesalePrevious.wholesale_price floatValue];
        
        if (wholesalePrice >= wholesalePricePrevious) {
            isValidPrice = NO;
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Harga harus lebih murah dari harga grosir sebelumnya"] delegate:self];
            [alert show];
            return isValidPrice;
        }
    }
    
    if (!isValidPrice) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[errorMessage] delegate:self];
        [alert show];
    }
    
    return isValidPrice;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.table.contentInset = contentInsets;
    self.table.scrollIndicatorInsets = contentInsets;
    
    [self.table scrollToRowAtIndexPath:[_table indexPathForCell:[self firstResponderCell]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(UITableViewCell *)firstResponderCell{
    NSArray *subviews = [self.table subviews];
    
    for (id cell in subviews )
    {
        if ([cell isKindOfClass:[UITableViewCell class]])
        {
            UITableViewCell *aCell = cell;
            NSArray *cellContentViews = [[aCell contentView] subviews];
            for (id textField in cellContentViews)
            {
                if ([textField isKindOfClass:[UITextField class]])
                {
                    UITextField *theTextField = textField;
                    if ([theTextField isFirstResponder]) {
                        return cell;
                    }
                    
                }
            }
            
        }
    }
    return nil;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [UIView animateWithDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^(void)
     {
         self.table.contentInset = UIEdgeInsetsZero;
         self.table.scrollIndicatorInsets = UIEdgeInsetsZero;
     }];
}
@end
