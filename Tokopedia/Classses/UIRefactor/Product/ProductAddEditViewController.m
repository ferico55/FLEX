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
#import "category.h"
#import "camera.h"
#import "GenerateHost.h"
#import "UploadImage.h"
#import "ShopSettings.h"
#import "CatalogAddProduct.h"
#import "ManageProduct.h"
#import "AlertPickerView.h"
#import "ProductAddEditViewController.h"
#import "ProductAddEditDetailViewController.h"
#import "ProductEditImageViewController.h"
#import "CategoryMenuViewController.h"
#import "URLCacheController.h"
#import "StickyAlertView.h"
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "UserAuthentificationManager.h"
#import "TKPDPhotoPicker.h"
#import "FilterCategoryViewController.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "Tokopedia-Swift.h"

#define DATA_SELECTED_BUTTON_KEY @"data_selected_button"

@implementation SelectedImage


@end

#pragma mark - Setting Add Product View Controller
@interface ProductAddEditViewController ()
<
UITextFieldDelegate,
UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
TKPDAlertViewDelegate,
CategoryMenuViewDelegate,
ProductEditDetailViewControllerDelegate,
ProductEditImageViewControllerDelegate,
GenerateHostDelegate,
CameraCollectionViewControllerDelegate,
RequestUploadImageDelegate,
TKPDPhotoPickerDelegate,
GeneralTableViewControllerDelegate,
FilterCategoryViewDelegate
>
{
    NSMutableDictionary *_dataInput;
    NSMutableArray *_productImageURLs;
    NSMutableArray *_productImageIDs;
    NSMutableArray *_productImageDesc;
    
    UITextField *_activeTextField;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    GenerateHost *_generateHost;
    UploadImage *_images;
    ProductEditResult *_editProductForm;
    ProductEditDetail *_product;
    NSArray<CatalogList*> *_catalogs;
    
    UIBarButtonItem *_nextBarButtonItem;
    BOOL _isFinishedUploadImages;
    NSDictionary *_auth;
    UserAuthentificationManager *_authManager;
    
    BOOL _isBeingPresented;
    
    NSMutableArray <SelectedImage*>*_selectedImages;
    NSMutableArray <DKAsset*>*_selectedAsset;
    DKAsset *_defaultImage;
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    
    ProductAddEditDetailViewController *_detailVC;
    
    UIAlertView *_alertProcessing;
    
    BOOL _isCatalog;
    
    NSString *_productNameBeforeCopy;
    
    BOOL _isDoneRequestCatalog;
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
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumbProductImageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *defaultImageLabels;
@property (weak, nonatomic) IBOutlet UILabel *catalogLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actCatalog;

@property (weak, nonatomic) IBOutlet UIView *productNameViewCell;

@end

@implementation ProductAddEditViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addImageButtons = [NSArray sortViewsWithTagInArray:_addImageButtons];
    _thumbProductImageViews = [NSArray sortViewsWithTagInArray:_thumbProductImageViews];
    _defaultImageLabels = [NSArray sortViewsWithTagInArray:_defaultImageLabels];
    _section1TableViewCell = [NSArray sortViewsWithTagInArray:_section1TableViewCell];
    _section2TableViewCell = [NSArray sortViewsWithTagInArray:_section2TableViewCell];
    _section3TableViewCell = [NSArray sortViewsWithTagInArray:_section3TableViewCell];
    
    _dataInput = [NSMutableDictionary new];
    _selectedImages = [NSMutableArray new];
    _selectedAsset = [NSMutableArray new];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _alertProcessing = [[UIAlertView alloc]initWithTitle:nil message:@"Processing" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
        barButtonItem.tag = 10;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    } else {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
        barButtonItem.tag = 10;
        self.navigationItem.backBarButtonItem = barButtonItem;
    }
    
    _nextBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                          style:UIBarButtonItemStyleDone
                                                         target:(self)
                                                         action:@selector(onTapNextButton:)];
    _nextBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _nextBarButtonItem;
    
    [self setDefaultData:_data];
    
    _authManager = [UserAuthentificationManager new];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY)
    {
        [self fetchFormEditProductID:[self getProductID]];
    }
    else if(type == TYPE_ADD_EDIT_PRODUCT_ADD)
    {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        CategoryDetail *lastCategory = [auth getLastProductAddCategory];
        if (lastCategory) {
            _product.product_category = lastCategory;
        }
    }
    
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
        _productNameTextField.enabled = NO;
    }
    
    [_productImageScrollView addSubview:_productImagesContentView];
}

-(NSString *)getProductID{
    NSString *productID = @"";
    if ([[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] isKindOfClass:[NSNumber class]]) {
        productID = [[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] stringValue];
    } else {
        productID = [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY];
    };
    return productID;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // keyboard notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    switch (type) {
        case TYPE_ADD_EDIT_PRODUCT_ADD:
            self.title = @"Tambah Produk";
            break;
        case TYPE_ADD_EDIT_PRODUCT_EDIT:
            self.title = @"Ubah Produk";
            break;
        case TYPE_ADD_EDIT_PRODUCT_COPY:
            self.title = @"Salin Produk";
            break;
        default:
            break;
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _productImageScrollView.contentSize = _productImagesContentView.frame.size;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.title = @"";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    
    _detailVC = nil;
}

#pragma mark - View Action

-(void)onTapNextButton:(UIBarButtonItem*)button{
    if ([self dataInputIsValid]) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        UserAuthentificationManager *authManager = [UserAuthentificationManager new];
        NSString *shopHasTerm = [authManager getShopHasTerm];
        _editProductForm.info.shop_has_terms = shopHasTerm;
        if (!_detailVC)_detailVC = [ProductAddEditDetailViewController new];
        _detailVC.title = self.title;
        _detailVC.product = _product;
        _detailVC.type = type;
        _detailVC.dataInput = _dataInput;
        _detailVC.selectedImages = _selectedImages;
        _detailVC.shopHasTerm = _editProductForm.info.shop_has_terms?:@"";
        _detailVC.returnableStatus = _editProductForm.info.product_returnable?:@"0";
        _detailVC.delegate = self;
        BOOL isShopHasTerm = ([_editProductForm.info.shop_has_terms isEqualToString:@""]||[_editProductForm.info.shop_has_terms isEqualToString:@"0"])?NO:YES;
        _detailVC.isShopHasTerm = isShopHasTerm;
        
        [self.navigationController pushViewController:_detailVC animated:YES];
    }
}

-(IBAction)tap:(id)sender
{
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
            {
                if (self.navigationItem.leftBarButtonItem) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            }
            case 11:
            {

                break;
            }
            default:
                break;
        }
    }
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
    return (button.tag != _selectedImages.count+1);
}

-(void)editImageDetailAtIndex:(NSUInteger)index{

    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    BOOL isDefaultImage = [_selectedImages[index].imagePrimary boolValue];

    ProductEditImageViewController *vc = [ProductEditImageViewController new];
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY : _productImageURLs[index]?:@"",
                kTKPDDETAIL_DATAINDEXKEY : @(index),
                DATA_IS_DEFAULT_IMAGE : @(isDefaultImage),
                DATA_PRODUCT_IMAGE_NAME_KEY : _productImageDesc[index]?:@"",
                };
    vc.uploadedImage = _selectedImages[index].image;
    vc.delegate = self;
//    vc.selectedImage = _selectedImages[index];
    vc.isDefaultFromWS = (type == TYPE_ADD_EDIT_PRODUCT_EDIT && index == 0);
    vc.type = type;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)selectImageFromCameraOrAlbum{
    __weak typeof(self) wself = self;
    [ImagePickerController showImagePicker:self
                                 assetType:DKImagePickerControllerAssetTypeallPhotos
                       allowMultipleSelect:YES
                                showCancel:YES
                                showCamera:YES
                               maxSelected:5 - (_selectedImages.count-_selectedAsset.count)
                            selectedAssets:_selectedAsset
                                completion:^(NSArray<DKAsset *> *asset) {
                                    [wself setSelectedAsset:asset];
                                    [wself addImageFromAsset];
                                }];
}

-(void)setSelectedAsset:(NSArray<DKAsset*>*)selectedAsset{
    [_selectedAsset removeAllObjects];
    [_selectedAsset addObjectsFromArray:selectedAsset];
}

-(BOOL)isDefaultImage:(DKAsset*)image{
    if (_defaultImage == nil) {
        return ([image isEqual:_selectedAsset.firstObject]);
    }
    return ([image isEqual:_defaultImage]);
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
    ProductEditDetail *product = _product;
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0TableViewCell[indexPath.row];
            break;
        case 1:
            cell = _section1TableViewCell[indexPath.row];
            if (indexPath.row == BUTTON_PRODUCT_PRODUCT_NAME) {
                NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
                    _productNameViewCell.hidden = NO;
                }
            }
            if (indexPath.row == BUTTON_PRODUCT_CATEGORY) {
                NSString *departmentTitle = @"Pilih Kategori";
                if (product.product_category) {
                    CategoryDetail *category =product.product_category;
                    departmentTitle = category.name;
                } else {
                    departmentTitle = @"Pilih Kategori";
                }
                cell.detailTextLabel.text = departmentTitle;
            }
            if (indexPath.row == BUTTON_PRODUCT_CATALOG) {
                _catalogLabel.text = product.product_catalog.catalog_name?:@"Pilih Katalog";
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
            if (!_isCatalog && indexPath.row == BUTTON_PRODUCT_CATALOG) {
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
    [_activeTextField resignFirstResponder];
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case BUTTON_PRODUCT_PRODUCT_NAME:
                {
                    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
//                        _productNameTextField.enabled = NO;
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
                    controller.selectedCategory = _product.product_category;
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
                        catalogVC.selectedObject = _product.product_catalog.catalog_name?:@"";
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
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
    
    _isCatalog = (_catalogs.count>0);
    [_tableView reloadData];

}

-(void)isFinishGetDataCatalogs:(BOOL)isFinish{
    _isDoneRequestCatalog = isFinish;
    if (isFinish) {
        [_actCatalog stopAnimating];
    }else {
        [_actCatalog startAnimating];
    }
}

-(void)fetchFormEditProductID:(NSString*)productID{
    
    [self enableButtonBeforeSuccessRequest:NO];
    [_alertProcessing show];

    [RequestAddEditProduct fetchFormEditProductID:productID
                                           shopID:[self getShopID]
                                        onSuccess:^(ProductEditResult * form) {
                                            
                                            [self setEditProductForm:form];
                                            [self addImageFromForm];
                                            [self enableButtonBeforeSuccessRequest:YES];
                                            [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
                                            
                                        } onFailure:^{
                                            
                                            [self enableButtonBeforeSuccessRequest:YES];
                                            [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
                                            
                                        }];
}

-(void)fetchDeleteProductPictID:(NSString*)pictureID productID:(NSString*)productID shopID:(NSString*)shopID{
    
    [RequestAddEditProduct fetchDeleteProductPictID:pictureID
                                          productID:productID
                                             shopID:shopID onSuccess:^{
                                                 
                                                 NSArray *objectProductPhoto = _productImageIDs;
                                                 NSMutableArray *photos = [NSMutableArray new];
                                                 for (NSString *photo in objectProductPhoto) {
                                                     if (![photo isEqualToString:@""]) {
                                                         [photos addObject:photo];
                                                     }
                                                 }
                                                 objectProductPhoto = [photos copy];
                                                 NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
                                                 [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
                                                 
                                             } onFailure:^{
                                                 
                                                 [self cancelDeletedImage];
                                                 
                                             }];
}

-(void)setProductDetail:(ProductEditDetail*)product{
    _product = product;
    
    NSInteger index = [product.product_weight_unit integerValue]-1;
    if (index<0) {
        index = 0;
    }
    _product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
    if ([_product.product_currency isEqualToString:@"idr"]) {
        _product.product_currency = [ARRAY_PRICE_CURRENCY[0]objectForKey:DATA_NAME_KEY];
    }
    if ([_product.product_currency isEqualToString:@"usd"]) {
        _product.product_currency = [ARRAY_PRICE_CURRENCY[1]objectForKey:DATA_NAME_KEY];
    }

    _product.product_short_desc = [product.product_short_desc stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
    
    _minimumOrderTextField.text = product.product_min_order;
    
    if (_editProductForm.breadcrumb.count > 0) {
        Breadcrumb *category = [_editProductForm.breadcrumb lastObject];
        
        CategoryDetail *filterCategory = [[CategoryDetail alloc] init];
        filterCategory.categoryId = category.department_id;
        filterCategory.name = category.department_name;
        _product.product_category = filterCategory;
    }
    
    NSString *priceCurencyID = product.product_currency_id?:@"1";
    NSString *price = product.product_price?:@"";
    NSString *weight = product.product_weight?:@"";
    
    _productNameTextField.text = product.product_name;
    _productNameBeforeCopy = product.product_name;
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    _productNameTextField.enabled = (type ==TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?YES:NO;
    
    CGFloat priceInteger = [price floatValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if ([priceCurencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
        price = (priceInteger>0)?[[NSNumberFormatter IDRFormarter] stringFromNumber:@(priceInteger)]:@"";
    }
    else
    {
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setCurrencyCode:@"USD"];
        [formatter setNegativeFormat:@"-¤#,##0.00"];
        price = [formatter stringFromNumber:@(priceInteger)];
        
    }
    
    _productPriceTextField.text = price;
    _productWeightTextField.text = weight;
}

-(void)setEditProductForm:(ProductEditResult*)form{
    _editProductForm = form;
    
    [self setProductDetail:_editProductForm.product];
    
    [self fetchGetCatalogWithProductName:_productNameTextField.text andDepartmentID:_product.product_category.categoryId];
    
    if(_detailVC)
    {
        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        NSString *defaultImagePath = [_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
        if (!defaultImagePath) {
            defaultImagePath = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)? [_productImageURLs firstObject]:[_productImageIDs firstObject];
            [_dataInput setObject:defaultImagePath forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
        }
        _detailVC.data = @{kTKPD_AUTHKEY : auth?:@{},
                           DATA_INPUT_KEY : _dataInput,
                           DATA_SHOP_HAS_TERM_KEY:_editProductForm.info.shop_has_terms?:@""
                           };
        _detailVC.shopHasTerm = _editProductForm.info.shop_has_terms;
        _detailVC.product = _product;
        _detailVC.delegate = self;
        
        //_detailVC.isNeedRequestAddProductPicture = YES;
    }
    
    
    [_tableView reloadData];
}

-(void)addImageFromForm{
    
    NSArray <ProductEditImages*> *selectedImagesEditProduct = _editProductForm.product_images;

    for (ProductEditImages* selectedImage in selectedImagesEditProduct) {
        SelectedImage *imageObject = [SelectedImage new];
        
        UIImageView *thumb = [UIImageView new];
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:selectedImage.image_src_300] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            imageObject.image = image;
            [self setImageButtons];
        } failure:nil];
        
        imageObject.desc = selectedImage.description?:@"";
        imageObject.imageID = selectedImage.image_id?:@"";
        imageObject.imagePrimary = selectedImage.image_primary;
        
        [_selectedImages addObject:imageObject];
    }
    
    [self setImageButtons];
}

-(void)addImageFromAsset{
    
    NSMutableArray *tempSelected = [_selectedImages mutableCopy];
    for (SelectedImage *selected in _selectedImages) {
        if (selected.isFromAsset) {
            [tempSelected removeObject:selected];
        }
    }
    
    [_selectedImages removeAllObjects];
    [_selectedImages addObjectsFromArray:tempSelected];
    
    for (DKAsset* selectedImage in _selectedAsset) {
        SelectedImage *imageObject = [SelectedImage new];
        imageObject.image = selectedImage.resizedImage;
        imageObject.desc = selectedImage.description?:@"";
        imageObject.imageID = @"";
        imageObject.isFromAsset = YES;
        imageObject.imagePrimary = ([self isDefaultImage:selectedImage])?@"1":@"";
        
        [_selectedImages addObject:imageObject];
    }
    
    [self setImageButtons];
}

-(void)setImageButtons{
    for (UIButton *button in _addImageButtons) {
        button.hidden = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
    }
    for (int i = 0; i<_selectedImages.count; i++) {
        ((UIButton*)_addImageButtons[i]).hidden = NO;
        
        [_addImageButtons[i] setBackgroundImage:_selectedImages[i].image forState:UIControlStateNormal];
        
    }
    if (_selectedImages.count<_addImageButtons.count) {
        UIButton *uploadedButton = (UIButton*)_addImageButtons[_selectedImages.count];
        uploadedButton.hidden = NO;
        
        //        _scrollViewUploadPhoto.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, 0);
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
    _product.product_category = category;
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY] integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        [secureStorage setKeychainWithValue:category.categoryId withKey:LAST_CATEGORY_VALUE];
        [secureStorage setKeychainWithValue:category.name withKey:LAST_CATEGORY_NAME];
    }
    [self.tableView reloadData];
}

-(void)setDefaultImage:(DKAsset *)defaultImage{
    _defaultImage = defaultImage;
}

-(void)deleteImage:(DKAsset *)image{
//    [_selectedImages removeObject:image];
}


-(void)setProductImageName:(NSString *)name atIndex:(NSInteger)index
{
    [_productImageDesc replaceObjectAtIndex:index withObject:name];
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD||type == TYPE_ADD_EDIT_PRODUCT_COPY) {
        NSMutableArray *photos = [NSMutableArray new];
        for (NSString *photo in _productImageDesc) {
            if (![photo isEqualToString:@""]) {
                [photos addObject:photo];
            }
        }
        NSString *stringImageName = [[photos valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageName forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    }
    else
    {
        NSInteger imageID =[_productImageIDs[index] integerValue];
        NSString *imageDescriptionKey = [NSString stringWithFormat:API_PRODUCT_IMAGE_DESCRIPTION_KEY@"%zd",imageID];
        NSDictionary *imageNames = [_dataInput objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
        NSMutableDictionary *ImageNameDictionary = [NSMutableDictionary new];
        [ImageNameDictionary addEntriesFromDictionary:imageNames];
        [ImageNameDictionary setObject:name forKey:imageDescriptionKey];
        [_dataInput setObject:ImageNameDictionary forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
    }
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
            
            NSInteger previousValue = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
            
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
                }
                ProductEditDetail *product = _product;
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
            ProductEditDetail *product = _product;
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
    _activeTextField = textField;
    if (textField == _productNameTextField) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
            UIAlertView *editableNameProductAlert = [[UIAlertView alloc]initWithTitle:nil message:ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [editableNameProductAlert show];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    ProductEditDetail *product = _product;
    if (textField == _productNameTextField) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        [self fetchGetCatalogWithProductName:textField.text andDepartmentID:_product.product_category.categoryId];
        if (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
            product.product_name = textField.text;
        }
    }
    if (textField == _productPriceTextField) {
        NSString *productPrice;
        NSInteger currency = [[_dataInput objectForKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY]integerValue];
        BOOL isIDRCurrency = (currency == PRICE_CURRENCY_ID_RUPIAH);
        if (isIDRCurrency)
        {
            productPrice = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            productPrice = [productPrice stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        else
        {
            NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [currencyFormatter setCurrencyCode:@"USD"];
            [currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
            productPrice = [[currencyFormatter numberFromString:textField.text] stringValue];
        }
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
    ProductEditDetail *product = _product;
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
            if (string.length > 0)
            {
                // Digit added
                centAmount = centAmount * 10 + string.integerValue;
            }
            else
            {
                // Digit deleted
                centAmount = centAmount / 10;
            }
            // Update call amount value
            NSNumber *amount = [[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f];
            // Write amount with currency symbols to the textfield
            NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [currencyFormatter setCurrencyCode:@"USD"];
            [currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
            textField.text = [currencyFormatter stringFromNumber:amount];
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

#pragma mark - Product Edit Detail Delegate
-(void)ProductEditDetailViewController:(ProductAddEditDetailViewController *)cell withUserInfo:(NSDictionary *)userInfo
{
    NSDictionary *updatedDataInput = [userInfo objectForKey:DATA_INPUT_KEY];
    
    [_dataInput removeAllObjects];
    [_dataInput addEntriesFromDictionary:updatedDataInput];
}

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    for (CatalogList *catalog in _catalogs) {
        if ([catalog.catalog_name isEqualToString:object]) {
            _product.product_catalog = catalog;
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

- (void) setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        switch (type) {
            case TYPE_ADD_EDIT_PRODUCT_ADD:
            {
                self.title =  TITLE_ADD_PRODUCT;
                [_dataInput setObject:@(PRICE_CURRENCY_ID_RUPIAH) forKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY];
                
                [_tableView reloadData];
                break;
            }
            case TYPE_ADD_EDIT_PRODUCT_EDIT:
                self.title = TITLE_EDIT_PRODUCT;
                break;
            case TYPE_ADD_EDIT_PRODUCT_COPY:
                self.title = TITLE_SALIN_PRODUCT;
                break;
            default:
                break;
        }

        ProductEditDetail *product = [ProductEditDetail new];
        product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_NAME_KEY];
        product.product_weight_unit = [[ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_VALUE_KEY] stringValue];
        
        product.product_currency = [ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_NAME_KEY];
        product.product_currency_id = [[ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_VALUE_KEY] stringValue];
        
        product.product_min_order = @"1";
        product.product_condition = [[ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_VALUE_KEY] stringValue];
        
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        CategoryDetail *lastCategory = [auth getLastProductAddCategory];
        if (lastCategory) {
            product.product_category = lastCategory;
        }
        
        [self setProductDetail:product];
    }
}

- (BOOL)dataInputIsValid
{
    NSMutableArray *errorMessage = [NSMutableArray new];
    BOOL isValid = YES;
    BOOL isValidPrice = YES;
    BOOL isValidWeight = YES;

    BOOL isValidImage = _selectedImages.count>0;
    
    ProductEditDetail *product = _product?:[ProductEditDetail new];
    NSString *productName = product.product_name;
    NSString *productPrice = product.product_price;
    NSString *productPriceCurrencyID = product.product_currency_id;
    NSString *productWeight = product.product_weight;
    NSString *productWeightUnitID = product.product_weight_unit;
    
    CategoryDetail *category = _product.product_category;
    NSString *departmentID = category.categoryId?: @"";
    
    BOOL isPriceCurrencyRupiah = ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH);
    BOOL isPriceCurrencyUSD = ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_USD);
    
    BOOL isWeightUnitGram = ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_GRAM);
    BOOL isWeightUnitKilogram = ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_KILOGRAM);
    
    if (productName && ![productName isEqualToString:@""] &&
        productPrice>0 &&
        productWeight>0 &&
        ![departmentID isEqualToString:@""]) {
        
        if (isPriceCurrencyRupiah && [productPrice integerValue]>=MINIMUM_PRICE_RUPIAH &&
            [productPrice integerValue]<=MAXIMUM_PRICE_RUPIAH)
            isValidPrice = YES;
        else if (isPriceCurrencyUSD && [productPrice floatValue]>=MINIMUM_PRICE_USD &&
                 [productPrice floatValue]<=MAXIMUM_PRICE_USD)
            isValidPrice = YES;
        else
            isValidPrice = NO;
        
        if (isWeightUnitGram &&
            [productWeight integerValue]>=MINIMUM_WEIGHT_GRAM &&
            [productWeight integerValue]<=MAXIMUM_WEIGHT_GRAM)
            isValidWeight = YES;
        else if (isWeightUnitKilogram && [productWeight integerValue]>=MINIMUM_WEIGHT_KILOGRAM &&
                 [productWeight integerValue]<=MAXIMUM_WEIGHT_KILOGRAM)
            isValidWeight = YES;
        else
            isValidWeight = NO;
    }
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_COPY && [productName isEqualToString:_productNameBeforeCopy]) {
        [errorMessage addObject:@"Tidak dapat menyalin dengan Nama Produk yang sama."];
        isValid = NO;
    }
    
    if ( !productName || [productName isEqualToString:@""]) {
        [errorMessage addObject:ERRORMESSAGE_NULL_PRODUCT_NAME];
        isValid = NO;
    }
    if (!(productPrice > 0)) {
        [errorMessage addObject:ERRORMESSAGE_NULL_PRICE];
        isValid = NO;
    }
    else
    {
        if ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH &&
            ([productPrice integerValue]<MINIMUM_PRICE_RUPIAH || [productPrice integerValue]>MAXIMUM_PRICE_RUPIAH)) {
            [errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_RUPIAH];
            isValid = NO;
        }
        else if ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_USD &&
                 ([productPrice floatValue]<MINIMUM_PRICE_USD || [productPrice floatValue]>MAXIMUM_PRICE_USD)) {
            [errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_USD];
            isValid = NO;
        }
    }
    if ([departmentID isEqualToString:@""]) {
        [errorMessage addObject:ERRORMESSAGE_NULL_CATEGORY];
        isValid = NO;
    }
    if ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_GRAM &&
        ([productWeight integerValue]<MINIMUM_WEIGHT_GRAM || [productWeight integerValue]>MAXIMUM_WEIGHT_GRAM)) {
        [errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_GRAM];
        isValid = NO;
    }
    else if ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_KILOGRAM &&
             ([productWeight integerValue]<MINIMUM_WEIGHT_KILOGRAM || [productWeight integerValue]>MAXIMUM_WEIGHT_KILOGRAM)) {
        [errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_KILOGRAM];
        isValid = NO;
    }
    
    if ([product.product_min_order integerValue]>=1000) {
        isValid = NO;
        [errorMessage addObject:@"Maksimal minimum pembelian untuk 1 produk adalah 999"];
    }
    
    if (!isValidImage) {
        [errorMessage addObject:ERRORMESSAGE_NULL_IMAGE];
    }
    
    if (errorMessage.count>0) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return (isValidWeight && isValidPrice && isValid && isValidImage);
}

-(void)enableButtonBeforeSuccessRequest:(BOOL)isEnable
{
    _nextBarButtonItem.enabled = isEnable;
    
    _productNameTextField.userInteractionEnabled = isEnable;
    _minimumOrderTextField.userInteractionEnabled = isEnable;
    _productPriceTextField.userInteractionEnabled = isEnable;
    _productWeightTextField.userInteractionEnabled = isEnable;
    
}

-(void)cancelDeletedImage
{
    NSString *deletedImagePath = [_dataInput objectForKey:DATA_LAST_DELETED_IMAGE_PATH];
    NSInteger deletedImageID = [[_dataInput objectForKey:DATA_LAST_DELETED_IMAGE_ID]integerValue];
    NSInteger index = [[_dataInput objectForKey:DATA_LAST_DELETED_INDEX]integerValue];
    UIImage *image = [_dataInput objectForKey:DATA_LAST_DELETED_IMAGE];
    
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ((UIButton*)_addImageButtons[index]).hidden = YES;
    ((UIImageView*)_thumbProductImageViews[index]).image = image;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = NO;
    [_productImageURLs replaceObjectAtIndex:index withObject:deletedImagePath];
    [_productImageIDs replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%zd",deletedImageID]];
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