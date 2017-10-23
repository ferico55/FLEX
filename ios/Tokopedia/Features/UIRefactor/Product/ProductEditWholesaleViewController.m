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
#define PRICE_CURRENCY_ID_USD 2

@interface ProductEditWholesaleViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray <WholesalePrice*> *_wholesales;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@end

@implementation ProductEditWholesaleViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Harga Grosir";
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStylePlain target:(self) action:@selector(onTapSave:)];
    [saveBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
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
    _wholesales = [_form.wholesale_price mutableCopy];
}

-(void)setHeaderAppearance{
    CGFloat priceInteger = [_form.product.product_price floatValue];
    
    if ([_form.product.product_currency_id integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
        self.productPriceLabel.text = [[NSNumberFormatter IDRFormatterWithoutCurency] stringFromNumber:@(priceInteger)]?:@"";
        self.currencyLabel.text = @"Rp";
    } else {
        self.productPriceLabel.text = [[NSNumberFormatter USDFormatter] stringFromNumber:@(priceInteger)];
        self.currencyLabel.text = @"US$";
    }
    _table.tableHeaderView = _headerView;
}

#pragma mark - View Gesture
-(void)onTapSave:(UIBarButtonItem*)sender{
    [[self.table superview] endEditing:YES];
    if ([self isValidMaxWholesaleList]) {
        _form.wholesale_price = [_wholesales copy];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)onTapAddWholesale:(id)sender {
    [[self.table superview] endEditing:YES];
    
    if (_wholesales.count == 5) {
        [StickyAlertView showErrorMessage:@[@"Maksimal harga grosir yang dapat Anda masukkan adalah 5."]];
        return;
    }
    
    if ([self isValidMaxWholesaleList]) {
        [self addWholesalePrice:@"" withQtyMin:@"" andQtyMax:@""];
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_wholesales.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)addWholesalePrice:(NSString*)price withQtyMin:(NSString*)min andQtyMax:(NSString*)max{
    WholesalePrice *wholesale = [WholesalePrice new];
    wholesale.wholesale_price = price?:@"";
    wholesale.wholesale_max = max?:@"";
    wholesale.wholesale_min = min?:@"";
    
    [_wholesales addObject:wholesale];
    [_table reloadData];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _wholesales.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellid = PRODUCT_EDIT_WHOLESALE_CELL_IDENTIFIER;
    
    ProductEditWholesaleCell *cell = (ProductEditWholesaleCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [ProductEditWholesaleCell newcell];
    }

    WholesalePrice *wholesale = _wholesales[indexPath.row];
    cell.wholesale = wholesale;
    cell.productPriceCurency = _form.product.product_currency_id;
    
    __weak typeof(self) wself = self;
    __block ProductEditWholesaleCell *cellWholesale = cell;
    [cell setRemoveWholesale:^(WholesalePrice *wholesale) {
        [wself removeCell:cellWholesale atIndexPath:indexPath];
    }];
    
    return cell;

}
-(void)removeCell:(ProductEditWholesaleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *wholesaleList = [[NSMutableArray alloc]initWithArray:_wholesales];

    NSMutableArray *deletedIndexPath = [NSMutableArray new];
    for (NSInteger i=_wholesales.count-1; i>=indexPath.row; i--) {
        [deletedIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [wholesaleList removeObject:_wholesales[i]];
    }
    _wholesales = wholesaleList;
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:deletedIndexPath
                  withRowAnimation:UITableViewRowAnimationLeft];
    [_table endUpdates];
    [_table reloadData];
    
}

#pragma mark - Methods
-(BOOL)isValidMaxWholesaleList
{
    FormProductValidation *validation = [FormProductValidation new];
    BOOL isValid = [validation isValidFormProductWholesale:_wholesales product:_form.product];
    
    return isValid;
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
