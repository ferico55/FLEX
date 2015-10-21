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
#import "Product.h"
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
#import "TokopediaNetworkManager.h"
#import "UserAuthentificationManager.h"
#import "TKPDPhotoPicker.h"

#define DATA_SELECTED_BUTTON_KEY @"data_selected_button"

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
    TokopediaNetworkManagerDelegate,
    TKPDPhotoPickerDelegate,
    GeneralTableViewControllerDelegate
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
    
    NSInteger *_requestcountGenerateHost;
    GenerateHost *_generateHost;
    UploadImage *_images;
    Product *_product;
    ShopSettings *_setting;
    CatalogAddProduct *_catalog;
    
    __weak RKObjectManager *_objectmanagerEditProductPicture;
    __weak RKManagedObjectRequestOperation *_requestEditProductPicture;
    
    NSMutableArray *_errorMessage;
    
    NSInteger _requestCount;
    NSInteger _requestcountDeleteImage;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    NSMutableArray *_uploadingImages;
    
    UIBarButtonItem *_nextBarButtonItem;
    BOOL _isFinishedUploadImages;
    NSDictionary *_auth;
    UserAuthentificationManager *_authManager;
    BOOL _isNodata;
    
    BOOL _isBeingPresented;
    
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    
    TokopediaNetworkManager *_networkManager;
    TokopediaNetworkManager *_networkManagerDeleteImage;
    TokopediaNetworkManager *_networkManagerCatalog;
    
    ProductAddEditDetailViewController *_detailVC;

    TKPDPhotoPicker *_photoPicker;
    UIAlertView *_alertProcessing;
    
    CatalogList *_selectedCatalog;
    
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

#define TAG_REQUEST_DETAIL 10
#define TAG_REQUEST_DELETE_IMAGE 11
#define TAG_REQUEST_LIST_CATALOG 12


@implementation ProductAddEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isFinishedUploadImages = YES;
    }
    return self;
}

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
    _errorMessage = [NSMutableArray new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _uploadingImages = [NSMutableArray new];
    
    _selectedImagesCameraController = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _productImageURLs = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _productImageIDs = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _productImageDesc = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _networkManager.tagRequest = TAG_REQUEST_DETAIL;
    _networkManager.delegate = self;
    
    _networkManagerDeleteImage = [TokopediaNetworkManager new];
    _networkManagerDeleteImage.tagRequest = TAG_REQUEST_DELETE_IMAGE;
    _networkManagerDeleteImage.delegate = self;
    
    _networkManagerCatalog = [TokopediaNetworkManager new];
    _networkManagerCatalog.tagRequest = TAG_REQUEST_LIST_CATALOG;
    _networkManagerCatalog.delegate = self;
    
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
                                                         action:@selector(tap:)];
    _nextBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _nextBarButtonItem;
    
    for (UIButton *buttonAdd in _addImageButtons) {
        buttonAdd.enabled = NO;
    }
    
    [_thumbProductImageViews makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
    for (UIImageView *productImageView in _thumbProductImageViews) {
        productImageView.userInteractionEnabled = NO;
        productImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    [self setDefaultData:_data];
    
    _authManager = [UserAuthentificationManager new];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY)
    {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager .tagRequest = TAG_REQUEST_DETAIL;
        [_networkManager doRequest];
    }
    else if(type == TYPE_ADD_EDIT_PRODUCT_ADD)
    {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        Breadcrumb *lastCategory = [auth getLastProductAddCategory];
        [_dataInput setObject:lastCategory forKey:DATA_CATEGORY_KEY];
    }
    
    RequestGenerateHost *generateHost =[RequestGenerateHost new];
    [generateHost configureRestkitGenerateHost];
    [generateHost requestGenerateHost];
    generateHost.delegate = self;
    
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
        _productNameTextField.enabled = NO;
    }
    
    [_productImageScrollView addSubview:_productImagesContentView];
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
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
    
    _detailVC = nil;
}

#pragma mark - View Action
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
                if (!_isFinishedUploadImages) {
                    NSArray *errorMessage = @[ERRORMESSAGE_PROCESSING_UPLOAD_IMAGE];
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
                    [alert show];
                }
                else{
                    if ([self dataInputIsValid]) {
                        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
                        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                        id productDetail = [_data objectForKey:DATA_PRODUCT_DETAIL_KEY]?:@"";
                        NSString *defaultImagePath = [_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                        if (!defaultImagePath) {
                            defaultImagePath = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)? [_productImageURLs firstObject]:[_productImageIDs firstObject];
                            [_dataInput setObject:defaultImagePath forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                        }
                        UserAuthentificationManager *authManager = [UserAuthentificationManager new];
                        NSString *shopHasTerm = [authManager getShopHasTerm];
                        _product.result.info.shop_has_terms = shopHasTerm;
                        
                        if (!_detailVC)_detailVC = [ProductAddEditDetailViewController new];
                        _detailVC.title = self.title;
                        _detailVC.data = @{kTKPD_AUTHKEY : auth?:@{},
                                           DATA_INPUT_KEY : _dataInput?:@{},
                                           DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(type),
                                           DATA_PRODUCT_DETAIL_KEY: productDetail,
                                           DATA_SHOP_HAS_TERM_KEY:_product.result.info.shop_has_terms?:@"0",
                                           @"Image_desc_array":_productImageDesc?:@[]
                                            };
                        _detailVC.shopHasTerm = _product.result.info.shop_has_terms?:@"";
                        _detailVC.generateHost = _generateHost;
                        _detailVC.delegate = self;
                        BOOL isShopHasTerm = ([_product.result.info.shop_has_terms isEqualToString:@""]||[_product.result.info.shop_has_terms isEqualToString:@"0"])?NO:YES;
                        _detailVC.isShopHasTerm = isShopHasTerm;
                        //_detailVC.isNeedRequestAddProductPicture = YES;
                        [self.navigationController pushViewController:_detailVC animated:YES];
                    }
                    else
                    {
                        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:_errorMessage delegate:self];
                        [alert show];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case BUTTON_PRODUCT_CATEGORY:
            {
                Breadcrumb *category = [_dataInput objectForKey:DATA_CATEGORY_KEY];
                CategoryMenuViewController *categoryViewController = [CategoryMenuViewController new];
                NSInteger d_id = [[_data objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY] integerValue];
                categoryViewController.data = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:@(d_id),
                                                DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE:@(CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT)
                                                };
                categoryViewController.selectedCategoryID = [category.department_id integerValue];
                categoryViewController.delegate = self;
                
                UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:categoryViewController];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                
                //[self.navigationController pushViewController:categoryViewController animated:YES];
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
            case 20: // tag 20-24 add product
            case 21:
            case 22:
            case 23:
            case 24:
            {
                NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                if (type == TYPE_ADD_EDIT_PRODUCT_EDIT || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
                    [self didTapImageButtonSingleSelection:(UIButton*)sender];
                }
                else
                    [self didTapImageButton:(UIButton*)sender];
                break;
            }
            default:
                break;
        }
    }
}

-(void)didTapImageButton:(UIButton*)sender
{
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.isAddEditProduct = YES;
    photoVC.tag = sender.tag;
    NSMutableArray *notEmptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _thumbProductImageViews) {
        if (image.image == nil)
        {
            [notEmptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (id selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject: selected];
        }
    }
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    photoVC.maxSelected = 5;

    photoVC.selectedImagesArray = selectedImage;

    selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    photoVC.selectedIndexPath = _selectedIndexPathCameraController;
    
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)didTapImageButtonSingleSelection:(UIButton*)sender
{
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                                  pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    _photoPicker.tag = sender.tag - 20;
    _photoPicker.delegate = self;
}

- (IBAction)gesture:(id)sender
{
    [_activeTextField resignFirstResponder];
    
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (gesture.view.tag > 0) {
                NSInteger indexImage = gesture.view.tag-20;
                NSNumber *defaultImagePath =[_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
                
                NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
                NSNumber *selectedImagePath = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)? _productImageURLs[indexImage]:_productImageIDs[indexImage];
                
                BOOL isDefaultImage;
                if (defaultImagePath)
                    isDefaultImage = [defaultImagePath isEqual:selectedImagePath];
                else
                    isDefaultImage = (gesture.view.tag-20 == 0);
                
                ProductEditImageViewController *vc = [ProductEditImageViewController new];
                vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY : _productImageURLs[indexImage]?:@"",
                            kTKPDDETAIL_DATAINDEXKEY : @(indexImage),
                            DATA_IS_DEFAULT_IMAGE : @(isDefaultImage),
                            DATA_PRODUCT_IMAGE_NAME_KEY : _productImageDesc[indexImage]?:@"",
                            };
                vc.uploadedImage = ((UIImageView*)_thumbProductImageViews[indexImage]).image;
                vc.delegate = self;
                vc.isDefaultFromWS = (type == TYPE_ADD_EDIT_PRODUCT_EDIT && indexImage == 0);
                vc.type = type;
                [self.navigationController pushViewController:vc animated:YES];
            }

            break;
        }
        default:
            break;
    }
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
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isNodata?1:rowCount;
#else
    return _isNodata?0:rowCount;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSDictionary *selectedCategory = [_dataInput objectForKey:DATA_CATEGORY_KEY];
    Breadcrumb *breadcrumb = [_dataInput objectForKey:DATA_CATEGORY_KEY];
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    
    UITableViewCell* cell = nil;
    if (!_isNodata) {
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
                    if (breadcrumb.department_name && ![breadcrumb.department_name isEqualToString:@""]) {
                        departmentTitle = breadcrumb.department_name;
                    }
                    cell.detailTextLabel.text = departmentTitle;
                }
                if (indexPath.row == BUTTON_PRODUCT_CATALOG) {
                    _catalogLabel.text = _selectedCatalog.catalog_name?:@"Pilih Katalog";
                    cell.detailTextLabel.text = _selectedCatalog.catalog_name?:@"Pilih Katalog";
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
                        _productNameTextField.enabled = NO;
                        UIAlertView *editableNameProductAlert = [[UIAlertView alloc]initWithTitle:nil message:ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                        [editableNameProductAlert show];
                    }
                    else
                        [_productNameTextField becomeFirstResponder];
                }
                    break;
                case BUTTON_PRODUCT_CATEGORY:
                {
                    Breadcrumb *category = [_dataInput objectForKey:DATA_CATEGORY_KEY];
                    CategoryMenuViewController *categoryViewController = [CategoryMenuViewController new];
                    NSInteger d_id = [[_data objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY] integerValue];
                    categoryViewController.data = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:@(d_id),
                                                    DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE:@(CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT)
                                                    };
                    categoryViewController.selectedCategoryID = [category.department_id integerValue];
                    categoryViewController.delegate = self;
                    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:categoryViewController];
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                    //[self.navigationController pushViewController:categoryViewController animated:YES];
                    break;
                }
                case BUTTON_PRODUCT_CATALOG:
                {
                    if (_isDoneRequestCatalog) {
                        GeneralTableViewController *catalogVC = [GeneralTableViewController new];
                        catalogVC.delegate = self;
                        NSMutableArray *catalogs =[NSMutableArray new];
                        for (CatalogList *catalog in _catalog.result.list) {
                            [catalogs addObject:catalog.catalog_name];
                        }
                        catalogVC.objects = [catalogs copy];
                        catalogVC.selectedObject = _selectedCatalog.catalog_name?:@"";
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
}

#pragma mark - Request Product Detail

-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_DETAIL) {
        return [self objectManagerDetail];
    }
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        return [self objectManagerDeleteImage];
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        return [self objectManagerCatalog];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_DETAIL) {
        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
        NSInteger productID = [[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]integerValue];
        NSInteger myshopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
        
        NSDictionary* param = @{
                                kTKPDDETAIL_APIACTIONKEY : ACTION_GET_PRODUCT_FORM,
                                kTKPDDETAIL_APIPRODUCTIDKEY : @(productID),
                                kTKPDDETAIL_APISHOPIDKEY : @(myshopID),
                                };
        return param;
    }
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        NSInteger productID = [[_dataInput objectForKey:API_PRODUCT_ID_KEY]integerValue];
        NSInteger myshopID = [[_dataInput objectForKey:kTKPD_SHOPIDKEY]integerValue];
        NSInteger pictureID = [[_dataInput objectForKey:API_PRODUCT_PICTURE_ID_KEY]integerValue];
        NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : ACTION_DELETE_IMAGE,
                                API_PRODUCT_ID_KEY: @(productID),
                                kTKPD_SHOPIDKEY : @(myshopID),
                                API_PRODUCT_PICTURE_ID_KEY:@(pictureID)
                                };
        return param;
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        Breadcrumb *department = [_dataInput objectForKey:DATA_CATEGORY_KEY]?:[Breadcrumb new];
        NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY: ACTION_GET_CATALOG,
                                @"product_name":_productNameTextField.text?:@"",
                                @"product_department_id": department.department_id?:@""
                                };
        return param;
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_DETAIL) {
        return kTKPDDETAILPRODUCT_APIPATH;
    }
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        return kTKPDDETAILACTIONPRODUCT_APIPATH;
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        return kTKDPDETAILCATALOG_APIPATH;
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stats = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_DETAIL) {
        _product = stats;
        return _product.status;
    }
    
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        _setting = stats;
        return _setting.status;
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        _catalog = stats;
        return _catalog.status;
    }
    
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_DETAIL) {
        [self enableButtonBeforeSuccessRequest:NO];
        [_alertProcessing show];
    }
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        _isDoneRequestCatalog = NO;
        [_actCatalog startAnimating];
    }
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_DETAIL) {
        [self enableButtonBeforeSuccessRequest:YES];
        [self requestsuccess:successResult withOperation:operation];
        
        [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        [self requestSuccessDeleteImage:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_LIST_CATALOG) {
        if (_catalog.result.list.count>0) {
            _isCatalog = YES;
            [_tableView reloadData];
        }
        else
        {
            _isCatalog = NO;
            [_tableView reloadData];
        }
        _isDoneRequestCatalog = YES;
        [_actCatalog stopAnimating];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_DELETE_IMAGE) {
        [_networkManagerDeleteImage doRequest];
        [self cancelDeletedImage];
    }
    if (tag == TAG_REQUEST_DETAIL)
    {
        [_alertProcessing dismissWithClickedButtonIndex:0 animated:NO];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self enableButtonBeforeSuccessRequest:YES];
    }
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _product = stats;
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data addEntriesFromDictionary:_data];
        [self setDefaultData:data];
        
        [_networkManagerCatalog doRequest];

        if(_detailVC)
        {
            NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
            NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
            id productDetail = [_data objectForKey:DATA_PRODUCT_DETAIL_KEY]?:@"";
            NSString *defaultImagePath = [_dataInput objectForKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
            if (!defaultImagePath) {
                defaultImagePath = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)? [_productImageURLs firstObject]:[_productImageIDs firstObject];
                [_dataInput setObject:defaultImagePath forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
            }
            _detailVC.data = @{kTKPD_AUTHKEY : auth?:@{},
                               DATA_INPUT_KEY : _dataInput,
                               DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(type),
                               DATA_PRODUCT_DETAIL_KEY: productDetail,
                               DATA_SHOP_HAS_TERM_KEY:_product.result.info.shop_has_terms?:@""
                               };
            _detailVC.shopHasTerm = _product.result.info.shop_has_terms;
            _detailVC.generateHost = _generateHost;
            _detailVC.delegate = self;
            
            //_detailVC.isNeedRequestAddProductPicture = YES;
        }
        

        [_tableView reloadData];
    }
}

#pragma mark Request Generate Host
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generateHost = generateHost;
    ((UIButton*)_addImageButtons[0]).enabled = YES;
    
    //[_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)failedGenerateHost:(NSArray *)errorMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
    [_alertProcessing dismissWithClickedButtonIndex:0 animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Request Action Upload Photo
-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    _images = uploadImage;

    
    [_uploadingImages removeObject:object];
    
    UIImageView *thumbProductImage = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    thumbProductImage.alpha = 1.0;
    
    thumbProductImage.userInteractionEnabled = YES;
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];

    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
        [self configureRestKitEditProductPicture];
        [self requestEditProductPicture:object];
    }
    else
    {
        [_productImageURLs replaceObjectAtIndex:thumbProductImage.tag-20 withObject:_images.result.file_path?:@""];
        [_productImageIDs replaceObjectAtIndex:thumbProductImage.tag-20 withObject:_images.result.pic_id?:@""];
        
        NSArray *objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
        NSMutableArray *photos = [NSMutableArray new];
        for (NSString *photo in objectProductPhoto) {
            if (![photo isEqualToString:@""]) {
                [photos addObject:photo];
            }
        }
        objectProductPhoto = [photos copy];
        NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
        NSLog(@" Product image URL %@ with string %@ ", objectProductPhoto, stringImageURLs);
    }
    
    [self requestProcessUploadPhoto];
}

-(void)failedUploadObject:(id)object
{
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = nil;
    
    for (UIButton *button in _addImageButtons) {
        if (button.tag == imageView.tag) {
            button.hidden = NO;
            button.enabled = YES;
        }
    }

    imageView.hidden = YES;
    
    [_uploadingImages removeObject:object];
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    NSMutableArray *objectProductPhoto = [NSMutableArray new];
    objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
    for (int i = 0; i<_selectedImagesCameraController.count; i++) {
        if ([_selectedImagesCameraController[i]isEqual:[object objectForKey:DATA_SELECTED_PHOTO_KEY]]) {
            [_selectedImagesCameraController replaceObjectAtIndex:i withObject:@""];
            [_selectedIndexPathCameraController replaceObjectAtIndex:i withObject:@""];
            if (type == TYPE_ADD_EDIT_PRODUCT_ADD)
                [objectProductPhoto replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
    [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
    
    [self requestProcessUploadPhoto];
}

-(void)failedUploadErrorMessage:(NSArray *)errorMessage
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
    [stickyAlertView show];
}

- (void)requestProcessUploadPhoto
{
    if (_uploadingImages.count ==0) _isFinishedUploadImages = YES;
    
}

#pragma mark Request Delete Image
-(RKObjectManager*)objectManagerDeleteImage
{
    RKObjectManager *objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(void)requestSuccessDeleteImage:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(setting.message_error)
        {
            NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:ERRORMESSAGE_DELETE_PRODUCT_IMAGE, nil];
            StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
            [alert show];
            [self cancelDeletedImage];
        }
        if (setting.result.is_success == 1) {
            NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:SUCCESSMESSAGE_DELETE_PRODUCT_IMAGE, nil];
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:array delegate:self];
            [alert show];
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
        
        }
    }
}

#pragma mark Request Edit Product Picture
-(void)configureRestKitEditProductPicture
{
    _objectmanagerEditProductPicture =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"pic_id":@"pic_id",
                                                        @"is_success":@"is_success"}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerEditProductPicture addResponseDescriptor:responseDescriptor];
}

-(void)cancelEditProductPicture
{
    [_requestEditProductPicture cancel];
    _requestEditProductPicture = nil;
    
    [_objectmanagerEditProductPicture.operationQueue cancelAllOperations];
    _objectmanagerEditProductPicture = nil;
}

- (void)requestEditProductPicture:(id)pictureObject
{
    if(_requestEditProductPicture.isExecuting) return;
    
    NSDictionary *param = @{@"action" : @"edit_product_picture",
                            @"pic_obj" : _images.result.pic_obj
                            };
    
    NSTimer *timer;
    
    _requestEditProductPicture = [_objectmanagerEditProductPicture appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]];
    [_requestEditProductPicture setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessEditProductPicture:pictureObject withOperation:operation mappingResult:mappingResult];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
        [timer invalidate];
    }];
    
    [[[RKObjectManager sharedClient] operationQueue] addOperation:_requestEditProductPicture];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutEditProductPicture) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessEditProductPicture:(id)object withOperation:(RKObjectRequestOperation*)operation mappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id info = [result objectForKey:@""];
    _images = info;
    NSString *statusstring = _images.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
         if ([_images.result.is_success integerValue] == 1) {
            UIImageView *thumbProductImage = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
            thumbProductImage.alpha = 1.0;
            
            thumbProductImage.userInteractionEnabled = YES;
            
            [_productImageURLs replaceObjectAtIndex:thumbProductImage.tag-20 withObject:_images.result.file_path?:@""];
            [_productImageIDs replaceObjectAtIndex:thumbProductImage.tag-20 withObject:_images.result.pic_id?:@""];
             
             NSMutableArray *photos = [NSMutableArray new];
             for (NSString *photo in _productImageIDs) {
                 if (![photo isEqualToString:@""]) {
                     [photos addObject:photo];
                 }
             }
             
            NSString *stringImageURLs = [[photos valueForKey:@"description"] componentsJoinedByString:@"~"];
            [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
            NSLog(@" Product image URL %@ with string %@ ", photos, stringImageURLs);
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil userInfo:nil];
         }
    }
}

-(void)requestTimeoutEditProductPicture
{
    [self cancelEditProductPicture];
    [_alertProcessing dismissWithClickedButtonIndex:0 animated:YES];
}



#pragma mark - Camera Delegate
-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    NSArray *selectedIndexpaths = [userinfo objectForKey:@"selected_indexpath"];
    NSInteger sourceType = [[userinfo objectForKey:DATA_CAMERA_SOURCE_TYPE] integerValue];
    
    // Cari Index Image yang kosong
    NSMutableArray *emptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _thumbProductImageViews) {
        if (image.image == nil)
        {
            [emptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    //Upload Image yg belum diupload tp dipilih
    int j = 0;
    for (NSDictionary *selected in selectedImages) {
        if ([selected isKindOfClass:[NSDictionary class]]) {
            if (j>=emptyImageIndex.count) {
                return;
            }
            if (![self Array:[_selectedImagesCameraController copy] containObject:selected])
            {
                NSUInteger index = [emptyImageIndex[j] integerValue];
                [_selectedImagesCameraController replaceObjectAtIndex:index withObject:selected];
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:selected];
                NSUInteger indexIndexPath = [_selectedImagesCameraController indexOfObject:selected];
                if (sourceType == UIImagePickerControllerSourceTypeCamera)
                    [data setObject:[NSIndexPath indexPathForRow:0 inSection:0] forKey:@"selected_indexpath"];
                else [data setObject:selectedIndexpaths[indexIndexPath] forKey:@"selected_indexpath"];
                [self setImageData:[data copy] tag:index];
                j++;
            }
        }
    }
}

#pragma mark - TKPDPhotoPicker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    [self setImageData:userInfo tag:picker.tag];
}

-(void)didRemoveImageDictionary:(NSDictionary *)removedImage
{
    //Hapus Image dari camera controller
//    NSMutableArray *removedImages = [NSMutableArray new];
    for (int i = 0; i<_selectedImagesCameraController.count; i++) {
        if ([_selectedImagesCameraController[i] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *photoObjectInArray = [_selectedImagesCameraController[i] objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
            NSDictionary *photoObject = [removedImage objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
            
            UIImage* imageObject = [photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
            UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, imageObject.scale);
            [imageObject drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
            imageObject = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if ([self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
                
                NSMutableDictionary *object = [NSMutableDictionary new];
                [object setObject:_selectedImagesCameraController[i] forKey:DATA_SELECTED_PHOTO_KEY];
                [object setObject:_selectedIndexPathCameraController[i] forKey:DATA_SELECTED_INDEXPATH_KEY];
                [object setObject:_thumbProductImageViews[i] forKey:DATA_SELECTED_IMAGE_VIEW_KEY];

                [self failedUploadObject:object];
                break;
            }
        }
    }
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

-(BOOL)Array:(NSArray*)array containObject:(NSDictionary*)object
{
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        for (id objectInArray in array) {
            if ([objectInArray isKindOfClass:[NSDictionary class]]) {
                NSDictionary *photoObjectInArray = [objectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
                NSDictionary *photoObject = [object objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
                if ([self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void)setImageData:(NSDictionary*)data tag:(NSInteger)tag
{
    id selectedIndexpaths = [data objectForKey:@"selected_indexpath"];
    [_selectedIndexPathCameraController replaceObjectAtIndex:tag withObject:selectedIndexpaths?:@""];

    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    
    NSInteger tagView = tag +20;
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:DATA_SELECTED_PHOTO_KEY];
    UIImageView *imageView;
    
    NSDictionary* photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* imagePhoto = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    for (UIImageView *image in _thumbProductImageViews) {
        if (image.tag == tagView)
        {
            image.image = imagePhoto;
            image.hidden = NO;
            image.alpha = 0.5f;
            imageView = image;
        }
    }
    
    if (imageView != nil) {
        [object setObject:imageView forKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    }
    
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        [object setObject:_selectedImagesCameraController[tag] forKey:DATA_SELECTED_PHOTO_KEY];
        [object setObject:_selectedIndexPathCameraController[tag] forKey:DATA_SELECTED_INDEXPATH_KEY];
    }
    
    for (UIButton *button in _addImageButtons) {
        if (button.tag == tagView) {
            button.enabled = NO;
        }
        if (button.tag == tagView+1)
        {
            for (UIImageView *image in _thumbProductImageViews) {
                if (image.tag == tagView+1)
                {
                    if (image.image == nil) {
                        button.enabled = YES;
                    }
                }
            }
        }
    }
    
    [self actionUploadImage:object];
}

#pragma mark - Upload Image
-(void)actionUploadImage:(id)object
{
    _isFinishedUploadImages = NO;
    [_uploadingImages addObject:object];
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type != TYPE_ADD_EDIT_PRODUCT_COPY) {
        uploadImage.productID = _product.result.product.product_id;
    }
    uploadImage.generateHost = _generateHost;
    uploadImage.action = ACTION_UPLOAD_PRODUCT_IMAGE;
    uploadImage.fieldName = @"fileToUpload";
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
    
    NSString *productID = @"";
    if (type != TYPE_ADD_EDIT_PRODUCT_COPY) {
        productID = _product.result.product.product_id;
    }
    uploadImage requestActionUploadPhoto:object generatedHost:_generateHost action:ACTION_UPLOAD_PRODUCT_IMAGE newAdd:1 productID:productID paymentID:@"" completion:^(id imageObject, UploadImage *image, bool isSuccess) {
        
    }
}

#pragma mark - Category Delegate
-(void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    [_dataInput setObject:userInfo forKey:DATA_CATEGORY_KEY];
    NSString *departmentName = [userInfo objectForKey:kTKPDCATEGORY_DATATITLEKEY];
    NSString *departmentID = [userInfo objectForKey:API_DEPARTMENT_ID_KEY];
    //[_categoryButton setTitle:departmentTitle forState:UIControlStateNormal];
    Breadcrumb *breadcrumb = [Breadcrumb new];
    breadcrumb.department_id = departmentID;
    breadcrumb.department_name = departmentName;
    [_dataInput setObject:breadcrumb forKey:DATA_CATEGORY_KEY];
    [_tableView reloadData];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        [secureStorage setKeychainWithValue:departmentID withKey:LAST_CATEGORY_VALUE];
        [secureStorage setKeychainWithValue:departmentName withKey:LAST_CATEGORY_NAME];
    }
    [_networkManagerCatalog doRequest];
}

#pragma mark - Product Edit Image Delegate

-(void)deleteProductImageAtIndex:(NSInteger)index isDefaultImage:(BOOL)isDefaultImage
{
    [_dataInput setObject:_productImageIDs[index] forKey:DATA_LAST_DELETED_IMAGE_ID];
    [_dataInput setObject:_productImageURLs forKey:DATA_LAST_DELETED_IMAGE_PATH];
    [_dataInput setObject:@(index) forKey:DATA_LAST_DELETED_INDEX];
    [_dataInput setObject:((UIImageView*)_thumbProductImageViews[index]).image forKey:DATA_LAST_DELETED_IMAGE];
    
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:_selectedImagesCameraController[index]  forKey:DATA_SELECTED_PHOTO_KEY];
    [object setObject:_thumbProductImageViews[index] forKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    [object setObject:_selectedIndexPathCameraController[index] forKey:DATA_SELECTED_INDEXPATH_KEY];
    
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    if (type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
        
        if (index != 0 && isDefaultImage) {
            [self setDefaultImageAtIndex:0];
        }
        
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary* auth = [secureStorage keychainDictionary];
        
        DetailProductResult *detailProduct = _product.result;
        NSInteger productID = [detailProduct.product.product_id integerValue];
        NSInteger myshopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
        NSInteger pictureID = [_productImageIDs[index] integerValue];
        NSDictionary *userInfo = @{API_PRODUCT_ID_KEY: @(productID),
                                   kTKPD_SHOPIDKEY : @(myshopID),
                                   API_PRODUCT_PICTURE_ID_KEY:@(pictureID)
                                   };
        [_dataInput addEntriesFromDictionary:userInfo];
        [_productImageDesc replaceObjectAtIndex:index withObject:@""];
        
        NSInteger imageID =[_productImageIDs[index] integerValue];
        NSString *imageDescriptionKey = [NSString stringWithFormat:API_PRODUCT_IMAGE_DESCRIPTION_KEY@"%zd",imageID];
        NSMutableDictionary *ImageNameDictionary = [NSMutableDictionary new];
        ImageNameDictionary = [[_dataInput objectForKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY] mutableCopy];
        [ImageNameDictionary removeObjectForKey:imageDescriptionKey];
        [_dataInput setObject:ImageNameDictionary forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];
        
        [_networkManagerDeleteImage doRequest];
    }
    else  if (type == TYPE_ADD_EDIT_PRODUCT_COPY) {

    }
    
    ((UIButton*)_addImageButtons[index]).hidden = NO;
    ((UIButton*)_addImageButtons[index]).enabled = YES;
    [_productImageIDs replaceObjectAtIndex:index withObject:@""];
    [_productImageURLs replaceObjectAtIndex:index withObject:@""];
    [_productImageDesc replaceObjectAtIndex:index withObject:@""];
    ((UIImageView*)_thumbProductImageViews[index]).image = nil;
    ((UIImageView*)_thumbProductImageViews[index]).hidden = YES;
    
    NSArray *objectProductPhoto;
    if (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
        NSMutableArray *photos = [NSMutableArray new];
        for (NSString *photo in _productImageURLs) {
            if (![photo isEqualToString:@""]) {
                [photos addObject:photo];
            }
        }
        objectProductPhoto = [photos copy];
        NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
    }
    
    [self failedUploadObject:object];
}

-(void)setDefaultImageAtIndex:(NSInteger)index
{
    for (UILabel *defaultImageLabel in _defaultImageLabels) {
        defaultImageLabel.hidden = YES;
    }
    NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
    ((UILabel*)_defaultImageLabels[index]).hidden = NO;
    NSString *imagePath = _productImageURLs[index];
    NSString *imageID = _productImageIDs[index];
    NSString *defaultImage = (type == TYPE_ADD_EDIT_PRODUCT_ADD||type == TYPE_ADD_EDIT_PRODUCT_COPY)?imagePath:imageID;
    NSArray *photosAll = (type == TYPE_ADD_EDIT_PRODUCT_ADD||type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
    [_dataInput setObject:defaultImage forKey:API_PRODUCT_IMAGE_DEFAULT_KEY];
    [_dataInput setObject:[NSString stringWithFormat:@"%ld", (long)index] forKey:API_PRODUCT_IMAGE_DEFAULT_INDEX];
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
                ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
                product.product_currency_id = [ARRAY_PRICE_CURRENCY[index] objectForKey:DATA_VALUE_KEY];
                product.product_currency = name;
                [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
                [_dataInput setObject:@(value) forKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY];
                [_tableView reloadData];
                
            }
            break;
        }
        case 12:
        {
            //weight curency
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_VALUE_KEY];
            NSString *name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
            ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
            product.product_weight_unit_name = name;
            product.product_weight_unit = value;
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
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
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    if (textField == _productNameTextField) {
        NSInteger type = [[_data objectForKey:DATA_TYPE_ADD_EDIT_PRODUCT_KEY]integerValue];
        [self requestCatalog];
        if (type == TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY) {
            product.product_name = textField.text;
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
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
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
    if (textField == _productWeightTextField) {
        product.product_weight = textField.text;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
    if (textField == _minimumOrderTextField) {
        product.product_min_order = textField.text;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
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

-(void)requestCatalog
{
    [_networkManagerCatalog doRequest];
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
    for (CatalogList *catalog in _catalog.result.list) {
        if ([catalog.catalog_name isEqualToString:object]) {
            _selectedCatalog = catalog;
        }
    }
    [_dataInput setObject:_selectedCatalog?:[CatalogList new] forKey:DATA_CATALOG_KEY];    
    
    [_tableView reloadData];
}

-(void)DidEditReturnableNote
{
    //_networkManager.delegate = self;
    //[_networkManager doRequest];
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
        DetailProductResult *result = _product.result;
        ProductDetail *product = result.product;
        if (!product) {
            product = [ProductDetail new];
            product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_NAME_KEY];
            product.product_weight_unit = [ARRAY_WEIGHT_UNIT[0] objectForKey:DATA_VALUE_KEY];
            
            product.product_currency = [ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_NAME_KEY];
            product.product_currency_id = [ARRAY_PRICE_CURRENCY[0] objectForKey:DATA_VALUE_KEY];
            
            product.product_min_order = @"1";
            product.product_condition = [ARRAY_PRODUCT_CONDITION[0] objectForKey:DATA_VALUE_KEY];
            
            NSString *value = [ARRAY_PRODUCT_MOVETO_ETALASE[0] objectForKey:DATA_VALUE_KEY];
            product.product_move_to = value;
        }
        else
        {
            NSInteger index = [product.product_weight_unit integerValue]-1;
            if (index<0) {
                index = 0;
            }
            product.product_weight_unit_name = [ARRAY_WEIGHT_UNIT[index] objectForKey:DATA_NAME_KEY];
            if ([product.product_currency isEqualToString:@"idr"]) {
                product.product_currency = [ARRAY_PRICE_CURRENCY[0]objectForKey:DATA_NAME_KEY];
            }
            if ([product.product_currency isEqualToString:@"usd"]) {
                product.product_currency = [ARRAY_PRICE_CURRENCY[1]objectForKey:DATA_NAME_KEY];
            }
            NSInteger indexMoveTo = ([product.product_etalase_id integerValue]>0)?1:0;
            NSString *value = [ARRAY_PRODUCT_MOVETO_ETALASE[indexMoveTo] objectForKey:DATA_VALUE_KEY];
            product.product_move_to = value;
            product.product_etalase_id = product.product_etalase_id?:@(0);
            product.product_short_desc = [product.product_short_desc stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
            product.product_description = product.product_short_desc?:@"";
            product.product_returnable = _product.result.info.product_returnable?:@"";
            product.product_min_order = _product.result.product.product_min_order?:@"1";
        }
        _minimumOrderTextField.text = product.product_min_order;
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
        [_dataInput setObject:product.product_currency_id forKey:API_PRODUCT_PRICE_CURRENCY_ID_KEY];
        
        NSArray *images = result.product_images;
        NSInteger imageCount = images.count;
        if (imageCount>5) {
            imageCount = 5;
        }
        NSInteger addProductImageCount = (imageCount<_addImageButtons.count)?imageCount:imageCount-1;
        if (_generateHost.result.generated_host != nil) {
            ((UIButton*)_addImageButtons[addProductImageCount]).enabled = YES;
        }
        
        NSMutableDictionary *productImageDescription = [NSMutableDictionary new];
        for (int i = 0 ; i<imageCount;i++) {
            ProductImages *image = images[i];
            ((UIButton*)_addImageButtons[i]).hidden = YES;
            [_productImageURLs replaceObjectAtIndex:i withObject:image.image_src];
            [_productImageIDs replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%zd",image.image_id]];
            [_productImageDesc replaceObjectAtIndex:i withObject:image.image_description];

            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *thumb = (UIImageView*)_thumbProductImageViews[i];
            thumb.userInteractionEnabled = NO;
            thumb.hidden = NO;
            thumb.image = nil;
            [thumb setContentMode:UIViewContentModeCenter];
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
                thumb.userInteractionEnabled = YES;
                [thumb setContentMode:UIViewContentModeScaleAspectFill];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
            
            NSString *productImageDescriptionKey = [NSString stringWithFormat:API_PRODUCT_IMAGE_DESCRIPTION_KEY@"%zd",image.image_id];
            [productImageDescription setObject:image.image_description forKey:productImageDescriptionKey];
        }
        
        [_dataInput setObject:productImageDescription forKey:API_PRODUCT_IMAGE_DESCRIPTION_KEY];

        NSArray *objectProductPhoto = (type == TYPE_ADD_EDIT_PRODUCT_ADD||type == TYPE_ADD_EDIT_PRODUCT_COPY)?_productImageURLs:_productImageIDs;
        NSMutableArray *photos = [NSMutableArray new];
        for (NSString *photo in objectProductPhoto) {
            if (![photo isEqualToString:@""]) {
                [photos addObject:photo];
            }
        }
        objectProductPhoto = [photos copy];
        NSString *stringImageURLs = [[objectProductPhoto valueForKey:@"description"] componentsJoinedByString:@"~"];
        [_dataInput setObject:stringImageURLs forKey:API_PRODUCT_IMAGE_TOUPLOAD_KEY];
        NSLog(@" Product image URL %@ with string %@ ", objectProductPhoto, stringImageURLs);
        
        NSString *serverID = result.server_id?:_generateHost.result.generated_host.server_id?:@"0";
        NSArray *breadcrumbs = result.breadcrumb?:@[];
        Breadcrumb *breadcrumb = [breadcrumbs lastObject]?:[Breadcrumb new];
        [_dataInput setObject:breadcrumb forKey:DATA_CATEGORY_KEY];
        NSString *priceCurencyID = result.product.product_currency_id?:@"1";
        
        NSString *price = result.product.product_price?:@"";
        NSString *weight = result.product.product_weight?:@"";
        NSArray *wholesale = result.wholesale_price?:@[];
        [_dataInput setObject:wholesale forKey:DATA_WHOLESALE_LIST_KEY];
        BOOL isWarehouse = ([result.product.product_etalase_id integerValue]>0)?NO:YES;
        NSInteger uploadToWarehouse = isWarehouse?UPLOAD_TO_VALUE_IF_IS_WAREHOUSE:UPLOAD_TO_VALUE_IF_ISNOT_WAREHOUSE;
        BOOL isGoldShop = result.shop_is_gold;
        
        _productNameTextField.text = product.product_name;
        _productNameBeforeCopy = product.product_name;
        //_productNameTextField.enabled = (type ==TYPE_ADD_EDIT_PRODUCT_ADD || type == TYPE_ADD_EDIT_PRODUCT_COPY)?YES:NO;
        
        CGFloat priceInteger = [price floatValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if ([priceCurencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:3];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            price = (priceInteger>0)?[formatter stringFromNumber:@(priceInteger)]:@"";
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
        
        [_dataInput setObject:serverID forKey:API_SERVER_ID_KEY];
        [_dataInput setObject:wholesale forKey:DATA_WHOLESALE_LIST_KEY];
        [_dataInput setObject:@(uploadToWarehouse) forKey:API_PRODUCT_MOVETO_WAREHOUSE_KEY];
//        [_dataInput setObject:@(etalaseID) forKey:API_PRODUCT_ETALASE_ID_KEY];
        [_dataInput setObject:@(isGoldShop) forKey:API_IS_GOLD_SHOP_KEY];
//        [_dataInput setObject:@(returnable) forKey:API_PRODUCT_IS_RETURNABLE_KEY];
        
    }
}

- (BOOL)dataInputIsValid
{
    [_errorMessage removeAllObjects];
    BOOL isValid = YES;
    BOOL isValidPrice = YES;
    BOOL isValidWeight = YES;
    int nImage = 0;
    
    
    NSMutableArray *productImagesTemp = [NSMutableArray new];
    for (NSString *productImage in _productImageURLs) {
        if (![productImage isEqualToString:@""]) {
            [productImagesTemp addObject:productImage];
            nImage++;
        }
    }
    //BOOL isValidImage = (productImagesTemp.count>0);
    BOOL isValidImage = nImage!=0;
    
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY]?:[ProductDetail new];
    Breadcrumb *department = [_dataInput objectForKey:DATA_CATEGORY_KEY]?:[Breadcrumb new];
    NSString *productName = product.product_name;
    NSString *productPrice = product.product_price;
    NSString *productPriceCurrencyID = product.product_currency_id;
    NSString *productWeight = product.product_weight;
    NSString *productWeightUnitID = product.product_weight_unit;
    NSInteger departmentID = [department.department_id integerValue];
    
    BOOL isPriceCurrencyRupiah = ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH);
    BOOL isPriceCurrencyUSD = ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_USD);
    
    BOOL isWeightUnitGram = ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_GRAM);
    BOOL isWeightUnitKilogram = ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_KILOGRAM);
    
    if (productName && ![productName isEqualToString:@""] &&
        productPrice>0 &&
        productWeight>0 &&
        departmentID>0) {
       
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
        [_errorMessage addObject:@"Tidak dapat menyalin dengan Nama Produk yang sama."];
        isValid = NO;
    }

    if ( !productName || [productName isEqualToString:@""]) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_PRODUCT_NAME];
        isValid = NO;
    }
    if (!(productPrice > 0)) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_PRICE];
        isValid = NO;
    }
    else
    {
        if ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_RUPIAH &&
            ([productPrice integerValue]<MINIMUM_PRICE_RUPIAH || [productPrice integerValue]>MAXIMUM_PRICE_RUPIAH)) {
            [_errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_RUPIAH];
            isValid = NO;
        }
        else if ([productPriceCurrencyID integerValue] == PRICE_CURRENCY_ID_USD &&
                 ([productPrice floatValue]<MINIMUM_PRICE_USD || [productPrice floatValue]>MAXIMUM_PRICE_USD)) {
            [_errorMessage addObject:ERRORMESSAGE_INVALID_PRICE_USD];
            isValid = NO;
        }
    }
    if (!(departmentID>0)) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_CATEGORY];
        isValid = NO;
    }
    if ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_GRAM &&
        ([productWeight integerValue]<MINIMUM_WEIGHT_GRAM || [productWeight integerValue]>MAXIMUM_WEIGHT_GRAM)) {
        [_errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_GRAM];
        isValid = NO;
    }
    else if ([productWeightUnitID integerValue] == WEIGHT_UNIT_ID_KILOGRAM &&
             ([productWeight integerValue]<MINIMUM_WEIGHT_KILOGRAM || [productWeight integerValue]>MAXIMUM_WEIGHT_KILOGRAM)) {
        [_errorMessage addObject:ERRORMESSAGE_INVALID_WEIGHT_KILOGRAM];
        isValid = NO;
    }
    
    if ([product.product_min_order integerValue]>=1000) {
        isValid = NO;
        [_errorMessage addObject:@"Maksimal minimum pembelian untuk 1 produk adalah 999"];
    }
    
    if (!isValidImage) {
        [_errorMessage addObject:ERRORMESSAGE_NULL_IMAGE];
    }

    return (isValidWeight && isValidPrice && isValid && isValidImage);
}

-(void)enableButtonBeforeSuccessRequest:(BOOL)isEnable
{
    _nextBarButtonItem.enabled = isEnable;
    ((UIButton*)_addImageButtons[0]).enabled = NO;

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


#pragma mark - Object Manager

- (RKObjectManager*)objectManagerDetail
{
    // initialize RestKit
    RKObjectManager *objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
    [productMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_SERVER_ID_KEY:API_SERVER_ID_KEY,
                                                        API_IS_GOLD_SHOP_KEY:API_IS_GOLD_SHOP_KEY,
                                                        }];
    
    RKObjectMapping *OtherInfoMapping = [RKObjectMapping mappingForClass:[Info class]];
    [OtherInfoMapping addAttributeMappingsFromArray:@[API_PRODUCT_RETURNABLE_KEY,
                                                   API_SHOP_HAS_TERMS_KEY
                                                   ]];
    
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
    [infoMapping addAttributeMappingsFromDictionary:@{API_PRODUCT_NAME_KEY:API_PRODUCT_NAME_KEY,
                                                      API_PRODUCT_WEIGHT_UNIT_KEY:API_PRODUCT_WEIGHT_UNIT_KEY,
                                                      API_PRODUCT_DESCRIPTION_KEY:API_PRODUCT_DESCRIPTION_KEY,
                                                      API_PRODUCT_PRICE_KEY:API_PRODUCT_PRICE_KEY,
                                                      API_PRODUCT_INSURANCE_KEY:API_PRODUCT_INSURANCE_KEY,
                                                      API_PRODUCT_CONDITION_KEY:API_PRODUCT_CONDITION_KEY,
                                                      API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                      API_PRODUCT_WEIGHT_KEY:API_PRODUCT_WEIGHT_KEY,
                                                      API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY:API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY,
                                                      kTKPDDETAILPRODUCT_APICURRENCYKEY:kTKPDDETAILPRODUCT_APICURRENCYKEY,
                                                      API_PRODUCT_ETALASE_ID_KEY:API_PRODUCT_ETALASE_ID_KEY,
                                                      API_PRODUCT_DEPARTMENT_ID_KEY:API_PRODUCT_DEPARTMENT_ID_KEY,
                                                      API_PRODUCT_FORM_DESCRIPTION_KEY:API_PRODUCT_FORM_DESCRIPTION_KEY,
                                                      API_PRODUCT_FORM_DEPARTMENT_TREE_KEY:API_PRODUCT_FORM_DEPARTMENT_TREE_KEY,
                                                      API_PRODUCT_FORM_RETURNABLE_KEY:API_PRODUCT_FORM_RETURNABLE_KEY,
                                                      API_PRODUCT_MUST_INSURANCE_KEY:API_PRODUCT_MUST_INSURANCE_KEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTURKKEY:kTKPDDETAILPRODUCT_APIPRODUCTURKKEY,
                                                      API_PRODUCT_FORM_ETALASE_NAME_KEY:API_PRODUCT_FORM_ETALASE_NAME_KEY
                                                      }];
    
    RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
    [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY,
                                                           KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY
                                                           
                                                           }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];
    
    RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
    [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
    
    RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
    [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
    
    RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
    [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,
                                                         API_PRODUCT_NAME_KEY,
                                                         kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                         kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
    
    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    
    // Relationship Mapping
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY withMapping:OtherInfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_INFO_KEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *breadcrumbRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY toKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY withMapping:breadcrumbMapping];
    [resultMapping addPropertyMapping:breadcrumbRel];
    RKRelationshipMapping *otherproductRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherproductMapping];
    [resultMapping addPropertyMapping:otherproductRel];
    RKRelationshipMapping *productimageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY withMapping:imagesMapping];
    [resultMapping addPropertyMapping:productimageRel];
    RKRelationshipMapping *wholesaleRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY toKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY withMapping:wholesaleMapping];
    [resultMapping addPropertyMapping:wholesaleRel];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectmanager addResponseDescriptor:responseDescriptor];
    
    return objectmanager;
}

-(RKObjectManager*)objectManagerCatalog
{
    RKObjectManager *objectManager =[RKObjectManager sharedClient];
    
    RKObjectMapping *catalogMapping = [RKObjectMapping mappingForClass:[CatalogAddProduct class]];
    [catalogMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                         kTKPD_APISERVERPROCESSTIMEKEY:
                                                             kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[CatalogResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[CatalogList class]];
    [listMapping addAttributeMappingsFromArray:@[@"catalog_description",
                                                      @"catalog_id",
                                                      @"catalog_name",
                                                      @"catalog_price",
                                                      @"catalog_image"
                                                      ]];
    
    [catalogMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listCatalog = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:listMapping];
    [resultMapping addPropertyMapping:listCatalog];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:catalogMapping method:RKRequestMethodGET pathPattern:kTKDPDETAILCATALOG_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    

    return objectManager;
}

@end
