//
//  MyShopShipmentTableViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "MyShopShipmentTableViewController.h"
#import "SettingPaymentResult.h"
#import "ShippingInfo.h"
#import "ShippingInfoShipmentPackage.h"
#import "ShopSettings.h"
#import "detail.h"
#import "GeneralTableViewController.h"
#import "Payment.h"
#import "string_create_shop.h"
#import "MyShopPaymentViewController.h"
#import "MyShopShipmentInfoViewController.h"
#import "AlertInfoView.h"
#import "Province.h"
#import "City.h"
#import "PlacePickerViewController.h"
#import "NavigateViewController.h"
#import "TKPDTextView.h"
#import "Tokopedia-Swift.h"

@interface MyShopShipmentTableViewController ()
<
    UITextFieldDelegate,
    GeneralTableViewControllerDelegate,
    PlacePickerDelegate,
    TKPPlacePickerDelegate
>
{
    ShippingInfoResult *_shipment;
    NSArray *_availableProvinceName;
    NSArray *_availableCityName;
    NSArray *_availableDistrictName;
    NSArray *_availableShipments;
    
    NSArray *_provinces;
    Province *_selectedProvince;
    
    NSArray *_cities;
    City *_selectedCity;

    NSArray *_disticts;
    District *_selectedDistrict;
    
    ShippingInfoShipmentPackage *_JNEPackageYes;
    ShippingInfoShipmentPackage *_JNEPackageReguler;
    ShippingInfoShipmentPackage *_JNEPackageOke;
    BOOL _showJNEMinimumWeightTextField;
    BOOL _showJNEExtraFeeTextField;
    BOOL _showJNEAWBSwitch;
    
    ShippingInfoShipmentPackage *_tikiPackageReguler;
    ShippingInfoShipmentPackage *_tikiPackageONS;
    BOOL _showTikiExtraFee;

    ShippingInfoShipmentPackage *_posPackageKhusus;
    ShippingInfoShipmentPackage *_posPackageBiasa;
    ShippingInfoShipmentPackage *_posPackageExpress;
    BOOL _showPosMinimumWeight;
    BOOL _showPosExtraFee;
    
    ShippingInfoShipmentPackage *_RPXPackageNextDay;
    ShippingInfoShipmentPackage *_RPXPackageEconomy;
    BOOL _showRPXIDropSwitch;
    
    ShippingInfoShipmentPackage *_wahanaPackageNormal;
    
    ShippingInfoShipmentPackage *_cahayaPackageNormal;
    
    ShippingInfoShipmentPackage *_panduPackageRegular;

    ShippingInfoShipmentPackage *_firstPackageRegular;

    ShippingInfoShipmentPackage *_siCepatPackageRegular;

    ShippingInfoShipmentPackage *_gojekPackageGoKilat;

    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    BOOL _hasSelectKotaAsal;
}

@property (strong, nonatomic) ShippingInfoShipments *JNE;
@property (strong, nonatomic) ShippingInfoShipments *tiki;
@property (strong, nonatomic) ShippingInfoShipments *posIndonesia;
@property (strong, nonatomic) ShippingInfoShipments *RPX;
@property (strong, nonatomic) ShippingInfoShipments *wahana;
@property (strong, nonatomic) ShippingInfoShipments *cahaya;
@property (strong, nonatomic) ShippingInfoShipments *pandu;
@property (strong, nonatomic) ShippingInfoShipments *first;
@property (strong, nonatomic) ShippingInfoShipments *siCepat;
@property (strong, nonatomic) ShippingInfoShipments *gojek;

@property (weak, nonatomic) IBOutlet UILabel *provinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *districtLabel;

@property (weak, nonatomic) IBOutlet UITextField *postCodeTextField;

@property (weak, nonatomic) IBOutlet UILabel *shipmentJNENameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentJNELogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNERegulerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNERegulerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNEYesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEYesSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNEOkeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEOkeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEAWBSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentJNEAWBCell;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEMinimumWeightSwitch;
@property (weak, nonatomic) IBOutlet UITextField *shipmentJNEMinimumWeightTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNEDifferentDistrictLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEDifferentDistrictSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNEExtraFeeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentJNEExtraFeeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *shipmentJNEExtraFeeTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentJNENotAvailableLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentJNEMoreInfoCell;


@property (weak, nonatomic) IBOutlet UILabel *shipmentTikiNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentTikiLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentTikiRegulerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentTikiRegulerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentTikiONSLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentTikiONSSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentTikiExtraFeeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentTikiExtraFeeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *shipmentTikiExtraFeeTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentTikiNotAvailable;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentTikiMoreInfoCell;

@property (weak, nonatomic) IBOutlet UILabel *shipmentRPXNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentRPXLogoImageView;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentRPXIDropCell;
@property (weak, nonatomic) IBOutlet UILabel *shipmentRPXIDropLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentRPXLogoIndomaretView;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentRPXIDropSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentRPXNextDaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentRPXEconomySwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentRPXNotAvailableLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentRPXMoreInfoCell;

@property (weak, nonatomic) IBOutlet UILabel *shipmentWahanaNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentWahanaLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentWahanaNextDayLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentWahanaNextDaySwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentWahanaNotAvailableLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentWahanaMoreInfoCell;

@property (weak, nonatomic) IBOutlet UILabel *shipmentPosNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentPosLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosKilatKhususLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPosKilatKhususSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosBiasaLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPosBiasaSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosExpressLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPosExpressSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosMinWeightLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPosMinWeightSwitch;
@property (weak, nonatomic) IBOutlet UITextField *shipmentPosMinWeightTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosExtraFeeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPosExtraFeeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *shipmentPosExtraFeeTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosNotAvailabelLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentPosMoreInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPosNoteCell;

@property (weak, nonatomic) IBOutlet UILabel *shipmentCahayaNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentCahayaLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentCahayaNormalLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentCahayaNormalSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmentCahayaNotAvailabelLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentCahayaMoreInfoCell;

@property (weak, nonatomic) IBOutlet UILabel *shipmentPanduNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shipmentPanduLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPanduRegulerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *shipmentPanduRegulerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shipmePanduNotAvailableLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *shipmentPanduMoreInfoCell;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstRegulerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *firstRegulerSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *firstMoreInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *firstNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstNotAvailableLabel;

@property (weak, nonatomic) IBOutlet UILabel *siCepatNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *siCepatLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *siCepatRegulerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *siCepatRegulerSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *siCepatMoreInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *siCepatNotAvailableLabel;

@property (weak, nonatomic) IBOutlet UILabel *gojekNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gojekLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *gojekGoKilatLabel;
@property (weak, nonatomic) IBOutlet UISwitch *gojekGoKilatSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *gojekMoreInfoCell;
@property (weak, nonatomic) IBOutlet UILabel *gojekMoreInfoLabel;

@property (weak, nonatomic) IBOutlet TKPDTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *pickupMapContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *pickupLocationImageView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *weightCollection;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *notSupportedCellColleciton;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end

@implementation MyShopShipmentTableViewController

@synthesize createShopViewController;

- (void)dealloc {
    [_request cancel];
    [_operationQueue cancelAllOperations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pengiriman";
    
    [self setLabelAttributedText];
    [self setTextFieldsDelegate];
    [self createSaveButton];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    _operationQueue = [NSOperationQueue new];
    [self configureRestKit];
    [self request];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Text field

- (void)setTextFieldsDelegate {
    [_postCodeTextField addTarget:self
                           action:@selector(textFieldDidEndEditing:)
                 forControlEvents:UIControlEventEditingChanged];
    
    [_shipmentJNEMinimumWeightTextField addTarget:self
                                           action:@selector(textFieldDidEndEditing:)
                                 forControlEvents:UIControlEventEditingChanged];
    [_shipmentJNEExtraFeeTextField addTarget:self
                                      action:@selector(textFieldDidEndEditing:)
                            forControlEvents:UIControlEventEditingChanged];
    
    [_shipmentTikiExtraFeeTextField addTarget:self
                                       action:@selector(textFieldDidEndEditing:)
                             forControlEvents:UIControlEventEditingChanged];
    
    [_shipmentPosMinWeightTextField addTarget:self
                                       action:@selector(textFieldDidEndEditing:)
                             forControlEvents:UIControlEventEditingChanged];
    [_shipmentPosExtraFeeTextField addTarget:self
                                      action:@selector(textFieldDidEndEditing:)
                            forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Save Button

- (void)createSaveButton {
    NSString *title = createShopViewController?CStringLanjut:@"Simpan";
    UIBarButtonItemStyle style = createShopViewController?UIBarButtonItemStylePlain:UIBarButtonItemStyleDone;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                   style:style
                                                                  target:self
                                                                  action:@selector(tap:)];
    saveButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)validateSaveButton {
    if(_hasSelectKotaAsal && _postCodeTextField.text.length > 4) {
        [self enableSaveButton];
    } else {
        [self disableSaveButton];
    }
}

- (void)enableSaveButton {
    UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
    saveButton.tintColor = [UIColor whiteColor];
    saveButton.enabled = YES;
}

- (void)disableSaveButton {
    UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
    saveButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    saveButton.enabled = NO;
}

#pragma mark - Label attributed

- (void)setLabelAttributedText {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor blackColor],
                                 };
    
    _shipmentJNEDifferentDistrictLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentJNEDifferentDistrictLabel.text attributes:attributes];
    
    _shipmentJNEExtraFeeLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentJNEExtraFeeLabel.text attributes:attributes];
    
    _shipmentTikiExtraFeeLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentTikiExtraFeeLabel.text attributes:attributes];
    
    _shipmePanduNotAvailableLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmePanduNotAvailableLabel.text attributes:attributes];
    
    _shipmentCahayaNotAvailabelLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentCahayaNotAvailabelLabel.text attributes:attributes];
    
    _shipmentPosMinWeightLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentPosMinWeightLabel.text attributes:attributes];
    
    _shipmentPosExtraFeeLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentPosExtraFeeLabel.text attributes:attributes];
    
    _shipmentPosNotAvailabelLabel.attributedText = [[NSAttributedString alloc] initWithString:_shipmentPosNotAvailabelLabel.text attributes:attributes];
    
    _firstNotAvailableLabel.attributedText = [[NSAttributedString alloc] initWithString:_firstNotAvailableLabel.text attributes:attributes];
    
    _siCepatNotAvailableLabel.attributedText = [[NSAttributedString alloc] initWithString:_siCepatNotAvailableLabel.text attributes:attributes];
    
    NSString *note = @"Berat maksimum paket biasa 30 kg. Berat maksimum paket lain nya 150 kg.";
    _shipmentPosNoteCell.attributedText = [[NSAttributedString alloc] initWithString:note attributes:attributes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_shipment) {
        if (_hasSelectKotaAsal) {
            return 13;
        } else {
            return 1;
        }
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0: {
            if (_shipment) {
                height = [self heightForFirstSectionIndexPath:indexPath];
            } else {
                height = 0;
            }
            break;
        }
            
        case 1: {
            height = [self heightForSecondSectionIndexPath:indexPath];
            break;
        }
            
        case 2: {
            height = [self heightForPhoneNumberRow:indexPath.row];
            break;
        }
            
        case 3: {
            height = [self heightForJNEAtRow:indexPath.row];
            break;
        }
            
        case 4: {
            height = [self heightForTikiAtRow:indexPath.row];
            break;
        }
            
        case 5: {
            height = [self heightForRPXAtRow:indexPath.row];
            break;
        }
            
        case 6: {
            height = [self heightForWahanaAtRow:indexPath.row];
            break;
        }
            
        case 7: {
            height = [self heightForPosAtRow:indexPath.row];
            break;
        }
            
        case 8: {
            height = [self heightForCahayaAtRow:indexPath.row];
            break;
        }
            
        case 9: {
            height = [self heightForPanduAtRow:indexPath.row];
            break;
        }
            
        case 10: {
            height = [self heightForFirstAtRow:indexPath.row];
            break;
        }

        case 11: {
            height = [self heightForGoJekRow:indexPath.row];
            break;
        }
            
        case 12: {
            height = [self heightForSiCepatAtRow:indexPath.row];
            break;
        }

        default:
            height = 0;
            break;
    }
    return height;
}

- (CGFloat)heightForFirstSectionIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 44;
        } else if (indexPath.row == 1 && _shipment.shop_shipping.province_id != 0) {
            if ([_shipment.shop_shipping.province_name isEqualToString:@"DKI Jakarta"] ||
                _shipment.shop_shipping.province_id == 13) {
                height = 0;
            } else {
                height = 44;
            }
        } else if (indexPath.row == 2 && _shipment.shop_shipping.city_id != 0) {
            if ([_shipment.shop_shipping.province_name isEqualToString:@"DKI Jakarta"] ||
                _shipment.shop_shipping.province_id == 13) {
                height = 0;
            } else {
                height = 44;
            }
        } else if (indexPath.row == 3) {
            height = 44;
        } else if (indexPath.row == 4) {
            height = 140;
        }
    }
    return height;
}

- (CGFloat)heightForSecondSectionIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    if (indexPath.row == 0) {
        height = 120;
    } else if (indexPath.row == 1) {
        height = 60;
    }
    return height;
}

- (CGFloat)heightForPhoneNumberRow:(NSInteger)row {
    if (_shipment.contact.msisdn_enc) {
        return 44;
    } else {
        return 0;
    }
}

- (CGFloat)heightForJNEAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_JNE.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_JNEPackageOke) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 2) {
            if (_JNEPackageReguler) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 3) {
            if (_JNEPackageYes) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // AWB appear only if at least one of three packages is activated
        else if (row == 4) {
            if ([_JNEPackageOke.active boolValue] ||
                [_JNEPackageReguler.active boolValue] ||
                [_JNEPackageYes.active boolValue]) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // minimum weight text field appear only if OKE package is activated
        else if (row == 5) {
            if ([_JNEPackageOke.active boolValue]) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell minimum weight textfield
        else if (row == 6) {
            if ([_JNEPackageOke.active boolValue] &&
                _showJNEMinimumWeightTextField) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell "Hanya dapat melayani pengiriman luar kota." if OKE is activated
        else if (row == 7) {
            if ([_JNEPackageOke.active boolValue]) {
                height = 50;
            } else {
                height = 0;
            }
        }
        
        // return switch to activate extra fee if at least one package is activated
        else if (row == 8) {
            if ([_JNEPackageOke.active boolValue] ||
                [_JNEPackageReguler.active boolValue] ||
                [_JNEPackageYes.active boolValue]) {
                height = 50;
            } else {
                height = 0;
            }
        }
        
        // return height for extra fee text field cell
        else if (row == 9) {
            if (_showJNEExtraFeeTextField) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // cell to show "more information" cell
        else if (row == 10) {
            height = 44;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 11) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForTikiAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_tiki.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_tikiPackageReguler) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 2) {
            if (_tikiPackageONS) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return switch to activate extra fee if at least one package is activated
        else if (row == 3) {
            if ([_tikiPackageReguler.active boolValue] ||
                [_tikiPackageONS.active boolValue]) {
                height = 50;
            } else {
                height = 0;
            }
        }
        
        // return height for extra fee text field cell
        else if (row == 4) {
            if (([_tikiPackageReguler.active boolValue] || [_tikiPackageONS.active boolValue]) &&
                _showTikiExtraFee) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // cell to show "more information" cell
        else if (row == 5) {
            height = 44;
        }
        
        else if (row == 6) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 7) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForRPXAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_RPX.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about i-drop exists
        else if (row == 1) {
            if(_shipment.rpx.whitelisted_idrop == 1) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 2) {
            if (_RPXPackageNextDay) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 3) {
            if (_RPXPackageEconomy) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        else if (row == 4) {
            height = 44;
        }
        
        else if (row == 5) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 6) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForWahanaAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_wahana.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
            
            // return cell if information about package is existing
        } else if (row == 1) {
            if (_wahanaPackageNormal) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        else if (row == 2) {
            height = 44;
        }
        
        else if (row == 3) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 4) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForPosAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_posIndonesia.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_posPackageKhusus) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 2) {
            if (_posPackageBiasa) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 3) {
            if (_posPackageExpress) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return switch to activate extra fee if at least one package is activated
        else if (row == 4) {
            if ([_posPackageBiasa.active boolValue] ||
                [_posPackageExpress.active boolValue] ||
                [_posPackageKhusus.active boolValue]) {
                height = 50;
            } else {
                height = 0;
            }
        }
        
        // return height for extra fee text field cell
        else if (row == 5) {
            if (([_posPackageBiasa.active boolValue] ||
                 [_posPackageExpress.active boolValue] ||
                 [_posPackageKhusus.active boolValue]) &&
                _showPosMinimumWeight) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return switch to activate extra fee if at least one package is activated
        else if (row == 6) {
            if ([_posPackageBiasa.active boolValue] ||
                [_posPackageExpress.active boolValue] ||
                [_posPackageKhusus.active boolValue]) {
                height = 50;
            } else {
                height = 0;
            }
        }
        
        // return height for extra fee text field cell
        else if (row == 7) {
            if (([_posPackageBiasa.active boolValue] ||
                 [_posPackageExpress.active boolValue] ||
                 [_posPackageKhusus.active boolValue]) &&
                _showPosExtraFee) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        else if (row == 8) {
            height = 44;
        }
        
        else if (row == 9) {
            height = 100;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 10) {
            height = 70;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForCahayaAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_cahaya.shipment_id]) {
        if (row == 0) {
            height = 50;
        } else if (row == 1) {
            if (_cahayaPackageNormal) {
                height = 44;
            } else {
                height = 0;
            }
        } else if (row == 2) {
            height = 44;
        } else if (row == 3) {
            height = 70;
        }
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 4) {
            height = 70;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForPanduAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_pandu.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_panduPackageRegular) {
                return 44;
            } else {
                return 0;
            }
        }
        
        else if (row == 2) {
            height = 44;
        }
        
        else if (row == 3) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 4) {
            height = 70;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForFirstAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_first.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_firstPackageRegular) {
                return 44;
            } else {
                return 0;
            }
        }
        
        else if (row == 2) {
            height = 44;
        }
        
        else if (row == 3) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 4) {
            height = 70;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForGoJekRow:(NSInteger)row {
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_gojek.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_gojekPackageGoKilat) {
                return 44;
            } else {
                return 0;
            }
        }
        
        else if (row == 2) {
            height = 44;
        }
        
    } else if (createShopViewController) {
        
        //TODO: Better codes
        if ([_shipment.allow_activate_gojek boolValue]) {
            // cell to show courier name and logo
            if (row == 0) {
                height = 50;
            }
            
            // return cell if information about package is existing
            else if (row == 1) {
                if (_gojekPackageGoKilat) {
                    return 44;
                } else {
                    return 0;
                }
            }
            
            else if (row == 2) {
                height = 44;
            }
        }
        
    } else if ([_shipment.gojek.whitelisted boolValue] == NO) {
        height = 0;
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 3) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (CGFloat)heightForSiCepatAtRow:(NSInteger)row
{
    CGFloat height = 0.0f;
    if ([_availableShipments containsObject:_siCepat.shipment_id]) {
        
        // cell to show courier name and logo
        if (row == 0) {
            height = 50;
        }
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_siCepatPackageRegular) {
                return 44;
            } else {
                return 0;
            }
        }
        
        else if (row == 2) {
            height = 44;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 3) {
            height = 44;
        } else {
            height = 0;
        }
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    switch (section) {
        case 0:
            numberOfRows = 4;
            break;
            
        case 1:
            numberOfRows = 2;
            break;

        case 2:
            numberOfRows = 1;
            break;
            
        case 3:
            numberOfRows = 12;
            break;
            
        case 4:
            numberOfRows = 8;
            break;
            
        case 5:
            numberOfRows = 7;
            break;
            
        case 6:
            numberOfRows = 5;
            break;
            
        case 7:
            numberOfRows = 11;
            break;
            
        case 8:
            numberOfRows = 5;
            break;
            
        case 9:
            numberOfRows = 5;
            break;
        
        case 10:
            numberOfRows = 5;
            break;
            
        case 11:
            numberOfRows = 4;
            break;

        case 12:
            numberOfRows = 4;
            break;

        default:
            numberOfRows = 0;
            break;
    }
    return numberOfRows;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlight = NO;
    if (indexPath.section == 0 && indexPath.row < 3) {
        shouldHighlight = YES;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        shouldHighlight = YES;
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isEqual:_shipmentJNEMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentJNEAWBCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentTikiMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentRPXIDropCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentRPXMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentWahanaMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentPosMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentCahayaMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentPanduMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_firstMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_gojekMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_siCepatMoreInfoCell]) {
            shouldHighlight = YES;
        }
    }
    return shouldHighlight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Pilih Lokasi";
        controller.delegate = self;
        controller.enableSearch = YES;
        controller.senderIndexPath = indexPath;
        
        if (indexPath.row == 0) {
            controller.objects = _availableProvinceName;
            controller.selectedObject = _shipment.shop_shipping.province_name;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == 1) {
            controller.objects = _availableCityName;
            controller.selectedObject = _shipment.shop_shipping.city_name;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == 2) {
            controller.objects = _availableDistrictName;
            controller.selectedObject = _shipment.shop_shipping.district_name;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        CLLocationCoordinate2D coordinate;
        if (_shipment.shop_shipping.latitude && _shipment.shop_shipping.longitude) {
            coordinate = CLLocationCoordinate2DMake(_shipment.shop_shipping.latitude, _shipment.shop_shipping.longitude);
        } else {
            coordinate = CLLocationCoordinate2DMake(0, 0);
        }
        [NavigateViewController navigateToMap:coordinate type:TypeEditPlace fromViewController:self];
        
    } else if (indexPath.section == 3 && indexPath.row == 4) {
        AlertInfoView *alert = [AlertInfoView newview];
        alert.text = @"Sistem AWB Otomatis";
        alert.detailText = @"Dengan menggunakan Sistem Kode Resi Otomatis, Anda tidak perlu lagi melakukan input nomor resi secara manual. Cukup cetak kode booking dan tunjukkan ke agen JNE yang mendukung, nomor resi akan otomatis masuk ke Tokopedia.";
        [alert show];
        
        CGRect frame = alert.frame;
        frame.origin.y -= 25;
        frame.size.height += (alert.detailTextLabel.frame.size.height-50);
        alert.frame = frame;
        
    } else if (indexPath.section == 5 && indexPath.row == 1) {
        AlertInfoView *alert = [AlertInfoView newview];
        alert.text = @"Sistem I-Drop";
        alert.detailText = @"I-Drop adalah kurir pengiriman kerja sama RPX dan Indomaret, nantinya barang yang Anda akan kirimkan menggunakan RPX bisa diantar ke Indomaret terdekat.";
        [alert show];
        
        CGRect frame = alert.frame;
        frame.origin.y -= 25;
        frame.size.height += (alert.detailTextLabel.frame.size.height-50);
        alert.frame = frame;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([_weightCollection containsObject:cell]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:(255.0/255.0) green:(249/255.0) blue:(196/255.0) alpha:1.0]];
    } else if ([_notSupportedCellColleciton containsObject:cell]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:(251.0/255.0) green:(227/255.0) blue:(228/255.0) alpha:1.0]];
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (section == 0) {
        title = @"    Kota Asal";
    } else if (section == 1) {
        title = @"    Lokasi Pickup";
    } else if (section == 2) {
        if (createShopViewController) {
            title = nil;
        } else {
            title = @"    Nomor HP";
        }
    } else if (section == 3) {
        title = @"    Shipping Services";
    }
    return title;
}

#pragma mark - Actions
- (void)validateShipment
{
    NSMutableArray *errorMessage = [NSMutableArray new];
    if(_showJNEExtraFeeTextField) {
        if(((long)_shipment.jne.jne_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan JNE harus diisi."];
        }
    }
    
    if(_showTikiExtraFee) {
        if(((long)_shipment.tiki.tiki_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan Tiki harus diisi."];
        }
    }
    
    if(_showPosExtraFee) {
        if(((long)_shipment.pos.pos_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan Pos Indonesia harus diisi."];
        }
    }
    
    if(errorMessage.count == 0) {
        if(createShopViewController) {
            if(![self hasSelectedShipping]) {
                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringSelectedShipping] delegate:self];
                [stickyAlertView show];
                
                return;
            }
        }        
        
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *_auth = [_userManager getUserLoginData];
        
        MyShopPaymentViewController *myShopPaymentViewController = [MyShopPaymentViewController new];
        myShopPaymentViewController.data = @{kTKPD_AUTHKEY:[_auth objectForKey:kTKPD_AUTHKEY]?:@{}};
        myShopPaymentViewController.arrDataPayment = _shipment.payment_options;
        myShopPaymentViewController.myShopShipmentTableViewController = self;
        [self.navigationController pushViewController:myShopPaymentViewController animated:YES];
    }
    else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
}


- (void)tap:(id)sender {
    if(createShopViewController) {
        [self validateShipment];
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self configureRestKitAction];
        [self requestAction];
    }
}

- (IBAction)valueChangedSwitch:(UISwitch *)sender {
    // actions for JNE
    if ([sender isEqual:_shipmentJNEYesSwitch]) {
        if (sender.isOn) {
            _JNEPackageYes.active = @"1";
        } else {
            _JNEPackageYes.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentJNERegulerSwitch]) {
        if (sender.isOn) {
            _JNEPackageReguler.active = @"1";
        } else {
            _JNEPackageReguler.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentJNEOkeSwitch]) {
        if (sender.isOn) {
            _JNEPackageOke.active = @"1";
        } else {
            _JNEPackageOke.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentJNEAWBSwitch]) {
        if (sender.isOn) {
            _shipment.jne.jne_tiket = @"1";
            NSMutableArray *autoResi = [_shipment.auto_resi mutableCopy];
            [autoResi addObject:_JNE.shipment_id];
            _shipment.auto_resi = autoResi;
        } else {
            _shipment.jne.jne_tiket = @"0";
            NSMutableArray *autoResi = [_shipment.auto_resi mutableCopy];
            [autoResi removeObject:_JNE.shipment_id];
            _shipment.auto_resi = autoResi;
        }
    }
    else if ([sender isEqual:_shipmentJNEMinimumWeightSwitch]) {
        _showJNEMinimumWeightTextField = sender.isOn;
        if (!sender.isOn) {
            _shipmentJNEMinimumWeightTextField.text = @"";
            _shipment.jne.jne_min_weight = @"";
        }
    }
    else if ([sender isEqual:_shipmentJNEDifferentDistrictSwitch]) {
        if (sender.isOn) {
            _shipment.jne.jne_diff_district = @"1";
        } else {
            _shipment.jne.jne_diff_district = @"0";
        }
    }
    else if ([sender isEqual:_shipmentJNEExtraFeeSwitch]) {
        _showJNEExtraFeeTextField = sender.isOn;
        if (!sender.isOn) {
            _shipmentJNEExtraFeeTextField.text = @"";
            _shipment.jne.jne_fee = 0;
        }
    }
    
    
    // actions for TIKI
    else if ([sender isEqual:_shipmentTikiRegulerSwitch]) {
        if (sender.isOn) {
            _tikiPackageReguler.active = @"1";
        } else {
            _tikiPackageReguler.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentTikiONSSwitch]) {
        if (sender.isOn) {
            _tikiPackageONS.active = @"1";
        } else {
            _tikiPackageONS.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentTikiExtraFeeSwitch]) {
        _showTikiExtraFee = sender.isOn;
        if (!sender.isOn) {
            _shipmentTikiExtraFeeTextField.text = @"";
            _shipment.tiki.tiki_fee = 0;
        }
    }
    
    
    // actions for RPX
    
    else if ([sender isEqual:_shipmentRPXIDropSwitch]) {
        NSNumber *number = [NSNumber numberWithInteger:[_RPX.shipment_id integerValue]];
        NSMutableArray *tempAutoResi = [_shipment.auto_resi mutableCopy];
        if (sender.isOn) {
            _RPXPackageNextDay.active = @"0";
            [_shipmentRPXNextDaySwitch setOn:NO animated:YES];
            
            _RPXPackageEconomy.active = @"1";
            [_shipmentRPXEconomySwitch setOn:YES animated:YES];
            
            [tempAutoResi addObject:number];
        } else {
            [tempAutoResi removeObject:number];
        }
        _shipment.auto_resi = tempAutoResi;
    }
    else if ([sender isEqual:_shipmentRPXNextDaySwitch]) {
        NSNumber *number = [NSNumber numberWithInteger:[_RPX.shipment_id integerValue]];
        NSMutableArray *tempAutoResi = [_shipment.auto_resi mutableCopy];
        if (sender.isOn) {
            _RPXPackageNextDay.active = @"1";
            [_shipmentRPXIDropSwitch setOn:NO animated:YES];
            [tempAutoResi removeObject:number];
        } else {
            _RPXPackageNextDay.active = @"0";
        }
        _shipment.auto_resi = tempAutoResi;
    }
    else if ([sender isEqual:_shipmentRPXEconomySwitch]) {
        NSNumber *number = [NSNumber numberWithInteger:[_RPX.shipment_id integerValue]];
        NSMutableArray *tempAutoResi = [_shipment.auto_resi mutableCopy];
        if (sender.isOn) {
            _RPXPackageEconomy.active = @"1";
            
        } else {
            _RPXPackageEconomy.active = @"0";
            [tempAutoResi removeObject:number];
            [_shipmentRPXIDropSwitch setOn:NO animated:YES];
        }
        _shipment.auto_resi = tempAutoResi;
    }
    
    
    // actions for WAHANA
    else if ([sender isEqual:_shipmentWahanaNextDaySwitch]) {
        if (sender.isOn) {
            _wahanaPackageNormal.active = @"1";
        } else {
            _wahanaPackageNormal.active = @"0";
        }
    }
    
    
    // actions for POS INDONESIA
    else if ([sender isEqual:_shipmentPosKilatKhususSwitch]) {
        if (sender.isOn) {
            _posPackageKhusus.active = @"1";
        } else {
            _posPackageKhusus.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentPosBiasaSwitch]) {
        if (sender.isOn) {
            _posPackageBiasa.active = @"1";
        } else {
            _posPackageBiasa.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentPosExpressSwitch]) {
        if (sender.isOn) {
            _posPackageExpress.active = @"1";
        } else {
            _posPackageExpress.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentPosMinWeightSwitch]) {
        _showPosMinimumWeight = sender.isOn;
        if (!sender.isOn) {
            _shipmentPosMinWeightTextField.text = @"";
            _shipment.pos.pos_min_weight = 0;
        }
    }
    else if ([sender isEqual:_shipmentPosExtraFeeSwitch]) {
        _showPosExtraFee = sender.isOn;
        if (!sender.isOn) {
            _shipmentPosExtraFeeTextField.text = @"";
            _shipment.pos.pos_fee = 0;
        }
    }
    
    
    // actions for CAHAYA
    else if ([sender isEqual:_shipmentCahayaNormalSwitch]) {
        if (sender.isOn) {
            _cahayaPackageNormal.active = @"1";
        } else {
            _cahayaPackageNormal.active = @"0";
        }
    }
    
    
    // actions for PANDU
    else if ([sender isEqual:_shipmentPanduRegulerSwitch]) {
        if (sender.isOn) {
            _panduPackageRegular.active = @"1";
        } else {
            _panduPackageRegular.active = @"0";
        }
    }

    // actions for First
    else if ([sender isEqual:_firstRegulerSwitch]) {
        if (sender.isOn) {
            _firstPackageRegular.active = @"1";
        } else {
            _firstPackageRegular.active = @"0";
        }
    }
    
    // actions for gojek
    
    else if ([sender isEqual:_gojekGoKilatSwitch]) {
        if (sender.isOn) {
            _gojekPackageGoKilat.active = @"1";
        } else {
            _gojekPackageGoKilat.active = @"0";
        }
    }

    // actions for SiCepat
    else if ([sender isEqual:_siCepatRegulerSwitch]) {
        if (sender.isOn) {
            _siCepatPackageRegular.active = @"1";
        } else {
            _siCepatPackageRegular.active = @"0";
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_postCodeTextField]) {
        _shipment.shop_shipping.postal_code = textField.text;
        [self validateSaveButton];
    } else if ([textField isEqual:_shipmentJNEMinimumWeightTextField]) {
        _shipment.jne.jne_min_weight = textField.text;
    } else if ([textField isEqual:_shipmentJNEExtraFeeTextField]) {
        _shipment.jne.jne_fee = [textField.text integerValue];
    } else if ([textField isEqual:_shipmentTikiExtraFeeTextField]) {
        _shipment.tiki.tiki_fee = [textField.text integerValue];
    } else if ([textField isEqual:_shipmentPosMinWeightTextField]) {
        _shipment.pos.pos_min_weight = [textField.text integerValue];
    } else if ([textField isEqual:_shipmentPosExtraFeeTextField]) {
        _shipment.pos.pos_fee = [textField.text integerValue];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            _hasSelectKotaAsal = NO;
            
            NSInteger index = [_availableProvinceName indexOfObject:object];
            Province *province = [_provinces objectAtIndex:index];
            
            _shipment.shop_shipping.province_id = province.province_id;
            _shipment.shop_shipping.province_name = province.province_name;

            _provinceLabel.text = province.province_name;
            _cityLabel.text = @"Pilih Kotamadya";
            _districtLabel.text = @"Pilih Kecamatan";
            
            _cities = province.cities;
            
            // If jakarta, add map and user location address, and shows all available couriers.
            if ([province.province_name isEqualToString:@"DKI Jakarta"] ||
                province.province_id == 13) {
                _hasSelectKotaAsal = YES;
                
                NSMutableArray *shipmentIds = [NSMutableArray new];
                for (ShippingInfoShipments *shipment in _shipment.shipment) {
                    [shipmentIds addObject:shipment.shipment_id];
                }
                _availableShipments = shipmentIds;

                // ID DKI
                _shipment.shop_shipping.district_id = 5573;
                
            } else {
                NSMutableArray *citiesName = [NSMutableArray new];
                for (City *city in _cities) {
                    if (city.city_id == _shipment.shop_shipping.city_id) {
                        _disticts = city.districts;
                    }
                    [citiesName addObject:city.city_name];
                }
                _availableCityName = citiesName;
        
                _shipment.shop_shipping.city_id = 0;
                _shipment.shop_shipping.city_name = nil;
                
                _shipment.shop_shipping.district_id = 0;
                _shipment.shop_shipping.district_name = nil;
            }
        } else if (indexPath.row == 1) {
            
            _hasSelectKotaAsal = NO;

            NSInteger index = [_availableCityName indexOfObject:object];
            City *city = [_cities objectAtIndex:index];
            
            _cityLabel.text = city.city_name;
            _districtLabel.text = @"Pilih Kecamatan";
            
            _disticts = city.districts;
            
            NSMutableArray *districtsName = [NSMutableArray new];
            for (District *district in _disticts) {
                [districtsName addObject:district.district_name];
            }
            _availableDistrictName = districtsName;

            _shipment.shop_shipping.city_id = city.city_id;
            _shipment.shop_shipping.city_name = city.city_name;

            _shipment.shop_shipping.district_id = 0;
            _shipment.shop_shipping.district_name = nil;
            
        } else if (indexPath.row == 2) {
            
            _hasSelectKotaAsal = YES;
            
            [self validateSaveButton];
            
            NSInteger index = [_availableDistrictName indexOfObject:object];
            District *district = [_disticts objectAtIndex:index];
            
            _districtLabel.text = district.district_name;
            
            if(createShopViewController != nil && _shipment.shop_shipping == nil) {
                _shipment.shop_shipping = [ShopShipping new];
            }
            
            _shipment.shop_shipping.district_name = district.district_name;
            _shipment.shop_shipping.district_id = district.district_id;
            
            _availableShipments = district.district_shipping_supported;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Restkit

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManager.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    // setup object mappings
    RKObjectMapping *shippingMapping = [RKObjectMapping mappingForClass:[ShippingInfo class]];
    [shippingMapping addAttributeMappingsFromArray:@[
                                                     kTKPD_APIERRORMESSAGEKEY,
                                                     kTKPD_APISTATUSKEY,
                                                     kTKPD_APISERVERPROCESSTIMEKEY,
                                                     ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShippingInfoResult class]];
    [resultMapping addAttributeMappingsFromArray:@[
                                                   kTKPDDETAILSHOP_APIPAYMENTLOCKEY,
                                                   kTKPDDETAILSHOP_APIPAYMENTNOTEKEY,
                                                   kTKPDSHOPSHIPMENT_APITIKIFEEKEY,
                                                   kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY,
                                                   kTKPDSHOPSHIPMENT_APIISALLOWKEY,
                                                   kTKPDSHOPSHIPMENT_APIPOSFEEKEY,
                                                   kTKPDSHOPSHIPMENT_APISHOPNAMEKEY,
                                                   kTKPDSHOPSHIPMENT_APIAUTORESIKEY,
                                                   kTKPDSHOPSHIPMENT_APIALLOW_ACTIVATE_GOJEKKEY
                                                   ]];
    
    RKObjectMapping *provinceMapping = [RKObjectMapping mappingForClass:[Province class]];
    [provinceMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIPROVINCEIDKEY,
                                                     kTKPDSHOPSHIPMENT_APIPROVINCENAMEKEY,
                                                     ]];
    
    RKObjectMapping *cityMapping = [RKObjectMapping mappingForClass:[City class]];
    [cityMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APICITYIDKEY,
                                                 kTKPDSHOPSHIPMENT_APICITYNAMEKEY,
                                                 ]];

    RKObjectMapping *districtMapping = [RKObjectMapping mappingForClass:[District class]];
    [districtMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY,
                                                     kTKPDSHOPSHIPMENT_APIDISTRICTSHIPPINGSUPPORTEDKEY,
                                                     kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY,
                                                     ]];

    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipments class]];
    [shipmentsMapping addAttributeMappingsFromArray:@[
                                                      kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY,
                                                      kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY,
                                                      kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY,
                                                      kTKPDSHOPSHIPMENT_APISHIPMENTAVAILABLEKEY,
                                                      ]];
    
    RKObjectMapping *shipmentsPackageMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipmentPackage class]];
    [shipmentsPackageMapping addAttributeMappingsFromArray:@[
                                                             kTKPDSHOPSHIPMENT_APIDESCKEY,
                                                             kTKPDSHOPSHIPMENT_APIACTIVEKEY,
                                                             kTKPDSHOPSHIPMENT_APINAMEKEY,
                                                             kTKPDSHOPSHIPMENT_APISPIDKEY,
                                                             ]];
    
    RKObjectMapping *JNEMapping = [RKObjectMapping mappingForClass:[JNE class]];
    [JNEMapping addAttributeMappingsFromArray:@[
                                                kTKPDSHOPSHIPMENT_APIJNEFEEKEY,
                                                kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY,
                                                kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY,
                                                kTKPDSHOPSHIPMENT_APIJNETICKETKEY
                                                ]];
    
    RKObjectMapping *POSMapping = [RKObjectMapping mappingForClass:[POSIndonesia class]];
    [POSMapping addAttributeMappingsFromArray:@[
                                                kTKPDSHOPSHIPMENT_APIPOSFEEKEY,
                                                kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY,
                                                ]];
    
    RKObjectMapping *tikiMapping = [RKObjectMapping mappingForClass:[Tiki class]];
    [tikiMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APITIKIFEEKEY]];
    
    RKObjectMapping *RPXMapping = [RKObjectMapping mappingForClass:[RPX class]];
    [RPXMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIRPXWHITELISTEDIDROPKEY:kTKPDSHOPSHIPMENT_APIRPXWHITELISTEDIDROPKEY,
                                                     kTKPDSHOPSHIPMENT_APIRPXINDOMARETLOGOKEY:kTKPDSHOPSHIPMENT_APIRPXINDOMARETLOGOKEY
                                                     }];
    
    RKObjectMapping *posWeightMapping = [RKObjectMapping mappingForClass:[PosMinWeight class]];
    [posWeightMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY,
                                                      kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY]];

    RKObjectMapping *gojekMapping = [RKObjectMapping mappingForClass:[Gojek class]];
    [gojekMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIGOJEKWHITELISTEDKEY]];

    RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[ShippingContact class]];
    [contactMapping addAttributeMappingsFromArray:@[@"messenger_enc",
                                                    @"msisdn_enc",
                                                    @"msisdn_verification",
                                                    @"user_email_enc",]];
    
    RKObjectMapping *shopShippingMapping = [RKObjectMapping mappingForClass:[ShopShipping class]];
    [shopShippingMapping addAttributeMappingsFromArray:@[
                                                         kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY,
                                                         kTKPDSHOPSHIPMENT_APIORIGINKEY,
                                                         kTKPDSHOPSHIPMENT_APISHIPPINGIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISCTRICTSUPPORTEDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY,
                                                         kTKPDSHOPSHIPMENT_APICITYIDKEY,
                                                         kTKPDSHOPSHIPMENT_APICITYNAMEKEY,
                                                         kTKPDSHOPSHIPMENT_APIPROVINCEIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIPROVINCENAMEKEY,
                                                         kTKPDSHOPSHIPMENT_APIADDR_STREETKEY,
                                                         kTKPDSHOPSHIPMENT_APILATITUDEKAY,
                                                         kTKPDSHOPSHIPMENT_APILONGITUDEKEY
                                                         ]];
    
    // Relationship Mapping
    RKRelationshipMapping *provinceRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPROVINCESKEY
                                                                                     toKeyPath:kTKPDSHOPSHIPMENT_APIPROVINCESKEY
                                                                                   withMapping:provinceMapping];
    [resultMapping addPropertyMapping:provinceRel];
    
    RKRelationshipMapping *cityRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APICITIESKEY
                                                                                 toKeyPath:kTKPDSHOPSHIPMENT_APICITIESKEY
                                                                               withMapping:cityMapping];
    [provinceMapping addPropertyMapping:cityRel];
    
    RKRelationshipMapping *districtRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTSKEY
                                                                                     toKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTSKEY
                                                                                   withMapping:districtMapping];
    [cityMapping addPropertyMapping:districtRel];
    
    if(createShopViewController != nil)
    {
        RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
        [paymentMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                        kTKPDDETAILSHOP_APIPAYMENTIDKEY,
                                                        kTKPDDETAILSHOP_APIPAYMENTNAMEKEY,
                                                        kTKPDDETAILSHOP_APIPAYMENTINFOKEY,
                                                        kTKPDDETAILSHOP_APIPAYMENTDEFAULTSTATUSKEY
                                                        ]];
        RKRelationshipMapping *paymentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTOPTIONKEY toKeyPath:kTKPDDETAILSHOP_APIPAYMENTOPTIONKEY withMapping:paymentMapping];
        [resultMapping addPropertyMapping:paymentRel];
    }
    
    RKRelationshipMapping *shipmentsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTKEY
                                                                                      toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTKEY
                                                                                    withMapping:shipmentsMapping];
    [resultMapping addPropertyMapping:shipmentsRel];
    
    RKRelationshipMapping *JNERel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIJNEKEY
                                                                                toKeyPath:kTKPDSHOPSHIPMENT_APIJNEKEY
                                                                              withMapping:JNEMapping];
    [resultMapping addPropertyMapping:JNERel];
    
    RKRelationshipMapping *tikiRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APITIKIKEY
                                                                                 toKeyPath:kTKPDSHOPSHIPMENT_APITIKIKEY
                                                                               withMapping:tikiMapping];
    [resultMapping addPropertyMapping:tikiRel];
    
    RKRelationshipMapping *posRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSKEY
                                                                                toKeyPath:kTKPDSHOPSHIPMENT_APIPOSKEY
                                                                              withMapping:POSMapping];
    [resultMapping addPropertyMapping:posRel];
    
    RKRelationshipMapping *rpxRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIRPXKEY toKeyPath:kTKPDSHOPSHIPMENT_APIRPXKEY withMapping:RPXMapping];
    [resultMapping addPropertyMapping:rpxRel];
    
    RKRelationshipMapping *shipmentpackagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY
                                                                                             toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY
                                                                                           withMapping:shipmentsPackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackagesRel];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY
                                                                                  toKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY
                                                                                withMapping:posWeightMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIGOJEKKEY
                                                                                  toKeyPath:kTKPDSHOPSHIPMENT_APIGOJEKKEY
                                                                                withMapping:gojekMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact"
                                                                                  toKeyPath:@"contact"
                                                                                withMapping:contactMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY
                                                                                  toKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY
                                                                                withMapping:shopShippingMapping]];
    
    [shippingMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                    toKeyPath:kTKPD_APIRESULTKEY
                                                                                  withMapping:resultMapping]];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shippingMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:(createShopViewController!=nil? kTKPMYSHOP_APIPATH : kTKPDSHOPSHIPMENT_APIPATH)
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}


- (void)request
{
    if (_request.isExecuting) return;
    
    [_loadingView startAnimating];
    self.tableView.sectionFooterHeight = 0;
    self.tableView.sectionHeaderHeight = 0;
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : (createShopViewController!=nil?kTKPDDETAIL_APIGET_OPEN_SHOP_FORM : kTKPDDETAIL_APIGETSHOPSHIPPINGINFOKEY)};
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:(createShopViewController!=nil? kTKPMYSHOP_APIPATH : kTKPDSHOPSHIPMENT_APIPATH)
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessResult:mappingResult withOperation:operation];
        self.tableView.sectionFooterHeight = 10;
        self.tableView.sectionHeaderHeight = 10;
        [self.tableView reloadData];
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestError:error withOperation:operation];
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
    }];
    
    [_operationQueue addOperation:_request];
}

- (void)requestSuccessResult:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation {
    ShippingInfo *shippingInfo = [result.dictionary objectForKey:@""];
    BOOL status = [shippingInfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (shippingInfo.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:shippingInfo.message_error delegate:self];
        [alert show];
    } else if (status) {
        _shipment = shippingInfo.result;
        _availableShipments = _shipment.shop_shipping.district_shipping_supported;
        _provinces = _shipment.provinces_cities_districts;

        _postCodeTextField.text = _shipment.shop_shipping.postal_code;

        [_addressTextView setPlaceholder:@"Alamat Pickup (optional)"];
        _addressTextView.text = _shipment.shop_shipping.addr_street;
        
        double latitude = _shipment.shop_shipping.latitude;
        double longitude = _shipment.shop_shipping.longitude;
        if (latitude && longitude) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate
                                           completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                   if (error != nil){
                       return;
                   }
                   if (response == nil|| response.results.count == 0) {
                       self.pickupLocationLabel.text = [NSString stringWithFormat:@"Tandai lokasi Anda"];
                   } else {
                       GMSAddress *placemark = [response results][0];
                       self.pickupLocationLabel.text = [self streetNameFromAddress:placemark];
                   }
            }];
        } else {
            self.pickupLocationLabel.text = @"Tentukan Peta Lokasi";
        }
        
        [self createShopDefaultValues];
        [self setProvincesData];
        [self setProvincesLabelValue];
        [self showsPhoneNumber];
        
        for (ShippingInfoShipments *shipment in _shipment.shipment) {
            NSInteger shipmentId = [shipment.shipment_id integerValue];
            if (shipmentId == 1) {
                self.JNE = shipment;
                [self setJNEValues];
            } else if (shipmentId == 2) {
                self.tiki = shipment;
                [self setTikiValues];
            } else if (shipmentId == 3) {
                self.RPX = shipment;
                [self setRPXValues];
            } else if (shipmentId == 4) {
                self.posIndonesia = shipment;
                [self setPosValues];
            } else if (shipmentId == 6) {
                self.wahana = shipment;
                [self setWahanaValues];
            } else if (shipmentId == 7) {
                self.cahaya = shipment;
                [self setCahayaValues];
            } else if (shipmentId == 8) {
                self.pandu = shipment;
                [self setPanduValues];
            } else if (shipmentId == 9) {
                self.first = shipment;
                [self setFirstValues];
            } else if (shipmentId == 10) {
                if (createShopViewController) {
                    if ([_shipment.allow_activate_gojek boolValue]) {
                        self.gojek = shipment;
                    }
                } else {
                    if ([_shipment.gojek.whitelisted boolValue]) {
                        self.gojek = shipment;
                    }
                }
                [self setGojekValues];
            } else if (shipmentId == 11) {
                self.siCepat = shipment;
                [self setSiCepatValues];
            }
        }
        
        //Set Note for pay
        for (Payment *payment in _shipment.payment_options) {
            if ([_shipment.loc objectForKey:payment.payment_id]) {
                payment.payment_info = [_shipment.loc objectForKey:payment.payment_id];
            }
        }
        
        [self validateSaveButton];
        
        [self.tableView reloadData];
    }
}

- (NSString *)streetNameFromAddress:(GMSAddress *)address {
    NSString *strSnippet = @"Tentukan Peta Lokasi";
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    strSnippet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    return strSnippet;
}

- (void)requestError:(NSError *)error withOperation:(RKObjectRequestOperation *)operation {}

#pragma mark - Method

- (void)createShopDefaultValues {
    if (createShopViewController) {
        if(_shipment.jne == nil) {
            _shipment.jne = [JNE new];
            _shipment.jne.jne_fee = 0;
            _shipment.jne.jne_diff_district = @"0";
            _shipment.jne.jne_min_weight = @"";
            _shipment.jne.jne_tiket = @"0";
        }
        if(_shipment.tiki == nil) {
            _shipment.tiki = [Tiki new];
            _shipment.tiki.tiki_fee = 0;
        }
        if(_shipment.pos == nil) {
            _shipment.pos = [POSIndonesia new];
            _shipment.pos.pos_fee = 0;
            _shipment.pos.pos_min_weight = 0;
        }
        if (_shipment.shop_shipping == nil) {
            _shipment.shop_shipping = [ShopShipping new];
        }
    }
}

- (void)setProvincesData {
    NSMutableArray *provincesName = [NSMutableArray new];
    for (Province *province in _shipment.provinces_cities_districts) {
        if (province.province_id == _shipment.shop_shipping.province_id) {
            _cities = province.cities;
        }
        [provincesName addObject:province.province_name];
    }
    _provinces = _shipment.provinces_cities_districts;
    _availableProvinceName = provincesName;

    NSMutableArray *citiesName = [NSMutableArray new];
    for (City *city in _cities) {
        if (city.city_id == _shipment.shop_shipping.city_id) {
            _disticts = city.districts;
        }
        [citiesName addObject:city.city_name];
    }
    _availableCityName = citiesName;

    NSMutableArray *districtsName = [NSMutableArray new];
    for (District *district in _disticts) {
        [districtsName addObject:district.district_name];
    }
    _availableDistrictName = districtsName;
}

- (void)setProvincesLabelValue {
    if (_shipment.shop_shipping.province_name) {
        _provinceLabel.text = _shipment.shop_shipping.province_name;
    } else {
        _provinceLabel.text = @"Pilih Provinsi";
    }
    
    if (_shipment.shop_shipping.city_name) {
        _cityLabel.text = _shipment.shop_shipping.city_name;
    } else {
        _cityLabel.text = @"Pilih Kotamadya";
    }
    
    if (_shipment.shop_shipping.district_name) {
        _districtLabel.text = _shipment.shop_shipping.district_name;
        _hasSelectKotaAsal = YES;
    } else {
        _districtLabel.text = @"Pilih Kecamatan";
    }
}

- (void)showsPhoneNumber {
    _phoneNumberLabel.text = _shipment.contact.msisdn_enc;
}

- (void)setJNE:(ShippingInfoShipments *)shipment {
    _JNE = shipment;
    for (ShippingInfoShipmentPackage *package in _JNE.shipment_package) {
        if ([package.sp_id isEqualToString:@"6"]) {
            // YES
            _JNEPackageYes = package;
        } else if ([package.sp_id isEqualToString:@"1"]) {
            // Reguler
            _JNEPackageReguler = package;
        } else  if ([package.sp_id isEqualToString:@"2"]) {
            // OKE
            _JNEPackageOke = package;
        }
    }
}

- (void)setJNEValues {
    _shipmentJNENameLabel.text = _JNE.shipment_name;
    NSURL *url = [NSURL URLWithString:_JNE.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentJNELogoImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  _shipmentJNELogoImageView.image = image;
                                              } failure:nil];
    
    if (_JNEPackageReguler) {
        _shipmentJNERegulerLabel.text = _JNEPackageReguler.name;
        _shipmentJNERegulerSwitch.on = [_JNEPackageReguler.active boolValue];
    }
    
    if (_JNEPackageYes) {
        _shipmentJNEYesLabel.text = _JNEPackageYes.name;
        _shipmentJNEYesSwitch.on = [_JNEPackageYes.active boolValue];
    }
    
    if (_JNEPackageOke) {
        _shipmentJNEOkeLabel.text = _JNEPackageOke.name;
        _shipmentJNEOkeSwitch.on = [_JNEPackageOke.active boolValue];
    }
    
    _shipmentJNEAWBSwitch.on = [_shipment.jne.jne_tiket boolValue];
    
    if ([_JNEPackageOke.active boolValue] ||
        [_JNEPackageReguler.active boolValue] ||
        [_JNEPackageYes.active boolValue]) {
        _showJNEAWBSwitch = YES;
    } else {
        _showJNEAWBSwitch = NO;
    }
    
    if ([_shipment.jne.jne_min_weight isEqualToString:@""] ||
        [_shipment.jne.jne_min_weight isEqualToString:@"0"]) {
        _shipmentJNEMinimumWeightSwitch.on = NO;
        _showJNEMinimumWeightTextField = NO;
    } else {
        _shipmentJNEMinimumWeightSwitch.on = YES;
        _shipmentJNEMinimumWeightTextField.text = _shipment.jne.jne_min_weight;
        _showJNEMinimumWeightTextField = YES;
    }
    
    _shipmentJNEDifferentDistrictSwitch.on = [_shipment.jne.jne_diff_district boolValue];
    
    if (_shipment.jne.jne_fee == 0) {
        _shipmentJNEExtraFeeSwitch.on = NO;
        _showJNEExtraFeeTextField = NO;
    } else {
        _shipmentJNEExtraFeeSwitch.on = YES;
        _shipmentJNEExtraFeeTextField.text = [NSString stringWithFormat:@"%ld", (long)_shipment.jne.jne_fee];
        _showJNEExtraFeeTextField = YES;
    }
}

- (void)setTiki:(ShippingInfoShipments *)shipment {
    _tiki = shipment;
    for (ShippingInfoShipmentPackage *package in _tiki.shipment_package) {
        if ([package.sp_id isEqualToString:@"3"]) {
            // Reguler
            _tikiPackageReguler = package;
        } else if ([package.sp_id isEqualToString:@"16"]) {
            // One Night Service
            _tikiPackageONS = package;
        }
    }
}

- (void)setTikiValues {
    _shipmentTikiNameLabel.text = _tiki.shipment_name;
    NSURL *url = [NSURL URLWithString:_tiki.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentTikiLogoImageView setImageWithURLRequest:request
                                      placeholderImage:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   _shipmentTikiLogoImageView.image = image;
                                               } failure:nil];
    
    if (_tikiPackageReguler) {
        _shipmentTikiRegulerLabel.text = _tikiPackageReguler.name;
        _shipmentTikiRegulerSwitch.on = [_tikiPackageReguler.active boolValue];
    }
    
    if (_tikiPackageONS) {
        _shipmentTikiONSLabel.text = _tikiPackageONS.name;
        _shipmentTikiONSSwitch.on = [_tikiPackageONS.active boolValue];
    }
    
    if (_shipment.tiki.tiki_fee == 0) {
        _shipmentTikiExtraFeeSwitch.on = NO;
        _showTikiExtraFee = NO;
    } else {
        _shipmentTikiExtraFeeSwitch.on = YES;
        _shipmentTikiExtraFeeTextField.text = [NSString stringWithFormat:@"%ld", (long)_shipment.tiki.tiki_fee];
        _showTikiExtraFee = YES;
    }
}

- (void)setRPX:(ShippingInfoShipments *)shipment {
    _RPX = shipment;
    for (ShippingInfoShipmentPackage *package in _RPX.shipment_package) {
        if ([package.sp_id isEqualToString:@"4"]) {
            // Next Day Package
            _RPXPackageNextDay = package;
        } else if ([package.sp_id isEqualToString:@"5"]) {
            // Reguler Package (Live) || Economy Package (Staging)
            _RPXPackageEconomy = package;
        }
    }
}

- (void)setRPXValues {
    _shipmentRPXNameLabel.text = _RPX.shipment_name;
    NSURL *url = [NSURL URLWithString:_RPX.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentRPXLogoImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  _shipmentRPXLogoImageView.image = image;
                                              } failure:nil];
    /*
     TODO
     add Indomaret logo image
     */
    
    NSURL *urlIndomaret = [NSURL URLWithString:_shipment.rpx.indomaret_logo];
    NSURLRequest *requestLogoIndomaret = [NSURLRequest requestWithURL:urlIndomaret];
    
    if (_shipment.rpx.whitelisted_idrop) {
        [_shipmentRPXLogoIndomaretView setImageWithURLRequest:requestLogoIndomaret
                                             placeholderImage:nil
                                                      success:^(NSURLRequest *request, NSURLResponse *response, UIImage *image) {
                                                          _shipmentRPXLogoIndomaretView.image = image;
                                                      } failure:nil];
    }
    
    NSNumber *number = [NSNumber numberWithInteger:[_RPX.shipment_id integerValue]];
    _shipmentRPXIDropSwitch.on = [_shipment.auto_resi containsObject:number];
    
    if (_RPXPackageEconomy) {
        _shipmentRPXEconomySwitch.on = [_RPXPackageEconomy.active boolValue];
    }
    
    if (_RPXPackageNextDay) {
        _shipmentRPXNextDaySwitch.on = [_RPXPackageNextDay.active boolValue];
    }
}

- (void)setWahana:(ShippingInfoShipments *)shipment {
    _wahana = shipment;
    for (ShippingInfoShipmentPackage *package in _wahana.shipment_package) {
        if ([package.sp_id isEqualToString:@"8"]) { // Service Normal
            _wahanaPackageNormal = package;
        }
    }
}

- (void)setWahanaValues {
    _shipmentWahanaNameLabel.text = _wahana.shipment_name;
    NSURL *url = [NSURL URLWithString:_wahana.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentWahanaLogoImageView setImageWithURLRequest:request
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     _shipmentWahanaLogoImageView.image = image;
                                                 } failure:nil];
    
    if (_wahanaPackageNormal) {
        _shipmentWahanaNextDayLabel.text = _wahanaPackageNormal.name;
        _shipmentWahanaNextDaySwitch.on = [_wahanaPackageNormal.active boolValue];
    }
}

- (void)setPosIndonesia:(ShippingInfoShipments *)posIndonesia {
    _posIndonesia = posIndonesia;
    for (ShippingInfoShipmentPackage *package in _posIndonesia.shipment_package) {
        if ([package.sp_id isEqualToString:@"10"]) { // Pos Kilat Khusus
            _posPackageKhusus = package;
        } else if ([package.sp_id isEqualToString:@"9"]) { // Paket Biasa
            _posPackageBiasa = package;
        } else if ([package.sp_id isEqualToString:@"11"]) { // Pos Express
            _posPackageExpress = package;
        }
    }
}

- (void)setPosValues {
    _shipmentPosNameLabel.text = _posIndonesia.shipment_name;
    NSURL *url = [NSURL URLWithString:_posIndonesia.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentPosLogoImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  _shipmentPosLogoImageView.image = image;
                                              } failure:nil];
    
    if (_posPackageKhusus) {
        _shipmentPosKilatKhususLabel.text = _posPackageKhusus.name;
        _shipmentPosKilatKhususSwitch.on = [_posPackageKhusus.active boolValue];
    }
    
    if (_posPackageBiasa) {
        _shipmentPosBiasaLabel.text = _posPackageBiasa.name;
        _shipmentPosBiasaSwitch.on = [_posPackageBiasa.active boolValue];
    }
    
    if (_posPackageExpress) {
        _shipmentPosExpressLabel.text = _posPackageExpress.name;
        _shipmentPosExpressSwitch.on = [_posPackageExpress.active boolValue];
    }
    
    if (_shipment.pos.pos_min_weight == 0) {
        _shipmentPosMinWeightSwitch.on = NO;
        _showPosMinimumWeight = NO;
    } else {
        _shipmentPosMinWeightSwitch.on = YES;
        _shipmentPosMinWeightTextField.text = [NSString stringWithFormat:@"%ld", (long)_shipment.pos.pos_min_weight];
        _showPosMinimumWeight = YES;
    }
    
    if (_shipment.pos.pos_fee == 0) {
        _shipmentPosExtraFeeSwitch.on = NO;
        _showPosExtraFee = NO;
    } else {
        _shipmentPosExtraFeeSwitch.on = YES;
        _shipmentPosExtraFeeTextField.text = [NSString stringWithFormat:@"%ld", (long)_shipment.pos.pos_fee];
        _showPosExtraFee = YES;
    }
}

- (void)setCahaya:(ShippingInfoShipments *)shipment {
    _cahaya = shipment;
    for (ShippingInfoShipmentPackage *package in _cahaya.shipment_package) {
        if ([package.sp_id isEqualToString:@"12"]) {
            // Service Normal
            _cahayaPackageNormal = package;
        }
    }
}

- (void)setCahayaValues {
    _shipmentCahayaNameLabel.text = _cahaya.shipment_name;
    NSURL *url = [NSURL URLWithString:_cahaya.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentCahayaLogoImageView setImageWithURLRequest:request
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     _shipmentCahayaLogoImageView.image = image;
                                                 } failure:nil];
    
    if (_cahayaPackageNormal) {
        _shipmentCahayaNormalLabel.text = _cahayaPackageNormal.name;
        _shipmentCahayaNormalSwitch.on = [_cahayaPackageNormal.active boolValue];
    }
}

- (void)setPandu:(ShippingInfoShipments *)shipment {
    _pandu = shipment;
    for (ShippingInfoShipmentPackage *package in _pandu.shipment_package) {
        if ([package.sp_id isEqualToString:@"14"]) {
            // Reguler
            _panduPackageRegular = package;
        }
    }
}

- (void)setPanduValues {
    _shipmentPanduNameLabel.text = _pandu.shipment_name;
    NSURL *url = [NSURL URLWithString:_pandu.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_shipmentPanduLogoImageView setImageWithURLRequest:request
                                       placeholderImage:nil
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                    _shipmentPanduLogoImageView.image = image;
                                                } failure:nil];
    
    if (_panduPackageRegular) {
        _shipmentPanduRegulerLabel.text = _panduPackageRegular.name;
        _shipmentPanduRegulerSwitch.on = [_panduPackageRegular.active boolValue];
    }
}

- (void)setFirst:(ShippingInfoShipments *)shipment {
    _first = shipment;
    for (ShippingInfoShipmentPackage *package in _first.shipment_package) {
        if ([package.sp_id isEqualToString:@"15"]) { // Reguler Service
            _firstPackageRegular = package;
        }
    }
}

- (void)setFirstValues {
    _firstNameLabel.text = _first.shipment_name;
    NSURL *url = [NSURL URLWithString:_first.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_firstLogoImageView setImageWithURLRequest:request
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            _firstLogoImageView.image = image;
                                        } failure:nil];
    
    if (_firstPackageRegular) {
        _firstRegulerLabel.text = _firstPackageRegular.name;
        _firstRegulerSwitch.on = [_firstPackageRegular.active boolValue];
    }
}

- (void)setGojek:(ShippingInfoShipments *)shipment {
    _gojek = shipment;
    for (ShippingInfoShipmentPackage *package in _gojek.shipment_package) {
        if ([package.sp_id isEqualToString:@"20"]) { // Go Kilat
            _gojekPackageGoKilat = package;
        }
    }
}

- (void)setGojekValues {
    _gojekNameLabel.text = _gojek.shipment_name;
    NSURL *url = [NSURL URLWithString:_gojek.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_gojekLogoImageView setImageWithURLRequest:request
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            _gojekLogoImageView.image = image;
                                        } failure:nil];
    if (_gojekPackageGoKilat) {
        _gojekGoKilatLabel.text = _gojekPackageGoKilat.name;
        _gojekGoKilatSwitch.on = [_gojekPackageGoKilat.active boolValue];
    }
}

- (void)setSiCepat:(ShippingInfoShipments *)shipment {
    _siCepat = shipment;
    for (ShippingInfoShipmentPackage *package in _siCepat.shipment_package) {
        if ([package.sp_id isEqualToString:@"18"]) {
            // Regular Package
            _siCepatPackageRegular = package;
        }
    }
}

- (void)setSiCepatValues {
    _siCepatNameLabel.text = _siCepat.shipment_name;
    NSURL *url = [NSURL URLWithString:_siCepat.shipment_image];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_siCepatLogoImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              _siCepatLogoImageView.image = image;
                                          } failure:nil];
    
    if (_siCepatPackageRegular) {
        _siCepatRegulerLabel.text = _siCepatPackageRegular.name;
        _siCepatRegulerSwitch.on = [_siCepatPackageRegular.active boolValue];
    }
}

- (void)loadData {
    [self.loadingView startAnimating];
    self.loadingView.hidden = NO;
    [self configureRestKit];
    [self request];
}

- (BOOL)hasSelectedShipping {
    //jne
    if ([[self getAvailShipment] containsObject:[self getJne].shipment_id]) {
        if ([[self getJnePackageYes].active boolValue]) {
            return YES;
        }
        if ([[self getJnePackageReguler].active boolValue]) {
            return YES;
        }
        if ([[self getJnePackageOke].active boolValue]) {
            return YES;
        }
    }
    
    //tiki
    if ([[self getAvailShipment] containsObject:[self getTiki].shipment_id]) {
        if ([[self getTikiPackageRegular].active boolValue]) {
            return YES;
        }
        if ([[self getTikiPackageOn].active boolValue]) {
            return YES;
        }
    }
    
    //rpx
    if ([[self getAvailShipment] containsObject:[self getRpx].shipment_id]) {
        if ([[self getRpxPackageNextDay].active boolValue]) {
            return YES;
        }
        if ([[self getRpxPackageEco].active boolValue]) {
            return YES;
        }
    }
    
    //wahana
    if ([[self getAvailShipment] containsObject:[self getWahana].shipment_id]) {
        if ([[self getWahanaPackNormal].active boolValue]) {
            return YES;
        }
    }
    
    //Pos indo
    if ([[self getAvailShipment] containsObject:[self getPosIndo].shipment_id]) {
        if ([[self getPosPackageKhusus].active boolValue]) {
            return YES;
        }
        if ([[self getPosPackageBiasa].active boolValue]) {
            return YES;
        }
        if ([[self getPosPackageExpress].active boolValue]) {
            return YES;
        }
    }
    
    //Cahaya
    if ([[self getAvailShipment] containsObject:[self getCahaya].shipment_id]) {
        if ([[self getCahayaPackageNormal].active boolValue]) {
            return YES;
        }
    }
    
    //pandu
    if ([[self getAvailShipment] containsObject:[self getPandu].shipment_id]) {
        if ([[self getPanduPackageRegular].active boolValue]) {
            return YES;
        }
    }

    //first
    if ([[self getAvailShipment] containsObject:[self getFirst].shipment_id]) {
        if ([[self getFirstPackageRegular].active boolValue]) {
            return YES;
        }
    }

    if ([[self getAvailShipment] containsObject:[self getGoJek].shipment_id]) {
        if ([[self getGojekPackageGoKilat].active boolValue]) {
            return YES;
        }
    }

    //si cepat
    if ([[self getAvailShipment] containsObject:[self getSiCepat].shipment_id]) {
        if ([[self getSiCepatPackageRegular].active boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - JNE

- (ShippingInfoShipments *)getJne {
    return _JNE;
}

- (ShippingInfoShipmentPackage *)getJnePackageReguler {
    return _JNEPackageReguler;
}

- (ShippingInfoShipmentPackage *)getJnePackageYes {
    return _JNEPackageYes;
}

- (ShippingInfoShipmentPackage *)getJnePackageOke {
    return _JNEPackageOke;
}

- (BOOL)getJneExtraFeeTextField {
    return _showJNEExtraFeeTextField;
}

- (BOOL)getJneMinWeightTextField {
    return _showJNEMinimumWeightTextField;
}

#pragma mark - TIKI

- (ShippingInfoShipments *)getTiki {
    return _tiki;
}

- (ShippingInfoShipmentPackage *)getTikiPackageOn {
    return _tikiPackageONS;
}

- (ShippingInfoShipmentPackage *)getTikiPackageRegular {
    return _tikiPackageReguler;
}

- (BOOL)getTikiExtraFee {
    return _showTikiExtraFee;
}

#pragma mark - RPX

- (ShippingInfoShipments *)getRpx {
    return _RPX;
}

- (ShippingInfoShipmentPackage *)getRpxPackageEco {
    return _RPXPackageEconomy;
}

- (ShippingInfoShipmentPackage *)getRpxPackageNextDay {
    return _RPXPackageNextDay;
}

#pragma mark - Wahana

- (ShippingInfoShipments *)getWahana {
    return _wahana;
}

- (ShippingInfoShipmentPackage *)getWahanaPackNormal {
    return _wahanaPackageNormal;
}

#pragma mark - Pos Indonesia

- (ShippingInfoShipments *)getPosIndo {
    return _posIndonesia;
}

- (ShippingInfoShipmentPackage *)getPosPackageKhusus {
    return _posPackageKhusus;
}

- (ShippingInfoShipmentPackage *)getPosPackageBiasa {
    return _posPackageBiasa;
}

- (ShippingInfoShipmentPackage *)getPosPackageExpress {
    return _posPackageExpress;
}

- (BOOL)getPosMinWeight {
    return _showPosMinimumWeight;
}

- (BOOL)getPosExtraFee {
    return _showPosExtraFee;
}

#pragma mark - Cahaya

- (ShippingInfoShipments *)getCahaya {
    return _cahaya;
}

- (ShippingInfoShipmentPackage *)getCahayaPackageNormal {
    return _cahayaPackageNormal;
}

#pragma mark - Pandu

- (ShippingInfoShipments *)getPandu {
    return _pandu;
}

- (ShippingInfoShipmentPackage *)getPanduPackageRegular {
    return _panduPackageRegular;
}

#pragma mark - First

- (ShippingInfoShipments *)getFirst {
    return _first;
}

- (ShippingInfoShipmentPackage *)getFirstPackageRegular {
    return _firstPackageRegular;
}

#pragma mark - Gojek

- (ShippingInfoShipments *)getGoJek {
    return _gojek;
}

- (ShippingInfoShipmentPackage *)getGojekPackageGoKilat {
    return _gojekPackageGoKilat;
}

#pragma mark - Si Cepat

- (ShippingInfoShipments *)getSiCepat {
    return _siCepat;
}

- (ShippingInfoShipmentPackage *)getSiCepatPackageRegular {
    return _siCepatPackageRegular;
}

#pragma mark - Shipment

- (ShippingInfoResult *)getShipment {
    return _shipment;
}

- (NSArray *)getAvailShipment {
    return _availableShipments;
}

- (int)getCourirOrigin {
    return (int)_shipment.shop_shipping.district_id;
}

- (NSString *)getPostalCode
{
    return _postCodeTextField.text;
}

#pragma mark - Location & Address

- (NSString *)getAddress {
    return  self.addressTextView.text;
}

- (NSString *)getLatitude {
    return [NSString stringWithFormat:@"%f", _shipment.shop_shipping.latitude];
}

- (NSString *)getLongitude {
    return [NSString stringWithFormat:@"%f", _shipment.shop_shipping.longitude];
}

#pragma mark - Restkit Action

- (void)configureRestKitAction
{
    _objectManagerAction = [RKObjectManager sharedClient];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_objectManagerAction.HTTPClient setDefaultHeader:@"X-APP-VERSION" value:appVersion];

    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromArray:@[
                                                   kTKPDDETAIL_APIISSUCCESSKEY,
                                                   ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOPACTIONEDITOR_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerAction addResponseDescriptor:responseDescriptor];
}

- (void)requestAction
{
    if (_requestAction.isExecuting) return;
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *loadingBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    self.navigationItem.rightBarButtonItem = loadingBarButton;
    
    NSDictionary *parameters = [[self getRequestParameters] encrypt];
    
    _requestAction = [_objectManagerAction appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:kTKPDDETAILSHOPACTIONEDITOR_APIPATH parameters:parameters];
    
    [_operationQueue addOperation:_requestAction];
    
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestActionSuccessResult:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestActionError:error];
    }];
}

- (void)requestActionSuccessResult:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation
{
    ShopSettings *settingResponse = [result.dictionary objectForKey:@""];
    BOOL status = [settingResponse.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(tap:)];
        saveButton.tintColor = [UIColor whiteColor];
        saveButton.enabled = YES;
        self.navigationItem.rightBarButtonItem = saveButton;
        if (status) {
            if (settingResponse.message_status) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:settingResponse.message_status
                                                                                 delegate:self];
                [alert show];
            } else if(settingResponse.message_error) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:settingResponse.message_error
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

- (void)requestActionError:(NSError *)error
{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda gagal mengganti pengaturan pengiriman",]
                                                                   delegate:self];
    [alert show];
}

- (NSDictionary *)getRequestParameters
{
    NSString *courier_origin = [NSString stringWithFormat:@"%ld", (long)_shipment.shop_shipping.district_id];
    NSString *postal = _shipment.shop_shipping.postal_code;
    
    NSString *jne_diff_district = @"";
    NSString *jne_fee = @"";
    NSString *jne_fee_value = @"";
    NSString *jne_min_weight = @"";
    NSString *jne_min_weight_value = @"";
    NSString *jne_tiket = @"";
    
    if ([_availableShipments containsObject:_JNE.shipment_id]) {
        jne_diff_district = _shipment.jne.jne_diff_district;
        jne_fee = _showJNEExtraFeeTextField?@"1":@"0";
        jne_fee_value = [NSString stringWithFormat:@"%ld", (long)_shipment.jne.jne_fee];
        jne_min_weight  = _showJNEMinimumWeightTextField?@"1":@"0";
        jne_min_weight_value = _shipment.jne.jne_min_weight;
        jne_tiket = _shipment.jne.jne_tiket;
    }
    
    NSString *pos_fee = @"";
    NSString *pos_fee_value = @"";
    NSString *pos_min_weight = @"";
    NSString *pos_min_weight_value = @"";
    
    if ([_availableShipments containsObject:_posIndonesia.shipment_id]) {
        pos_fee = _showPosExtraFee?@"1":@"0";
        pos_fee_value = [NSString stringWithFormat:@"%ld", (long)_shipment.pos.pos_fee];
        pos_min_weight = _showPosMinimumWeight?@"1":@"0";
        pos_min_weight_value = [NSString stringWithFormat:@"%ld", (long)_shipment.pos.pos_min_weight];
    }
    
    NSString *tiki_fee = @"";
    NSString *tiki_fee_value = @"";
    if ([_availableShipments containsObject:_tiki.shipment_id]) {
        tiki_fee = _showTikiExtraFee?@"1":@"0";
        tiki_fee_value = [NSString stringWithFormat:@"%ld", (long)_shipment.tiki.tiki_fee];
    }
    
    NSMutableDictionary *shipments = [NSMutableDictionary new];
    
    NSMutableDictionary *jne = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_JNE.shipment_id]) {
        if ([_JNEPackageYes.active boolValue]) {
            [jne setValue:@"1" forKey:_JNEPackageYes.sp_id];
        }
        if ([_JNEPackageReguler.active boolValue]) {
            [jne setValue:@"1" forKey:_JNEPackageReguler.sp_id];
        }
        if ([_JNEPackageOke.active boolValue]) {
            [jne setValue:@"1" forKey:_JNEPackageOke.sp_id];
        }
        
        if ([[jne allValues] count] > 0) {
            [shipments setValue:jne forKey:_JNE.shipment_id];
        }
    }
    
    NSMutableDictionary *tiki = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_tiki.shipment_id]) {
        if ([_tikiPackageReguler.active boolValue]) {
            [tiki setValue:@"1" forKey:_tikiPackageReguler.sp_id];
        }
        if ([_tikiPackageONS.active boolValue]) {
            [tiki setValue:@"1" forKey:_tikiPackageONS.sp_id];
        }
        
        if ([[tiki allValues] count] > 0) {
            [shipments setValue:tiki forKey:_tiki.shipment_id];
        }
    }
    
    NSMutableDictionary *rpx = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_RPX.shipment_id]) {
        if ([_RPXPackageNextDay.active boolValue]) {
            [rpx setValue:@"1" forKey:_RPXPackageNextDay.sp_id];
        } else{
            [rpx setValue:@"0" forKey:_RPXPackageNextDay.sp_id];
        }
        
        if ([_RPXPackageEconomy.active boolValue]) {
            [rpx setValue:@"1" forKey:_RPXPackageEconomy.sp_id];
        } else{
            [rpx setValue:@"0" forKey:_RPXPackageEconomy.sp_id];
        }
        
        if ([[rpx allValues] count] > 0) {
            [shipments setValue:rpx forKey:_RPX.shipment_id];
        }
    }
    
    NSMutableDictionary *wahana = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_wahana.shipment_id]) {
        if ([_wahanaPackageNormal.active boolValue]) {
            [wahana setObject:@"1" forKey:_wahanaPackageNormal.sp_id];
        }
        
        if ([[wahana allValues] count] > 0) {
            [shipments setObject:wahana forKey:_wahana.shipment_id];
        }
    }
    
    NSMutableDictionary *pos = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_posIndonesia.shipment_id]) {
        if ([_posPackageKhusus.active boolValue]) {
            [pos setObject:@"1" forKey:_posPackageKhusus.sp_id];
        }
        if ([_posPackageBiasa.active boolValue]) {
            [pos setObject:@"1" forKey:_posPackageBiasa.sp_id];
        }
        if ([_posPackageExpress.active boolValue]) {
            [pos setObject:@"1" forKey:_posPackageExpress.sp_id];
        }
        
        if ([[pos allValues] count] > 0) {
            [shipments setObject:pos forKey:_posIndonesia.shipment_id];
        }
    }
    
    NSMutableDictionary *cahaya = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_cahaya.shipment_id]) {
        if ([_cahayaPackageNormal.active boolValue]) {
            [cahaya setObject:@"1" forKey:_cahayaPackageNormal.sp_id];
        }
        
        if ([[cahaya allValues] count] > 0) {
            [shipments setObject:cahaya forKey:_cahaya.shipment_id];
        }
    }
    
    NSMutableDictionary *pandu = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_pandu.shipment_id]) {
        if ([_panduPackageRegular.active boolValue]) {
            [pandu setObject:@"1" forKey:_panduPackageRegular.sp_id];
        }
        
        if ([[pandu allValues] count] > 0) {
            [shipments setObject:pandu forKey:_pandu.shipment_id];
        }
    }
    
    NSMutableDictionary *first = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_first.shipment_id]) {
        if ([_firstPackageRegular.active boolValue]) {
            [first setObject:@"1" forKey:_firstPackageRegular.sp_id];
        }
        if ([[first allValues] count] > 0) {
            [shipments setObject:first forKey:_first.shipment_id];
        }
    }
    
    NSMutableDictionary *gojek = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_gojek.shipment_id]) {
        if ([_gojekPackageGoKilat.active boolValue]) {
            [gojek setObject:@"1" forKey:_gojekPackageGoKilat.sp_id];
        }
        if ([[gojek allValues] count] > 0) {
            [shipments setObject:gojek forKey:_gojek.shipment_id];
        }
    }

    NSMutableDictionary *siCepat = [NSMutableDictionary new];
    if ([_availableShipments containsObject:_siCepat.shipment_id]) {
        if ([_siCepatPackageRegular.active boolValue]) {
            [siCepat setObject:@"1" forKey:_siCepatPackageRegular.sp_id];
        }
        if ([[siCepat allValues] count] > 0) {
            [shipments setObject:siCepat forKey:_siCepat.shipment_id];
        }
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:shipments
                                                   options:0
                                                     error:nil];
    
    NSString *shipments_ids = [[NSString alloc] initWithBytes:[data bytes]
                                                       length:[data length]
                                                     encoding:NSUTF8StringEncoding];
    
    NSString *iDrop = _shipmentRPXIDropSwitch.isOn ? @"1" : @"0";

    NSString *latitude = [NSString stringWithFormat:@"%f", _shipment.shop_shipping.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", _shipment.shop_shipping.longitude];
    NSString *address_street = self.addressTextView.text;
    
    NSDictionary *parameters = @{
                                 kTKPDDETAIL_APIACTIONKEY                : kTKPDDETAIL_APIEDITSHIPPINGINFOKEY,
                                 kTKPDSHOPSHIPMENT_APICOURIRORIGINKEY    : courier_origin,
                                 kTKPDSHOPSHIPMENT_APIPOSTALKEY          : postal,
                                 kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY    : jne_diff_district,
                                 kTKPDSHOPSHIPMENT_APIJNEFEEKEY          : jne_fee,
                                 kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY     : jne_fee_value,
                                 kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY       : jne_min_weight,
                                 kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY  : jne_min_weight_value,
                                 kTKPDSHOPSHIPMENT_APIJNETICKETKEY       : jne_tiket,
                                 kTKPDSHOPSHIPMENT_APITIKIFEEKEY         : tiki_fee,
                                 kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY    : tiki_fee_value,
                                 kTKPDSHOPSHIPMENT_APIPOSFEEKEY          : pos_fee,
                                 kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY     : pos_fee_value,
                                 kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY    : pos_min_weight,
                                 kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY : pos_min_weight_value,
                                 kTKPDSHOPSHIPMENT_APISHIPMENTIDS        : shipments_ids,
                                 kTKPDSHOPSHIPMENT_APIRPXIDROPKEY        : iDrop,
                                 @"latitude" : latitude,
                                 @"longitude" : longitude,
                                 @"addr_street" : address_street,
                                 };
    
    return parameters;
}

#pragma mark - Action

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    NSArray *shipmentPackages;
    NSString *title;
    if ([cell isEqual:_shipmentJNEMoreInfoCell]) {
        title = _JNE.shipment_name;
        shipmentPackages = @[_JNEPackageOke, _JNEPackageReguler, _JNEPackageYes];
    } else if ([cell isEqual:_shipmentTikiMoreInfoCell]) {
        title = _tiki.shipment_name;
        shipmentPackages = @[_tikiPackageONS, _tikiPackageReguler];
    } else if ([cell isEqual:_shipmentRPXMoreInfoCell]) {
        title = _RPX.shipment_name;
        shipmentPackages = @[_RPXPackageEconomy, _RPXPackageNextDay];
    } else if ([cell isEqual:_shipmentWahanaMoreInfoCell]) {
        title = _wahana.shipment_name;
        shipmentPackages = @[_wahanaPackageNormal];
    } else if ([cell isEqual:_shipmentPosMoreInfoCell]) {
        title = _posIndonesia.shipment_name;
        shipmentPackages = @[_posPackageBiasa, _posPackageExpress, _posPackageKhusus];
    } else if ([cell isEqual:_shipmentCahayaMoreInfoCell]) {
        title = _cahaya.shipment_name;
        shipmentPackages = @[_cahayaPackageNormal];
    } else if ([cell isEqual:_shipmentPanduMoreInfoCell]) {
        title = _pandu.shipment_name;
        shipmentPackages = @[_panduPackageRegular];
    } else if ([cell isEqual:_firstMoreInfoCell]) {
        title = _first.shipment_name;
        shipmentPackages = @[_firstPackageRegular];
    } else if ([cell isEqual:_gojekMoreInfoCell]) {
        title = _gojek.shipment_name;
        shipmentPackages = @[_gojekPackageGoKilat];
    } else if ([cell isEqual:_siCepatMoreInfoCell]) {
        title = _siCepat.shipment_name;
        shipmentPackages = @[_siCepatPackageRegular];
    }
    
    MyShopShipmentInfoViewController *controller = (MyShopShipmentInfoViewController *)segue.destinationViewController;
    controller.title = title;
    controller.shipment_packages = shipmentPackages;
}

#pragma mark - Map delegate

- (void)pickAddress:(GMSAddress *)address
         suggestion:(NSString *)suggestion
          longitude:(double)longitude
           latitude:(double)latitude
           mapImage:(UIImage *)mapImage {
    NSString *addressStreet= @"";
    
    if (![suggestion isEqualToString:@""]) {
        NSArray *addressSuggestions = [suggestion componentsSeparatedByString:@","];
        addressStreet = addressSuggestions[0];
    }
    NSString *locationAddress = [self streetNameFromAddress:address];
    NSString *street= locationAddress;
    if (addressStreet.length != 0) {
        addressStreet = [NSString stringWithFormat:@"%@\n%@",addressStreet,street];
    }
    else
        addressStreet = street;
    
    self.pickupLocationLabel.text = [locationAddress isEqualToString:@""]?@"Tandai lokasi Anda":locationAddress;
    _shipment.shop_shipping.latitude = latitude;
    _shipment.shop_shipping.longitude = longitude;
}

@end