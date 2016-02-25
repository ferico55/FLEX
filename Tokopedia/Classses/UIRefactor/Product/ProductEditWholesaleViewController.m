//
//  ProductEditWholesaleViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#pragma mark - Product Edit Wholesale View Controller

#import "detail.h"
#import "string_product.h"
#import "ProductEditWholesaleViewController.h"
#import "ProductEditWholesaleCell.h"
#import "ProductDetail.h"
#import "StickyAlertView.h"

@interface ProductEditWholesaleViewController ()<UITableViewDataSource,UITableViewDelegate,ProductEditWholesaleCellDelegate>
{
    BOOL _isnodata;
    NSMutableArray *_wholesaleList;
    NSMutableDictionary *_dataInput;
    
    UITextField *_activeTextField;
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSNumberFormatter *_USDCurrencyFormatter;
    NSNumberFormatter *_RPCurrencyFormatter;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation ProductEditWholesaleViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Harga Grosir";
    
    _dataInput = [NSMutableDictionary new];
    _wholesaleList = [NSMutableArray new];
    
    _USDCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [_USDCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_USDCurrencyFormatter setCurrencyCode:@"USD"];
    [_USDCurrencyFormatter setNegativeFormat:@"-¤#,##0.00"];
    
    _RPCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [_RPCurrencyFormatter setGroupingSeparator:@","];
    [_RPCurrencyFormatter setGroupingSize:3];
    [_RPCurrencyFormatter setUsesGroupingSeparator:YES];
    [_RPCurrencyFormatter setSecondaryGroupingSize:3];
    
    _table.tableHeaderView = _headerView;
    [self setDefaultData:_data];
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [saveBarButtonItem setTintColor:[UIColor whiteColor]];
    saveBarButtonItem.tag = BARBUTTON_PRODUCT_SAVE;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [cancelBarButtonItem setTintColor:[UIColor whiteColor]];
    cancelBarButtonItem.tag = BARBUTTON_PRODUCT_BACK;
    self.navigationItem.backBarButtonItem = cancelBarButtonItem;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    
    
}

#pragma mark - View Gesture
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_PRODUCT_ADD_WHOLESALE:
                if ([self isValidMaxWholesaleList] && [self isValidQuantityValue] && [self isValidWholesalePriceCompareNet] && [self isValidWholesalePrice]) {
                    [self addWholesaleListPrice:0 withQuantityMinimum:0 andQuantityMaximum:0];
                    [_table reloadData];
                    
                    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_wholesaleList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                break;
                
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem*)sender;
        switch (barButton.tag) {
            case BARBUTTON_PRODUCT_BACK:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case BARBUTTON_PRODUCT_SAVE:
            {
                if (_wholesaleList.count==0 || [[_wholesaleList[0] objectForKey:@"prd_prc_1"] floatValue]==0) {
                    [_delegate ProductEditWholesaleViewController:self withWholesaleList:_wholesaleList];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    if ([self isValidQuantityValue] && [self isValidWholesalePriceCompareNet] && [self isValidWholesalePrice]) {
                        [_delegate ProductEditWholesaleViewController:self withWholesaleList:_wholesaleList];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activeTextField resignFirstResponder];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_wholesaleList.count;
#else
    return _isnodata?0:_wholesaleList.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = PRODUCT_EDIT_WHOLESALE_CELL_IDENTIFIER;
        
        cell = (ProductEditWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ProductEditWholesaleCell newcell];
            ((ProductEditWholesaleCell*)cell).delegate = self;
        }
        
        if (_wholesaleList.count > indexPath.row) {
            NSInteger wholesaleListIndex = indexPath.row+1;
            NSDictionary *wholesale = _wholesaleList[indexPath.row];
            NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndex];
            NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,wholesaleListIndex];
            NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,wholesaleListIndex];
            
            CGFloat priceInteger = [[wholesale objectForKey:wholesalePriceKey] floatValue];

            NSString *wholesalePrice = (priceInteger>0)?[_RPCurrencyFormatter stringFromNumber:@(priceInteger)]:@"";
            ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
            NSString *priceCurrencyID = product.product_currency_id;
            
            if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
                wholesalePrice = [_RPCurrencyFormatter stringFromNumber:@(priceInteger)];
            }
            else
            {
                wholesalePrice = [_USDCurrencyFormatter stringFromNumber:@(priceInteger)];
            }
            
            NSInteger wholesaleMinQty = [[wholesale objectForKey:wholesaleQuantityMinimum]integerValue];
            NSInteger wholesaleMaxQty = [[wholesale objectForKey:wholesaleQuantityMaximum]integerValue];
            ((ProductEditWholesaleCell*)cell).productPriceTextField.text = ([wholesalePrice isEqualToString:@"0"])?@"":wholesalePrice;            
            ((ProductEditWholesaleCell*)cell).minimumProductTextField.text = (wholesaleMinQty==0)?@"":[NSString stringWithFormat:@"%zd",wholesaleMinQty];
            ((ProductEditWholesaleCell*)cell).maximumProductTextField.text = (wholesaleMaxQty==0)?@"":[NSString stringWithFormat:@"%zd",wholesaleMaxQty];
            ((ProductEditWholesaleCell*)cell).indexPath = indexPath;
            ((ProductEditWholesaleCell*)cell).product = product;
            //((ProductEditWholesaleCell*)cell).deleteWholesaleButton.hidden = (indexPath.row==0);
            
            NSInteger priceCurencyID = [product.product_currency_id integerValue]?:1;
            if (priceCurencyID == PRICE_CURRENCY_ID_RUPIAH)
                ((ProductEditWholesaleCell*)cell).productCurrencyLabel.text = @"Rp";
            else if (priceCurencyID == PRICE_CURRENCY_ID_USD)
                ((ProductEditWholesaleCell*)cell).productCurrencyLabel.text = @"US$";
            if (indexPath.row == 0 && _wholesaleList.count>0) {
                NSInteger priceInteger = [[wholesale objectForKey:wholesalePriceKey] integerValue];
                NSInteger wholesaleMinQty = [[wholesale objectForKey:wholesaleQuantityMinimum]integerValue];
                NSInteger wholesaleMaxQty = [[wholesale objectForKey:wholesaleQuantityMaximum]integerValue];
                if (priceInteger != 0 && wholesaleMaxQty !=0 && wholesaleMinQty != 0) {
                    ((ProductEditWholesaleCell*)cell).deleteWholesaleButton.hidden = NO;
                }
                else
                {
                    ((ProductEditWholesaleCell*)cell).deleteWholesaleButton.hidden = YES;
                }
            }
        }
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}


#pragma mark - Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        //if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
        //    /** called if need to load next page **/
        //    //NSLog(@"%@", NSStringFromSelector(_cmd));
        //    [self configureRestKit];
        //    [self request];
        //}
    }
}

#pragma mark - Cell Delegate
-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell *)cell textFieldShouldBeginEditing:(UITextField *)textField withIndexPath:(NSIndexPath *)indexPath
{
    _activeTextField = textField;
}

-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell *)cell textFieldShouldReturn:(UITextField *)textField withIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell *)cell textFieldShouldEndEditing:(UITextField *)textField withIndexPath:(NSIndexPath *)indexPath
{
    UITextField *wholesalePriceTextFiled = ((ProductEditWholesaleCell *)cell).productPriceTextField;
    UITextField *wholesaleMinimumQuantityTextFiled = ((ProductEditWholesaleCell *)cell).minimumProductTextField;
    UITextField *wholesaleMaximumQuantityTextFiled = ((ProductEditWholesaleCell *)cell).maximumProductTextField;
    
    if (indexPath.row<_wholesaleList.count) {
        NSInteger wholesaleListIndex = indexPath.row+1;
        NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndex];
        NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,wholesaleListIndex];
        NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,wholesaleListIndex];
        
        NSMutableDictionary *wholesale = [NSMutableDictionary new];
        [wholesale addEntriesFromDictionary:_wholesaleList[indexPath.row]];
        
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        NSString *priceCurrencyID = product.product_currency_id;
        if (textField == wholesalePriceTextFiled) {
            NSNumber *textFieldValue;
            if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
                textFieldValue = [_RPCurrencyFormatter numberFromString:textField.text];
            }
            else
            {
                textFieldValue = [_USDCurrencyFormatter numberFromString:textField.text];
            }
            [wholesale setObject:textFieldValue?:@"" forKey:wholesalePriceKey];
        }
        if (textField == wholesaleMinimumQuantityTextFiled) {
            [wholesale setObject:textField.text?:@"" forKey:wholesaleQuantityMinimum];
        }
        if (textField == wholesaleMaximumQuantityTextFiled) {
            [wholesale setObject:textField.text?:@"" forKey:wholesaleQuantityMaximum];
        }
        
        [_wholesaleList replaceObjectAtIndex:indexPath.row withObject:wholesale];
        if (indexPath.row == 0 && _wholesaleList.count>0) {
            CGFloat priceInteger = [[wholesale objectForKey:wholesalePriceKey] floatValue];
            NSInteger wholesaleMinQty = [[wholesale objectForKey:wholesaleQuantityMinimum]integerValue];
            NSInteger wholesaleMaxQty = [[wholesale objectForKey:wholesaleQuantityMaximum]integerValue];
            if (priceInteger != 0 && wholesaleMaxQty !=0 && wholesaleMinQty != 0) {
                cell.deleteWholesaleButton.hidden = NO;
            }
            else
            {
                cell.deleteWholesaleButton.hidden = YES;
            }
        }
    }
}

- (void)ProductEditWholesaleCell:(ProductEditWholesaleCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
 }


-(void)removeCell:(ProductEditWholesaleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger wholesaleCount = _wholesaleList.count;
    //if (wholesaleCount>1) {
    
    if (indexPath.row == 0) {
        NSRange rangeDeletedWholesale = NSMakeRange(1, wholesaleCount-1);
        [_wholesaleList removeObjectsInRange:rangeDeletedWholesale];
        cell.deleteWholesaleButton.hidden = YES;
        NSMutableDictionary *wholesale = [NSMutableDictionary new];
        [wholesale addEntriesFromDictionary:_wholesaleList[indexPath.row]];
        NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,1];
        NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,1];
        NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,1];
        
        [wholesale setObject:@"0" forKey:wholesalePriceKey];
        [wholesale setObject:@"0" forKey:wholesaleQuantityMinimum];
        [wholesale setObject:@"0" forKey:wholesaleQuantityMaximum];
        [_wholesaleList replaceObjectAtIndex:0 withObject:[wholesale copy]];
    }
    else
    {
        NSRange rangeDeletedWholesale = NSMakeRange(indexPath.row, wholesaleCount-indexPath.row);
        [_wholesaleList removeObjectsInRange:rangeDeletedWholesale];
    }
    
    NSMutableArray *deletedIndexPath = [NSMutableArray new];
    for (NSInteger i=indexPath.row; i<wholesaleCount; i++) {
        if (i > 0) {
            [deletedIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:deletedIndexPath
                  withRowAnimation:UITableViewRowAnimationLeft];
    [_table endUpdates];
    [_table reloadData];
    
    //}
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        NSDictionary *dataInputFromPreviousVC = [_data objectForKey:DATA_INPUT_KEY];
        [_dataInput addEntriesFromDictionary:dataInputFromPreviousVC];
        
        NSArray *wholesales = [_dataInput objectForKey:DATA_WHOLESALE_LIST_KEY];
        [_wholesaleList addObjectsFromArray:wholesales];
        
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        NSString *priceCurrencyID = product.product_currency_id;
        NSString *productPricePerProduct = product.product_price;
        
        CGFloat priceInteger = [productPricePerProduct floatValue];
        if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
            _productPriceLabel.text = (priceInteger>0)?[_RPCurrencyFormatter stringFromNumber:@(priceInteger)]:@"";
        }
        else
        {
            _productPriceLabel.text = [_USDCurrencyFormatter stringFromNumber:@(priceInteger)];
        }
        
        if (wholesales.count<=0) {
            [self addWholesaleListPrice:0 withQuantityMinimum:0 andQuantityMaximum:0];
        }
        else {
            _isnodata = NO;
            [_table reloadData];
        }
        
        if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH)
            _currencyLabel.text = @"Rp";
        else if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_USD)
            _currencyLabel.text = @"US$";
    }
    else
    {
        [self addWholesaleListPrice:0 withQuantityMinimum:0 andQuantityMaximum:0];
        [_table reloadData];
    }
}

-(void)addWholesaleListPrice:(NSInteger)price withQuantityMinimum:(NSInteger)minimum andQuantityMaximum:(NSInteger)maximum
{
    NSInteger wholesaleListIndex = _wholesaleList.count+1;
    NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndex];
    NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,wholesaleListIndex];
    NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,wholesaleListIndex];
    
    
    NSDictionary *wholesale = @{wholesalePriceKey:@(price),
                                wholesaleQuantityMaximum:@(maximum),
                                wholesaleQuantityMinimum:@(minimum)
                                };
    [_wholesaleList addObject:wholesale];
    
    _isnodata = NO;
}

-(BOOL)isValidMaxWholesaleList
{
    if (_wholesaleList.count>=5) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_MAXIMAL_WHOLESALE_LIST delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

-(BOOL)isValidWholesalePriceCompareNet
{
    BOOL isValidWholesalePriceCompareNet = YES;
    
    if (_wholesaleList.count==0) {
        return isValidWholesalePriceCompareNet;
    }
    
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    CGFloat netPrice = [product.product_price floatValue];
    float wholesalePrice;
    NSString *wholesalePriceKey;
    
    for(int i = 0;i<_wholesaleList.count;i++)
    {
        NSInteger wholesaleListIndex = i;
        NSInteger wholesaleIndex = i+1;
        wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleIndex];
        wholesalePrice = [[_wholesaleList[wholesaleListIndex]objectForKey:wholesalePriceKey]floatValue];

        if (wholesalePrice>=netPrice) {
            isValidWholesalePriceCompareNet = NO;
            break;
        }
    }
    
    if (!isValidWholesalePriceCompareNet) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_INVALID_PRICE_WHOLESALE_COMPARE_NET delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    return isValidWholesalePriceCompareNet;
}

-(BOOL)isValidQuantityValue
{
    BOOL isValidQuantityValue = YES;
    
    if (_wholesaleList.count==0) {
        return isValidQuantityValue;
    }
    
    NSString *errorMessage;
    
    NSInteger wholesaleCount = _wholesaleList.count;
    for (int i = 1; i<=wholesaleCount; i++) {
        NSString *wholesaleQuantityMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,i];
        NSString *wholesaleQuantityMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,i];
        
        NSDictionary *wholesale = _wholesaleList[i-1];
        NSInteger wholesaleMinQty = [[wholesale objectForKey:wholesaleQuantityMinimum]integerValue];
        NSInteger wholesaleMaxQty = [[wholesale objectForKey:wholesaleQuantityMaximum]integerValue];
        
        
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        NSInteger minimumOrder = [ product.product_min_order integerValue]?:1;
        
        NSInteger wholesaleListIndexPrevious = i-1;
        NSString *wholesaleQuantityPreviousMaximum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MAXIMUM_KEY,wholesaleListIndexPrevious];
        NSString *wholesaleQuantityPreviousMinimum = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_QUANTITY_MINIMUM_KEY,wholesaleListIndexPrevious];
        
        NSDictionary *wholesalePrevious = _wholesaleList[(wholesaleListIndexPrevious==0)?wholesaleListIndexPrevious:wholesaleListIndexPrevious-1];
        NSInteger wholesaleMinQtyPrevious = [[wholesalePrevious objectForKey:wholesaleQuantityPreviousMinimum]integerValue];
        NSInteger wholesaleMaxQtyPrevious = [[wholesalePrevious objectForKey:wholesaleQuantityPreviousMaximum]integerValue];
        
        if (wholesaleMaxQty<=0) {
            isValidQuantityValue = NO;
        }
        else if (wholesaleMinQty<=0) {
            isValidQuantityValue = NO;
        }
        else if (wholesaleMaxQty<wholesaleMinQty)
        {
            isValidQuantityValue = NO;
        }
        else if (wholesaleMinQty<=minimumOrder) {
            isValidQuantityValue = NO;
            errorMessage = ERRORMESSAGE_INVALID_QUANTITY_MINIMUM_WHOLESALE_COMPARE_MINIMUM_ORDER;
        }
        else if (wholesaleMinQty<=wholesaleMinQtyPrevious ||
                 wholesaleMaxQty<=wholesaleMaxQtyPrevious ||
                 wholesaleMinQty<=wholesaleMaxQtyPrevious ||
                 wholesaleMinQty>=wholesaleMaxQty){
            isValidQuantityValue = NO;
        }
    }
    
    BOOL isValid = isValidQuantityValue;
    
    if (!isValid) {
        if (!errorMessage) {
            errorMessage = ERRORMESSAGE_INVALID_QUANTITY_WHOLESALE;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    return isValid;
}

-(BOOL)isValidWholesalePrice
{
    BOOL isValidPrice = YES;
    
    if (_wholesaleList.count==0) {
        return isValidPrice;
    }
    
    NSString *errorMessage = @"";
    NSInteger wholesaleListKeyIndex = _wholesaleList.count;
    NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListKeyIndex];
    
    NSInteger wholesaleListIndex = _wholesaleList.count-1;
    
    NSDictionary *wholesale = _wholesaleList[wholesaleListIndex];
    float wholesalePrice = 0;
    if (wholesaleListIndex < 0) {
        wholesaleListIndex = 0;
    }
    else
    {
        wholesalePrice = [[wholesale objectForKey:wholesalePriceKey]floatValue];
    }
    
    NSInteger productPriceCurrencyID = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
    
    if (!(wholesalePrice > 0)) {
        errorMessage = @"Harga harus diisi";
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_RUPIAH &&
             (wholesalePrice<MINIMUM_PRICE_RUPIAH || wholesalePrice>MAXIMUM_PRICE_RUPIAH)) {
        errorMessage = ERRORMESSAGE_INVALID_PRICE_RUPIAH;
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_USD && (wholesalePrice<MINIMUM_PRICE_USD || wholesalePrice>MAXIMUM_PRICE_USD)) {
        errorMessage = ERRORMESSAGE_INVALID_PRICE_USD;
        isValidPrice = NO;
    }
    else if (_wholesaleList.count>=2) {
        NSInteger wholesaleListIndexPrevious = wholesaleListKeyIndex-1;
        NSString *wholesalePricePreviousKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndexPrevious];
        
        NSDictionary *wholesalePrevious = _wholesaleList[wholesaleListIndex-1];
        float wholesalePricePrevious = [[wholesalePrevious objectForKey:wholesalePricePreviousKey]floatValue];
        
        if (wholesalePrice >= wholesalePricePrevious) {
            isValidPrice = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_INVALID_PRICE_WHOLESALE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
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
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        _scrollviewContentSize = [_table contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_table setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             _scrollviewContentSize = [_table contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             //if ((self.view.frame.origin.y + _activeTextField.frame.origin.y+_activeTextField.frame.size.height)> _keyboardPosition.y) {
                             UIEdgeInsets inset = _table.contentInset;
                             inset.bottom = (_keyboardPosition.y-(self.view.frame.origin.y + _table.frame.origin.y+_activeTextField.frame.size.height));
                             [_table setContentSize:_scrollviewContentSize];
                             [_table setContentInset:inset];
                             //}
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                         _table.contentInset = contentInsets;
                         _table.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}
@end
