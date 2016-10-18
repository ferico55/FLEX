//
//  ProductAddEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTableViewController.h"
#import "detail.h"
#import "string_product.h"
#import "string_alert.h"
#import "CatalogAddProduct.h"
#import "AlertPickerView.h"
#import "ProductAddEditViewController.h"
#import "ProductAddEditDetailViewController.h"
#import "ProductEditImageViewController.h"
#import "FilterCategoryViewController.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "Tokopedia-Swift.h"
#import "UIButton+AFNetworking.h"

#define DATA_SELECTED_BUTTON_KEY @"data_selected_button"

#pragma mark - Setting Add Product View Controller
@interface ProductAddEditViewController ()
<
UITextFieldDelegate,
UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
TKPDAlertViewDelegate,
GeneralTableViewControllerDelegate,
FilterCategoryViewDelegate
>
{
    UITextField *_activeTextField;
    
    ProductEditResult *_form;
    NSArray<CatalogList*> *_catalogs;
    
    UIBarButtonItem *_nextBarButtonItem;
    UserAuthentificationManager *_authManager;
    
    NSMutableArray <DKAsset*>*_selectedAsset;
    DKAsset *_defaultImageFromAsset;
    
    UIAlertView *_alertProcessing;

    NSString *_productNameBeforeCopy;
    
    BOOL _isDoneRequestCatalog;
    BOOL _isProductNameEditable;
}

@property (strong, nonatomic) IBOutlet UIView *section2FooterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2TableViewCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3TableViewCell;

@property (weak, nonatomic) IBOutlet UIScrollView *productImageScrollView;
@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *minimumOrderTextField;
@property (weak, nonatomic) IBOutlet UITextField *productPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *productWeightTextField;
@property (weak, nonatomic) IBOutlet UIView *productImagesContentView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *addImageButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *defaultImageLabels;

@property (weak, nonatomic) IBOutlet UIView *productNameViewCell;

@end

@implementation ProductAddEditViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addImageButtons = [NSArray sortViewsWithTagInArray:_addImageButtons];
    _defaultImageLabels = [NSArray sortViewsWithTagInArray:_defaultImageLabels];
    _section1TableViewCell = [NSArray sortViewsWithTagInArray:_section1TableViewCell];
    _section2TableViewCell = [NSArray sortViewsWithTagInArray:_section2TableViewCell];
    _section3TableViewCell = [NSArray sortViewsWithTagInArray:_section3TableViewCell];
    
    _selectedAsset = [NSMutableArray new];
    
    _alertProcessing = [[UIAlertView alloc]initWithTitle:nil message:@"Processing" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    BOOL isBeingPresented = self.navigationController.isBeingPresented;
    if (isBeingPresented) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(onTapBackBarButton:)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    _nextBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                          style:UIBarButtonItemStyleDone
                                                         target:(self)
                                                         action:@selector(onTapNextButton:)];
    self.navigationItem.rightBarButtonItem = _nextBarButtonItem;
    
    [_productImageScrollView addSubview:_productImagesContentView];
    
    switch (_type) {
        case TYPE_ADD_EDIT_PRODUCT_ADD:
            self.title =  @"Tambah Produk";
            [self setDefaultForm];
            [AnalyticsManager trackScreenName:@"Add Product Page"];
            break;
        case TYPE_ADD_EDIT_PRODUCT_EDIT:
            self.title = @"Ubah Produk";
            [self fetchFormEditProductID:_productID];
            [AnalyticsManager trackScreenName:@"Edit Product Page"];
            break;
        case TYPE_ADD_EDIT_PRODUCT_COPY:
            self.title = @"Salin Produk";
            [self fetchFormEditProductID:_productID];
            [AnalyticsManager trackScreenName:@"Copy Product Page"];
            break;
        default:
            break;
    }
    
    [self addObserver];
}

-(void)addObserver{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _productImageScrollView.contentSize = _productImagesContentView.frame.size;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Action

-(void)onTapNextButton:(UIBarButtonItem*)button{
    [[self.tableView superview] endEditing:YES];
    if ([self dataInputIsValid]) {
        UserAuthentificationManager *authManager = [UserAuthentificationManager new];
        NSString *shopHasTerm = [authManager getShopHasTerm];
        _form.info.shop_has_terms = shopHasTerm;
        ProductAddEditDetailViewController *detailVC = [ProductAddEditDetailViewController new];
        detailVC.title = self.title;
        detailVC.form = _form;
        detailVC.type = _type;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

-(void)onTapBackBarButton:(UIBarButtonItem*)button{
    if (self.navigationItem.leftBarButtonItem) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)tap:(id)sender
{
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case BUTTON_PRODUCT_CATEGORY: {
                FilterCategoryViewController *controller = [FilterCategoryViewController new];
                controller.filterType = FilterCategoryTypeProductAddEdit;
                controller.delegate = self;
                UINavigationController *navigation = [[UINavigationController new] initWithRootViewController:controller];
                navigation.navigationBar.translucent = NO;
                [self.navigationController presentViewController:navigation animated:YES completion:nil];
                break;
            }
            case BUTTON_PRODUCT_PRICE_CURRENCY:
            {
                AlertPickerView *v = [AlertPickerView newview];
                v.pickerData = ARRAY_PRICE_CURRENCY;
                v.tag = btn.tag;
                v.delegate = self;
                [v show];
                break;
            }
            default:
                break;
        }
    }
}
-(IBAction)onTapImageButton:(UIButton*)sender
{
    if ([self isButtonWithProductImage:sender]) {
        [self editImageDetailAtIndex:sender.tag-1];
    } else {
        [self selectImageFromCameraOrAlbum];
    }
}

-(BOOL)isButtonWithProductImage:(UIButton*)button{
    return (button.tag != _form.product_images.count+1);
}

-(void)editImageDetailAtIndex:(NSUInteger)index{
    ProductEditImageViewController *vc = [ProductEditImageViewController new];
    vc.imageObject = _form.product_images[index];
    [vc setDefaultImageObject:^(ProductEditImages *imageObject) {
        for (ProductEditImages *image in _form.product_images) {
            if (![image isEqual:imageObject]) {
                image.image_primary = @"0";
            }
        }
        [self setImageButtons];
    }];
    [vc setDeleteImageObject:^(ProductEditImages *imageObject) {

        [self deleteImageObject:imageObject];
        if (!imageObject.isFromAsset) {
            [self fetchDeleteImageObject:imageObject atIndex:index];
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)deleteImageObject:(ProductEditImages*)imageObject{
    NSMutableArray *images = [NSMutableArray new];
    for (ProductEditImages *image in _form.product_images) {
        if (![image isEqual:imageObject]) {
            [images addObject:image];
        }
    }
    _form.product_images = [images copy];
    
    DKAsset *imageAsset = imageObject.asset;
    if (imageAsset) {
        [_selectedAsset removeObject:imageAsset];
    }
    
    [self setImageButtons];
}

-(void)fetchDeleteImageObject:(ProductEditImages*)imageObject atIndex:(NSUInteger)index{
    [self enableButtonBeforeSuccessRequest:NO];
    [RequestAddEditProduct fetchDeleteProductImageObject:imageObject
                                               productID:_form.product.product_id
                                                  shopID:[self getShopID]
                                               onSuccess:^{
        [self enableButtonBeforeSuccessRequest:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
    } onFailure:^{
        [self insertImageObject:imageObject atIndex:index];
        [self enableButtonBeforeSuccessRequest:YES];
    }];
}

-(void)insertImageObject:(ProductEditImages*)imageObject atIndex:(NSUInteger)index{
    NSMutableArray *images = [NSMutableArray new];
    [images addObjectsFromArray:_form.product_images];

    [images insertObject:imageObject atIndex:index];
    _form.product_images = [images copy];
    
    DKAsset *imageAsset = _form.product_images[index].asset;
    if (imageAsset) {
        [_selectedAsset addObject:imageAsset];
    }
    
    [self setImageButtons];
}

-(void)selectImageFromCameraOrAlbum{
    __weak typeof(self) wself = self;
    [ImagePickerController showImagePicker:self
                                 assetType:DKImagePickerControllerAssetTypeallPhotos
                       allowMultipleSelect:YES
                                showCancel:YES
                                showCamera:YES
                               maxSelected:5 - (_form.product_images.count-_selectedAsset.count)
                            selectedAssets:_selectedAsset
                                completion:^(NSArray<DKAsset *> *asset) {
                                    dispatch_async (dispatch_get_main_queue(), ^{
                                        [wself setSelectedAsset:asset];
                                        [wself addImageFromAsset];
                                    });
                                }];
}

-(void)setSelectedAsset:(NSArray<DKAsset*>*)selectedAsset{
    [_selectedAsset removeAllObjects];
    [_selectedAsset addObjectsFromArray:selectedAsset];
}

-(BOOL)isDefaultImage:(DKAsset*)image{
    
    ProductEditImages *primary;
    for (ProductEditImages *selectedImage in _form.product_images) {
        if ([selectedImage.image_primary boolValue]) {
            primary = selectedImage;
        }
    }
    
    if (_defaultImageFromAsset == nil && primary == nil) {
        return ([image isEqual:_selectedAsset.firstObject]);
    } else {
        return ([primary.asset isEqual:image]);
    }
    return NO;
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
        default:
            break;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductEditDetail *product = _form.product;
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0TableViewCell[indexPath.row];
            break;
        case 1:
            cell = _section1TableViewCell[indexPath.row];
            if (indexPath.row == BUTTON_PRODUCT_PRODUCT_NAME) {
                if (_type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
                    _productNameViewCell.hidden = _isProductNameEditable;
                }
            }
            if (indexPath.row == BUTTON_PRODUCT_CATEGORY) {
                NSString *departmentTitle = @"Pilih Kategori";
                CategoryDetail *category =product.product_category;
                departmentTitle = ([category.name isEqualToString:@""])?@"Pilih Kategori":category.name;
                cell.detailTextLabel.text = departmentTitle;
            }
            if (indexPath.row == BUTTON_PRODUCT_CATALOG) {
                cell.detailTextLabel.text = product.product_catalog.catalog_name?:@"Pilih Katalog";
            }
            break;
        case 2:
            cell = _section2TableViewCell[indexPath.row];
            if (indexPath.row==BUTTON_PRODUCT_PRICE_CURRENCY) {
                NSString *currencyName = product.product_currency;
                cell.detailTextLabel.text = currencyName;
            }
            break;
        case 3:
            cell = _section3TableViewCell[indexPath.row];
            if (indexPath.row == BUTTON_PRODUCT_WEIGHT_UNIT) {
                NSString *weightUnitName = product.product_weight_unit_name;
                cell.detailTextLabel.text = weightUnitName;
            }
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
    if (section==2) {
        return _section2FooterView;
    }
    else return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==2) {
        return _section2FooterView.frame.size.height;
    }
    else return 0;
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
            if ((_catalogs.count==0) && indexPath.row == BUTTON_PRODUCT_CATALOG) {
                cellHeight = 0;
            }
            else
            {
                cellHeight = 44;
            }
            break;
        case 2:
            cellHeight = ((UITableViewCell*)_section2TableViewCell[indexPath.row]).frame.size.height;
            break;
        case 3:
            cellHeight = ((UITableViewCell*)_section3TableViewCell[indexPath.row]).frame.size.height;
            break;
        default:
            break;
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.tableView superview] endEditing:YES];
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_PRODUCT_NAME:
                {
                    if (_type == TYPE_ADD_EDIT_PRODUCT_EDIT && !_isProductNameEditable) {
                        UIAlertView *editableNameProductAlert = [[UIAlertView alloc]initWithTitle:nil message:ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                        [editableNameProductAlert show];
                    }
                    else
                        [_productNameTextField becomeFirstResponder];
                }
                    break;
                case BUTTON_PRODUCT_CATEGORY:
                {
                    FilterCategoryViewController *controller = [FilterCategoryViewController new];
                    controller.filterType = FilterCategoryTypeProductAddEdit;
                    controller.delegate = self;
                    controller.selectedCategory = _form.product.product_category;
                    UINavigationController *navigation = [[UINavigationController new] initWithRootViewController:controller];
                    navigation.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:navigation animated:YES completion:nil];
                    break;
                }
                case BUTTON_PRODUCT_CATALOG:
                {
                    if (_isDoneRequestCatalog) {
                        GeneralTableViewController *catalogVC = [GeneralTableViewController new];
                        catalogVC.delegate = self;
                        NSMutableArray *catalogs =[NSMutableArray new];
                        for (CatalogList *catalog in _catalogs) {
                            [catalogs addObject:catalog.catalog_name];
                        }
                        catalogVC.objects = [catalogs copy];
                        catalogVC.selectedObject = _form.product.product_catalog.catalog_name?:@"";
                        [self.navigationController pushViewController:catalogVC animated:YES];
                    }
                }
                    break;
                case BUTTON_PRODUCT_MIN_ORDER:
                    [_minimumOrderTextField becomeFirstResponder];
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_PRICE_CURRENCY:
                {
                    AlertPickerView *v = [AlertPickerView newview];
                    v.pickerData = ARRAY_PRICE_CURRENCY;
                    v.tag = 11;
                    v.delegate = self;
                    [v show];
                    break;
                }
                case BUTTON_PRODUCT_PRICE:
                    [_productPriceTextField becomeFirstResponder];
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_WEIGHT_UNIT:
                {
                    AlertPickerView *v = [AlertPickerView newview];
                    v.pickerData = ARRAY_WEIGHT_UNIT;
                    v.tag = 12;
                    v.delegate = self;
                    [v show];
                    break;
                }
                case BUTTON_PRODUCT_WEIGHT:
                    [_productWeightTextField becomeFirstResponder];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
}

-(void)fetchGetCatalogWithProductName:(NSString*)productName andDepartmentID:(NSString*)departmentID{
    
    [self isFinishGetDataCatalogs:NO];
    
    [RequestAddEditProduct fetchGetCatalog:productName
                              departmentID:departmentID
                                 onSuccess:^(NSArray<CatalogList *> * catalogs) {
                                     
                                     [self setListCatalogs:catalogs];
                                     [self isFinishGetDataCatalogs:YES];
                                     
                                 } onFailure:^{
                                     
                                     [self isFinishGetDataCatalogs:YES];
                                     
                                 }];
}

-(void)setListCatalogs:(NSArray<CatalogList*>*)catalogs{
    _catalogs = catalogs;
    [_tableView reloadData];
}

-(void)isFinishGetDataCatalogs:(BOOL)isFinish{
    _isDoneRequestCatalog = isFinish;
}

-(void)fetchFormEditProductID:(NSString*)productID{
    
    [self enableButtonBeforeSuccessRequest:NO];
    [_alertProcessing show];

    [RequestAddEditProduct fetchFormEditProductID:productID
                                           shopID:[self getShopID]
                                        onSuccess:^(ProductEditResult * form) {
                                            
                                            [self setProductForm:form];
                                            [self addImageFromURLStrings];
                                            [self enableButtonBeforeSuccessRequest:YES];
                                            [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
                                            
                                        } onFailure:^{
                                            
                                            [self enableButtonBeforeSuccessRequest:YES];
                                            [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
                                            
                                        }];
}

-(void)setProductDetail:(ProductEditDetail*)product{
    _form.product = product;
    
    NSInteger index = [product.product_weight_unit integerValue]-1;
    if (index<0) {
        index = 0;
    }
    _form.product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
    if ([_form.product.product_currency isEqualToString:@"idr"]) {
        _form.product.product_currency = [ARRAY_PRICE_CURRENCY[0]objectForKey:DATA_NAME_KEY];
    }
    if ([_form.product.product_currency isEqualToString:@"usd"]) {
        _form.product.product_currency = [ARRAY_PRICE_CURRENCY[1]objectForKey:DATA_NAME_KEY];
    }

    _form.product.product_short_desc = [product.product_short_desc stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
    
    _minimumOrderTextField.text = _form.product.product_min_order;
    
    if (_form.breadcrumb.count > 0) {
        Breadcrumb *category = [_form.breadcrumb lastObject];
        
        CategoryDetail *filterCategory = [[CategoryDetail alloc] init];
        filterCategory.categoryId = category.department_id;
        filterCategory.name = category.department_name;
        _form.product.product_category = filterCategory;
    }
    
    NSString *priceCurencyID = product.product_currency_id?:@"1";
    NSString *price = product.product_price?:@"";
    
    _productNameTextField.text = product.product_name;
    _productNameBeforeCopy = product.product_name;
    
    _isProductNameEditable = [product.product_name_editable isEqualToString:@"1"];
    
    _productNameTextField.enabled = (_type ==TYPE_ADD_EDIT_PRODUCT_ADD || _type == TYPE_ADD_EDIT_PRODUCT_COPY || _isProductNameEditable)?YES:NO;
    
    CGFloat priceInteger = [price floatValue];
    if ([priceCurencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH)
        price = (priceInteger>0)?[[NSNumberFormatter IDRFormatterWithoutCurency] stringFromNumber:@(priceInteger)]:@"";
    else
        price = [[NSNumberFormatter USDFormatter] stringFromNumber:@(priceInteger)];

    _productPriceTextField.text = price;
    _productWeightTextField.text = product.product_weight?:@"";
    _form.product.product_returnable = ([_form.info.product_returnable integerValue]==3)?@"0":_form.info.product_returnable;
    
    _form.product.product_catalog = _form.catalog;
}

-(void)setProductForm:(ProductEditResult*)form{
    _form = form;
    
    [self setProductDetail:_form.product];
    
    [self fetchGetCatalogWithProductName:_productNameTextField.text andDepartmentID:_form.product.product_category.categoryId];
    
    [_tableView reloadData];
}

-(void)addImageFromURLStrings{
    
    NSArray <ProductEditImages*> *selectedImagesEditProduct = _form.product_images;
    for (int i = 0; i< selectedImagesEditProduct.count ; i++) {
        if (i < _addImageButtons.count) {
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:selectedImagesEditProduct[i].image_src_300] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            [_addImageButtons[i] setBackgroundImageForState:UIControlStateNormal
                                             withURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]
                                                    success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
                                                        
                                                        selectedImagesEditProduct[i].image = image;
                                                        [self setImageButtons];
                                                        
                                                    } failure:nil];
        }
    }
}

-(void)addImageFromAsset{
    
    NSArray <ProductEditImages*> *selectedImagesEditProduct = _form.product_images;
    
    NSMutableArray <ProductEditImages*>*selectedImages = [[NSMutableArray alloc]initWithArray:selectedImagesEditProduct];
    
    for (ProductEditImages *selected in selectedImagesEditProduct) {
        if (selected.isFromAsset) {
            [selectedImages removeObject:selected];
        }
    }
    for (DKAsset* selectedImage in _selectedAsset) {
        ProductEditImages *imageObject = [ProductEditImages new];
        imageObject.image = selectedImage.resizedImage;
        imageObject.isFromAsset = YES;
        imageObject.asset = selectedImage;
        imageObject.image_primary = ([self isDefaultImage:selectedImage])?@"1":@"";
        
        [selectedImages addObject:imageObject];
    }
    
    _form.product_images = [selectedImages copy];
    
    [self setImageButtons];
}

-(void)setImageButtons{
    for (UIButton *button in _addImageButtons) {
        button.hidden = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
    }
    for (int i = 0; i<_form.product_images.count; i++) {
        if (i<_addImageButtons.count) {
            ((UIButton*)_addImageButtons[i]).hidden = NO;
            [_addImageButtons[i] setBackgroundImage:_form.product_images[i].image forState:UIControlStateNormal];
            ((UILabel*)_defaultImageLabels[i]).hidden = !([_form.product_images[i].image_primary boolValue]);
        }
    }
    if (_form.product_images.count<_addImageButtons.count) {
        UIButton *uploadedButton = (UIButton*)_addImageButtons[_form.product_images.count];
        uploadedButton.hidden = NO;
        
        _productImageScrollView.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, 0);
    }
}

-(UserAuthentificationManager *)authManager{
    if (!_authManager) {
        _authManager = [UserAuthentificationManager new];
    }
    return _authManager;
}

-(NSString *)getShopID{
    return [[self authManager] getShopId];
}

#pragma mark - Delegate

- (void)didSelectCategory:(CategoryDetail *)category {
    _form.product.product_category = category;
    if (_type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        [secureStorage setKeychainWithValue:category.categoryId withKey:LAST_CATEGORY_VALUE];
        [secureStorage setKeychainWithValue:category.name withKey:LAST_CATEGORY_NAME];
    }
    [self fetchGetCatalogWithProductName:_productNameTextField.text andDepartmentID:_form.product.product_category.categoryId];
    [self.tableView reloadData];
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_productNameTextField resignFirstResponder];
    switch (alertView.tag) {
        case 11:
        {
            //price curency
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            NSDictionary* auth = [secureStorage keychainDictionary];
            BOOL isGoldShop = [[auth objectForKey:kTKPD_SHOPISGOLD]boolValue];
            
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            
            NSInteger previousValue = [_form.product.product_currency_id integerValue];
            
            NSInteger value = [[ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_VALUE_KEY] integerValue];
            NSString *name = [ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_NAME_KEY];
            
            if ( value == PRICE_CURRENCY_ID_USD && !isGoldShop) {
                NSArray *errorMessage = @[ERRORMESSAGE_INVALID_PRICE_CURRENCY_USD];
                StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
                [alert show];
            }
            else{
                if (value != previousValue) {
                    _productPriceTextField.text = @"";
                    _form.product.product_price = @"";
                }
                ProductEditDetail *product = _form.product;
                product.product_currency_id = [[ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_VALUE_KEY] stringValue];
                product.product_currency = name;
                [_tableView reloadData];
                
            }
            break;
        }
        case 12:
        {
            //weight curency
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [[ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_VALUE_KEY] stringValue];
            NSString *name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
            ProductEditDetail *product = _form.product;
            product.product_weight_unit_name = name;
            product.product_weight_unit = value;
            [_tableView reloadData];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _productNameTextField) {
        if (_type == TYPE_ADD_EDIT_PRODUCT_EDIT && !_isProductNameEditable) {
            UIAlertView *editableNameProductAlert = [[UIAlertView alloc]initWithTitle:nil message:ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [editableNameProductAlert show];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    ProductEditDetail *product = _form.product;
    if (textField == _productNameTextField) {
        product.product_name = textField.text;
        [self fetchGetCatalogWithProductName:textField.text andDepartmentID:product.product_category.categoryId];

    }
    if (textField == _productPriceTextField) {
        NSString *productPrice;
        NSInteger currency = [_form.product.product_currency_id integerValue];
        BOOL isIDRCurrency = (currency == PRICE_CURRENCY_ID_RUPIAH);
        if (isIDRCurrency)
            productPrice = [[[NSNumberFormatter IDRFormatterWithoutCurency] numberFromString:textField.text] stringValue];
        else
            productPrice = [[[NSNumberFormatter USDFormatter] numberFromString:textField.text] stringValue];
        product.product_price = productPrice;
    }
    if (textField == _productWeightTextField) {
        product.product_weight = textField.text;
    }
    if (textField == _minimumOrderTextField) {
        product.product_min_order = textField.text;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ProductEditDetail *product = _form.product;
    BOOL isIDRCurrency = ([product.product_currency_id integerValue] == PRICE_CURRENCY_ID_RUPIAH);
    if (textField == _productPriceTextField) {
        if (isIDRCurrency) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([string length]==0)
            {
                [formatter setGroupingSeparator:@"."];
                [formatter setGroupingSize:4];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
                return YES;
            }
            else {
                [formatter setGroupingSeparator:@"."];
                [formatter setGroupingSize:2];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                if(![num isEqualToString:@""])
                {
                    num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                    textField.text = str;
                }
                return YES;
            }
        }
        else
        {
            NSString *cleanCentString = [[textField.text
                                          componentsSeparatedByCharactersInSet:
                                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                         componentsJoinedByString:@""];
            // Parse final integer value
            NSInteger centAmount = cleanCentString.integerValue;
            // Check the user input
            if (string.length > 0){
                // Digit added
                centAmount = centAmount * 10 + string.integerValue;
            } else {
                // Digit deleted
                centAmount = centAmount / 10;
            }
            // Update call amount value
            NSNumber *amount = [[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f];
            // Write amount with currency symbols to the textfield
            textField.text = [[NSNumberFormatter USDFormatter] stringFromNumber:amount];
            return NO;
        }
    }
    else if (textField == _productNameTextField) {
#define PRODUCT_NAME_CHARACTER_LIMIT 70
        return textField.text.length + (string.length - range.length) <= PRODUCT_NAME_CHARACTER_LIMIT;
    }
    else
        return YES;
}

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    for (CatalogList *catalog in _catalogs) {
        if ([catalog.catalog_name isEqualToString:object]) {
            _form.product.product_catalog = catalog;
        }
    }
    
    [_tableView reloadData];
}

-(void)DidEditReturnableNote
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:SHOULD_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME object:nil];
}


#pragma mark - Methods

-(void)setDefaultForm{
    
    _form = [ProductEditResult new];

    ProductEditDetail *product = [ProductEditDetail new];
    product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_NAME_KEY];
    product.product_weight_unit = [[ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_VALUE_KEY] stringValue];
    
    product.product_currency = [ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_NAME_KEY];
    product.product_currency_id = [[ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_VALUE_KEY] stringValue];
    
    product.product_min_order = @"1";
    product.product_condition = [[ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_VALUE_KEY] stringValue];
    
    CategoryDetail *lastCategory = [[self authManager] getLastProductAddCategory];
    product.product_category = lastCategory?:[CategoryDetail new];
    
    [self setProductDetail:product];
}

- (BOOL)dataInputIsValid
{    
    FormProductValidation *validation = [FormProductValidation new];
    BOOL isValid = [validation isValidFormFirstStep:_form type:_type productNameBeforeCopy:_productNameBeforeCopy];
    
    return isValid;
}

-(void)enableButtonBeforeSuccessRequest:(BOOL)isEnable
{
    _nextBarButtonItem.enabled = isEnable;
    
    _minimumOrderTextField.userInteractionEnabled = isEnable;
    _productPriceTextField.userInteractionEnabled = isEnable;
    _productWeightTextField.userInteractionEnabled = isEnable;    
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _productPriceTextField) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (_activeTextField == _productWeightTextField)
    {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
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
@end