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
    
    _dataInput = [NSMutableDictionary new];
    _wholesaleList = [NSMutableArray new];
    
    _table.tableHeaderView = _headerView;
    [self setDefaultData:_data];
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [saveBarButtonItem setTintColor:[UIColor blackColor]];
    saveBarButtonItem.tag = BARBUTTON_PRODUCT_SAVE;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [cancelBarButtonItem setTintColor:[UIColor whiteColor]];
    cancelBarButtonItem.tag = BARBUTTON_PRODUCT_BACK;
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_delegate ProductEditWholesaleViewController:self withWholesaleList:_wholesaleList];
    [self.navigationController popViewControllerAnimated:YES];
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
                    if ([self isValidQuantityValue] && [self isValidWholesalePriceCompareNet] && [self isValidWholesalePrice]) {
                        [_delegate ProductEditWholesaleViewController:self withWholesaleList:_wholesaleList];
                        [self.navigationController popViewControllerAnimated:YES];
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
            
            NSInteger priceInteger = [[wholesale objectForKey:wholesalePriceKey] integerValue];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:3];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *wholesalePrice = (priceInteger>0)?[formatter stringFromNumber:@(priceInteger)]:@"";

            NSInteger wholesaleMinQty = [[wholesale objectForKey:wholesaleQuantityMinimum]integerValue];
            NSInteger wholesaleMaxQty = [[wholesale objectForKey:wholesaleQuantityMaximum]integerValue];
            ((ProductEditWholesaleCell*)cell).productPriceTextField.text = (wholesalePrice==0)?@"":wholesalePrice;
            
            ((ProductEditWholesaleCell*)cell).minimumProductTextField.text = (wholesaleMinQty==0)?@"":[NSString stringWithFormat:@"%zd",wholesaleMinQty];
            ((ProductEditWholesaleCell*)cell).maximumProductTextField.text = (wholesaleMaxQty==0)?@"":[NSString stringWithFormat:@"%zd",wholesaleMaxQty];
            ((ProductEditWholesaleCell*)cell).indexPath = indexPath;
            ((ProductEditWholesaleCell*)cell).deleteWholesaleButton.hidden = (indexPath.row==0);

            ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
            NSInteger priceCurencyID = [product.product_currency_id integerValue]?:1;
            if (priceCurencyID == PRICE_CURRENCY_ID_RUPIAH)
                ((ProductEditWholesaleCell*)cell).productCurrencyLabel.text = @"Rp";
            else if (priceCurencyID == PRICE_CURRENCY_ID_USD)
                ((ProductEditWholesaleCell*)cell).productCurrencyLabel.text = @"US$";
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
		cell.backgroundColor = [UIColor whiteColor];
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

        NSString *textFieldValue = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        if (textField == wholesalePriceTextFiled) {
            
            [wholesale setObject:textFieldValue forKey:wholesalePriceKey];
        }
        if (textField == wholesaleMinimumQuantityTextFiled) {
            [wholesale setObject:textFieldValue forKey:wholesaleQuantityMinimum];
        }
        if (textField == wholesaleMaximumQuantityTextFiled) {
            [wholesale setObject:textFieldValue forKey:wholesaleQuantityMaximum];
        }
        
        [_wholesaleList replaceObjectAtIndex:indexPath.row withObject:wholesale];
    }
}

- (void)ProductEditWholesaleCell:(ProductEditWholesaleCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    NSInteger priceCurencyID = [product.product_currency_id integerValue]?:1;
    BOOL isIDRCurrency = (priceCurencyID == PRICE_CURRENCY_ID_RUPIAH);
    if (textField == cell.productPriceTextField) {
        if (isIDRCurrency) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([string length]==0)
            {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:4];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            else {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:2];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                if(![num isEqualToString:@""])
                {
                    num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                    textField.text = str;
                }
            }
        }
    }
}


-(void)removeCell:(ProductEditWholesaleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger wholesaleCount = _wholesaleList.count;
    if (wholesaleCount>1) {
        NSRange rangeDeletedWholesale = NSMakeRange(indexPath.row, wholesaleCount-indexPath.row);
        [_wholesaleList removeObjectsInRange:rangeDeletedWholesale];
        [_table reloadData];
    }
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
        NSString *price;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if ([priceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:3];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            price = [formatter stringFromNumber:@([productPricePerProduct integerValue])];
        }
        else
        {
            [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
            price = [NSString stringWithFormat:@"$%.2lf",(double)[productPricePerProduct integerValue]];
        }
        _productPriceLabel.text = price;
        
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
    
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    NSInteger netPrice = [product.product_price integerValue];
    NSInteger wholesalePrice;
    NSString *wholesalePriceKey;
    
    NSInteger wholesaleListIndex = _wholesaleList.count;
    NSInteger wholesaleIndex = _wholesaleList.count-1;
    wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndex];
    wholesalePrice = [[_wholesaleList[wholesaleIndex]objectForKey:wholesalePriceKey]integerValue];
    if (wholesalePrice>=netPrice) {
        isValidWholesalePriceCompareNet = NO;
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
        else if (wholesaleMinQty<=wholesaleMinQtyPrevious && wholesaleMaxQty<=wholesaleMaxQtyPrevious ){
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
    NSString *errorMessage;
    NSInteger wholesaleListKeyIndex = _wholesaleList.count;
    NSString *wholesalePriceKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListKeyIndex];
    
    NSInteger wholesaleListIndex = _wholesaleList.count-1;
    NSDictionary *wholesale = _wholesaleList[wholesaleListIndex];
    NSInteger wholesalePrice = [[wholesale objectForKey:wholesalePriceKey]integerValue];
    
    NSInteger productPriceCurrencyID = [[wholesale objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
    
    if (!(wholesalePrice > 0)) {
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_RUPIAH && (wholesalePrice<MINIMUM_PRICE_RUPIAH || wholesalePrice>MAXIMUM_PRICE_RUPIAH)) {
        errorMessage = ERRORMESSAGE_INVALID_PRICE_RUPIAH;
        isValidPrice = NO;
    }
    else if (productPriceCurrencyID == PRICE_CURRENCY_ID_USD && (wholesalePrice<MINIMUM_PRICE_USD || wholesalePrice>MAXIMUM_PRICE_USD)) {
        errorMessage = ERRORMESSAGE_INVALID_PRICE_USD;
        isValidPrice = NO;
    }
    else if (_wholesaleList.count>=2) {
        NSInteger wholesaleListIndexPrevious = wholesaleListIndex-1;
        NSString *wholesalePricePreviousKey = [NSString stringWithFormat:@"%@%zd",API_WHOLESALE_PRICE,wholesaleListIndexPrevious];

        NSDictionary *wholesalePrevious = _wholesaleList[wholesaleListIndex-1];
        NSInteger wholesalePricePrevious = [[wholesalePrevious objectForKey:wholesalePricePreviousKey]integerValue];
        
        if (wholesalePrice < wholesalePricePrevious) {
            isValidPrice = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_INVALID_PRICE_WHOLESALE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
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
