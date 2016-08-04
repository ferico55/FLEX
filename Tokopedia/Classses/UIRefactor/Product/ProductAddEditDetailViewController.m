//
//  ProductAddEditDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "string_product.h"
#import "EtalaseList.h"
#import "AlertPickerView.h"
#import "ProductAddEditDetailViewController.h"
#import "EtalaseViewController.h"
#import "ProductEditWholesaleViewController.h"
#import "MyShopEtalaseEditViewController.h"
#import "MyShopNoteViewController.h"

#import "MyShopNoteDetailViewController.h"
#import "GAIDictionaryBuilder.h"
#import "Tokopedia-Swift.h"

NSString * const ProductStatusWarehouse = @"3";

@interface ProductAddEditDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate,
    TKPDAlertViewDelegate,
    EtalaseViewControllerDelegate
>
{
    UIAlertView *_processingAlert;
    UIBarButtonItem *_saveBarButtonItem;
}

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4TableViewCell;
@property (strong, nonatomic) IBOutlet UIView *section0FooterView;
@property (strong, nonatomic) IBOutlet UIView *section3FooterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *pengembalianProductLabel;

- (IBAction)tap:(id)sender;

@end

@implementation ProductAddEditDetailViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self adjustBarButton];
    [self adjustReturnableNotesLabel];
    
    _processingAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Uploading..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(didUpdateShopHasTerms:)
               name:DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME
             object:nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self setAppearance];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITableViewCell *returnableCell = (UITableViewCell*)_section0TableViewCell[1];
    
    if (_form.info.shop_has_terms) {
        returnableCell.detailTextLabel.textColor = TEXT_COLOUR_ENABLE;
    }
    else
    {
        returnableCell.detailTextLabel.textColor = TEXT_COLOUR_DISABLE;
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(void)onTapSave:(UIBarButtonItem*)sender{
    if (_type == TYPE_ADD_EDIT_PRODUCT_ADD|| _type == TYPE_ADD_EDIT_PRODUCT_COPY) {
        if ([self isValidInput]) {
            [self fetchAddProduct];
        }
    } else {
        [self fetchEditProduct];
    }
}
-(IBAction)tap:(id)sender
{
    MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
    vc.data = @{kTKPDDETAIL_DATATYPEKEY : @(NOTES_RETURNABLE_PRODUCT)
                };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)fetchAddProduct{
    
    [_processingAlert show];
    _saveBarButtonItem.enabled = NO;
    
    NSString *duplicate = (_type == TYPE_ADD_EDIT_PRODUCT_COPY)?@"1":@"0";
    
    [RequestAddEditProduct fetchAddProduct:_form
                               isDuplicate:duplicate
                                 onSuccess:^{
                                     
                                     [self successAddProduct];
                                     
                                 } onFailure:^{
                                     
                                     _saveBarButtonItem.enabled = YES;
                                     [_processingAlert dismissWithClickedButtonIndex:0 animated:YES];
                                     [self trackerFailAddProduct];
                                     
                                 }];
}

-(void)trackerFailAddProduct{
    [TPAnalytics trackScreenName:@"Add Product - Fail"];
    
    // GA
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:kGAIScreenName value:@"Add Product - Fail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)fetchEditProduct{
    
    [_processingAlert show];
    _saveBarButtonItem.enabled = NO;

    [RequestAddEditProduct fetchEditProduct:_form onSuccess:^{
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        _saveBarButtonItem.enabled = YES;
        [_processingAlert dismissWithClickedButtonIndex:0 animated:YES];
        
    } onFailure:^{
        
        _saveBarButtonItem.enabled = YES;
        [_processingAlert dismissWithClickedButtonIndex:0 animated:YES];
        
    }];
}

-(void)successAddProduct{
    
    // UA
    [TPAnalytics trackScreenName:@"Add Product - Success"];
    
    // GA
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:kGAIScreenName value:@"Add Product - Success"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil userInfo:nil];
    [_processingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessages = [NSMutableArray new];
    ProductEditDetail *product = _form.product;
    
    NSString* etalaseUserInfoID = product.product_etalase_id;
    BOOL isNewEtalase = [etalaseUserInfoID isEqualToString:@"-1"];
    NSString *etalaseID = isNewEtalase ? @"new" : etalaseUserInfoID;
    
    NSString *etalaseName = product.product_etalase?:@"";
    
    if (isNewEtalase && (etalaseName == nil || [etalaseName isEqualToString:@""])) {
        isValid = NO;
        [errorMessages addObject:@"Nama etalase belum diisi"];
    }
    if (!isNewEtalase && [etalaseID integerValue] == 0) {
        isValid = NO;
        [errorMessages addObject:@"Etalase belum dipilih"];
    }
    
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
    return isValid;
}

- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        if (gesture.view.tag == GESTURE_PRODUCT_EDIT_WHOLESALE) {
            ProductEditWholesaleViewController *editWholesaleVC = [ProductEditWholesaleViewController new];
            editWholesaleVC.form = _form;
            [self.navigationController pushViewController:editWholesaleVC animated:YES];
        }
    }
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    switch (section) {
        case 0:
            rowCount = _section0TableViewCell.count;
            break;
        case 1:
            rowCount = _section1TableViewCell.count;
            break;
        case 2:
            rowCount = _section2TableViewCell.count;
            break;
        case 3:
            rowCount = _section3TableViewCell.count;
            break;
        case 4:
            rowCount = _section4TableViewCell.count;
            break;
        default:
            break;
    }
    
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductEditDetail *product = _form.product;
    
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0TableViewCell[indexPath.row];
            if (indexPath.row == BUTTON_PRODUCT_INSURANCE) {
                NSString *productMustInsurance =[ARRAY_PRODUCT_INSURACE[([product.product_must_insurance integerValue]>0)?[product.product_must_insurance integerValue]:0]objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = productMustInsurance;
            }
            if (indexPath.row == BUTTON_PRODUCT_RETURNABLE) {
                NSString *productReturnable =[ARRAY_PRODUCT_RETURNABLE[[product.product_returnable integerValue]]objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = productReturnable;
            }
            break;
        case 1:
            cell = _section1TableViewCell[indexPath.row];
            BOOL isProductWarehouse = [product.product_status isEqualToString:@"3"];
            if (indexPath.row == BUTTON_PRODUCT_ETALASE) {
                NSString *moveTo = (isProductWarehouse)?[ARRAY_PRODUCT_MOVETO_ETALASE[0]objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_MOVETO_ETALASE[1]objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = moveTo;
            }
            else if (indexPath.row == BUTTON_PRODUCT_ETALASE_DETAIL)
            {
                cell.detailTextLabel.text = ([product.product_etalase isEqualToString:@"0"]||!product.product_etalase)?@"Pilih Etalase":product.product_etalase;
            }
            break;
        case 2:
            cell = _section2TableViewCell[indexPath.row];
            if (indexPath.row==BUTTON_PRODUCT_CONDITION) {
                NSInteger productCondition = [product.product_condition integerValue];
                BOOL isNewProduct = (productCondition == PRODUCT_CONDITION_NEW_ID || productCondition == PRODUCT_CONDITION_NOTSET_ID)?YES:NO;
                NSString *productConditionName = isNewProduct?[ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_NAME_KEY]:[ARRAY_PRODUCT_CONDITION[1] objectForKey:DATA_NAME_KEY];
                cell.detailTextLabel.text = productConditionName;
            }
            break;
        case 3:
            cell = _section3TableViewCell[indexPath.row];
            break;
        case 4:
            cell = _section4TableViewCell[indexPath.row];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - Table View Delegate
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return _section0FooterView;
    else if (section == 3)
        return _section3FooterView;
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return _section0FooterView.frame.size.height;
    else if(section == 3)
        return _section3FooterView.frame.size.height;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellHeight = 0.0f;
    switch (indexPath.section) {
        case 0:
            cellHeight = ((UITableViewCell*)_section0TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 1:
            cellHeight = ((UITableViewCell*)_section1TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 2:
            cellHeight = ((UITableViewCell*)_section2TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 3:
            cellHeight = ((UITableViewCell*)_section3TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 4:
            cellHeight = ((UITableViewCell*)_section4TableViewCell[indexPath.row]).frame.size.height;
            break;
        default:
            break;
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_productDescriptionTextView resignFirstResponder];
    _form.product.product_short_desc = _productDescriptionTextView.text?:@"";
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_INSURANCE:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 10;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_INSURACE;
                    [alertView show];
                    break;
                }
                case BUTTON_PRODUCT_RETURNABLE:
                {
                    if (_form.info.shop_has_terms) {
                        AlertPickerView *alertView = [AlertPickerView newview];
                        alertView.tag = 13;
                        alertView.delegate = self;
                        alertView.pickerData = ARRAY_PRODUCT_RETURNABLE;
                        [alertView show];
                    }
                    break;
                }
            }
            break;
        case 1:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_ETALASE:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 11;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_MOVETO_ETALASE;
                    [alertView show];
                    break;
                }
                case BUTTON_PRODUCT_ETALASE_DETAIL:
                {
                    ProductEditDetail *product = _form.product;
                    EtalaseList *newEtalase = [EtalaseList new];
                    newEtalase.etalase_name = product.product_etalase;
                    newEtalase.etalase_id = product.product_etalase_id;
                    EtalaseViewController *etalaseViewController = [EtalaseViewController new];
                    etalaseViewController.isEditable = NO;
                    etalaseViewController.showOtherEtalase = NO;
                    UserAuthentificationManager *auth = [UserAuthentificationManager new];
                    etalaseViewController.shopId = [auth getShopId];
                    etalaseViewController.initialSelectedEtalase = newEtalase;
                    etalaseViewController.delegate = self;
                    [etalaseViewController setEnableAddEtalase:YES];
                    [self.navigationController pushViewController:etalaseViewController animated:YES];

                    break;
                }
            }
            break;
        case 2:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_CONDITION:
                {
                    AlertPickerView *alertView = [AlertPickerView newview];
                    alertView.tag = 12;
                    alertView.delegate = self;
                    alertView.pickerData = ARRAY_PRODUCT_CONDITION;
                    [alertView show];
                    break;
                }
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_EDIT_WHOLESALE:
                {
                    ProductEditWholesaleViewController *editWholesaleVC = [ProductEditWholesaleViewController new];
                    editWholesaleVC.form = _form;
                    [self.navigationController pushViewController:editWholesaleVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    // UA
    [TPAnalytics trackScreenName:@"Add Product - Fail"];
    
    // GA
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:kGAIScreenName value:@"Add Product - Fail"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - TextView Delegate

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _productDescriptionTextView) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            ProductEditDetail *product = _form.product;
            product.product_short_desc = textView.text;
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
#define PRODUCT_DESCRIPTION_CHARACTER_LIMIT 2000
    return textView.text.length + (text.length - range.length) <= PRODUCT_DESCRIPTION_CHARACTER_LIMIT;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Alertview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#define DEFAULT_ETALASE_DETAIL_TITLE_BUTTON @"Pilih Etalase"
    ProductEditDetail *product = _form.product?:[ProductEditDetail new];
    switch (alertView.tag) {
        case 10:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [[ARRAY_PRODUCT_INSURACE[index] objectForKey:DATA_VALUE_KEY] stringValue];
            product.product_must_insurance = value;
            [_tableView reloadData];
            break;
        }
        case 12:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [[ARRAY_PRODUCT_CONDITION[index] objectForKey:DATA_VALUE_KEY] stringValue];
            product.product_condition = value;
            [_tableView reloadData];
            break;
        }
        case 11:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [[ARRAY_PRODUCT_MOVETO_ETALASE[index] objectForKey:DATA_VALUE_KEY] stringValue];
            product.product_status = [value isEqualToString:@"1"] ? @"1" : @"3";
            [_tableView reloadData];
            break;
        }
        case 13:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [[ARRAY_PRODUCT_RETURNABLE[index] objectForKey:DATA_VALUE_KEY] stringValue];
            _form.product.product_returnable = value;
            [_tableView reloadData];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Product Etalase Delegate

-(void)didSelectEtalase:(EtalaseList *)selectedEtalase{
    ProductEditDetail *product = _form.product;
    product.product_etalase_id = selectedEtalase.etalase_id;
    product.product_etalase = selectedEtalase.etalase_name;
    
    [_tableView reloadData];

}


#pragma mark - Methods
-(void)setShopHasTerm:(NSString *)shopHasTerm
{
    _form.info.shop_has_terms = shopHasTerm;
}

-(void)setAppearance {
    ProductEditDetail *product = _form.product;

    NSString *productDescription = [NSString convertHTML:product.product_short_desc]?:@"";
    productDescription = ([productDescription isEqualToString:@"0"])?@"":productDescription;
    _productDescriptionTextView.text = productDescription;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *shopHasTerm = [auth getShopHasTerm];
    _form.info.shop_has_terms = shopHasTerm;
    
    [_tableView reloadData];
}

-(void)adjustBarButton
{

    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                          style:UIBarButtonItemStyleDone
                                                         target:(self)
                                                         action:@selector(onTapSave:)];
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
}

-(void)adjustReturnableNotesLabel
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:_pengembalianProductLabel.text];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_10 range:[_pengembalianProductLabel.text rangeOfString:@"Klik Disini"]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                             range:[_pengembalianProductLabel.text rangeOfString:@"Klik Disini"]];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:[_pengembalianProductLabel.text rangeOfString:_pengembalianProductLabel.text]];
    
    _pengembalianProductLabel.attributedText = attributedString;
}

-(void)didEditNote:(NSNotification*)notification
{
    [_delegate DidEditReturnableNote];
}

-(void)didUpdateShopHasTerms:(NSNotification*)notification
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *shopHasTerm = [auth getShopHasTerm];
    _form.info.shop_has_terms= shopHasTerm;
    
    [_tableView reloadData];
}

@end
