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

@interface MyShopShipmentTableViewController ()
<
    UITextFieldDelegate,
    GeneralTableViewControllerDelegate
>
{
    ShippingInfoResult *_shipment;
    NSArray *_districts;
    NSArray *_availableShipments;
    
    ShippingInfoShipments *_JNE;
    ShippingInfoShipmentPackage *_JNEPackageYes;
    ShippingInfoShipmentPackage *_JNEPackageReguler;
    ShippingInfoShipmentPackage *_JNEPackageOke;
    BOOL _showJNEMinimumWeightTextField;
    BOOL _showJNEExtraFeeTextField;
    BOOL _showJNEAWBSwitch;
    
    ShippingInfoShipments *_tiki;
    ShippingInfoShipmentPackage *_tikiPackageReguler;
    ShippingInfoShipmentPackage *_tikiPackageONS;
    BOOL _showTikiExtraFee;

    ShippingInfoShipments *_posIndonesia;
    ShippingInfoShipmentPackage *_posPackageKhusus;
    ShippingInfoShipmentPackage *_posPackageBiasa;
    ShippingInfoShipmentPackage *_posPackageExpress;
    BOOL _showPosMinimumWeight;
    BOOL _showPosExtraFee;
    
    ShippingInfoShipments *_RPX;
    ShippingInfoShipmentPackage *_RPXPackageNextDay;
    ShippingInfoShipmentPackage *_RPXPackageEconomy;
    
    ShippingInfoShipments *_wahana;
    ShippingInfoShipmentPackage *_wahanaPackageNormal;
    
    ShippingInfoShipments *_cahaya;
    ShippingInfoShipmentPackage *_cahayaPackageNormal;
    
    ShippingInfoShipments *_pandu;
    ShippingInfoShipmentPackage *_panduPackageRegular;

    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    BOOL _hasSelectKotaAsal;
}

@property (weak, nonatomic) IBOutlet UILabel *provinceLabel;
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

@end

@implementation MyShopShipmentTableViewController
@synthesize createShopViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pengiriman";
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:(createShopViewController!=nil? CStringLanjut:@"Simpan")
                                                                   style:(createShopViewController!=nil? UIBarButtonItemStylePlain:UIBarButtonItemStyleDone)
                                                                  target:self
                                                                  action:@selector(tap:)];
    
    
    if(createShopViewController == nil) {
        saveButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    }
    
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
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
    
    NSString *note = @"Berat maksimum paket biasa 30 kg. Berat maksimum paket lain nya 150 kg.";
    _shipmentPosNoteCell.attributedText = [[NSAttributedString alloc] initWithString:note attributes:attributes];
    
    _operationQueue = [NSOperationQueue new];
    
    [self configureRestKit];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_shipment) {
        if(createShopViewController!=nil && !_hasSelectKotaAsal)
            return 1;
        return 8;
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
                height = 44;
            } else {
                height = 0;
            }
            break;
        }

        case 1: {
            height = [self heightForJNEAtRow:indexPath.row];
            break;
        }
        
        case 2: {
            height = [self heightForTikiAtRow:indexPath.row];
            break;
        }
            
        case 3: {
            height = [self heightForRPXAtRow:indexPath.row];
            break;
        }
            
        case 4: {
            height = [self heightForWahanaAtRow:indexPath.row];
            break;
        }

        case 5: {
            height = [self heightForPosAtRow:indexPath.row];
            break;
        }

        case 6: {
            height = [self heightForCahayaAtRow:indexPath.row];
            break;
        }

        case 7: {
            height = [self heightForPanduAtRow:indexPath.row];
            break;
        }
            
        default:
            height = 0;
            break;
    }
    return height;
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
        
        // return cell if information about package is existing
        else if (row == 1) {
            if (_RPXPackageNextDay) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        // return cell if information about package is existing
        else if (row == 2) {
            if (_RPXPackageEconomy) {
                height = 44;
            } else {
                height = 0;
            }
        }
        
        else if (row == 3) {
            height = 44;
        }
        
        else if (row == 4) {
            height = 70;
        }
        
    } else {
        if (row == 0) {
            height = 50;
        }
        else if (row == 5) {
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
            height = 60;
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
            numberOfRows = 2;
            break;
        
        case 1:
            numberOfRows = 12;
            break;
            
        case 2:
            numberOfRows = 8;
            break;
            
        case 3:
            numberOfRows = 6;
            break;
            
        case 4:
            numberOfRows = 5;
            break;
            
        case 5:
            numberOfRows = 11;
            break;
            
        case 6:
            numberOfRows = 5;
            break;

        case 7:
            numberOfRows = 5;
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
    if (indexPath.section == 0 && indexPath.row == 0 && _shipment) {
        shouldHighlight = YES;
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isEqual:_shipmentJNEMoreInfoCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentJNEAWBCell]) {
            shouldHighlight = YES;
        } else if ([cell isEqual:_shipmentTikiMoreInfoCell]) {
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
        }
    }
    return shouldHighlight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0 && _districts) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Pilih Lokasi";
        controller.delegate = self;
        controller.objects = _districts;
        controller.selectedObject = _shipment.shop_shipping.district_name;
        controller.enableSearch = YES;
        controller.isPresentedViewController = YES;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        nav.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.row == 4) {
        AlertInfoView *alert = [AlertInfoView newview];
        alert.text = @"Sistem AWB Otomatis";
        alert.detailText = @"Dengan menggunakan Sistem Kode Resi Otomatis, Anda tidak perlu lagi melakukan input nomor resi secara manual. Cukup cetak kode booking dan tunjukkan ke agen JNE yang mendukung, nomor resi akan otomatis masuk ke Tokopedia.";
        [alert show];

        CGRect frame = alert.frame;
        frame.origin.y -= 25;
        frame.size.height += (alert.detailTextLabel.frame.size.height-50);
        alert.frame = frame;

    }
}

#pragma mark - Actions
- (void)validateShipment
{
    NSMutableArray *errorMessage = [NSMutableArray new];
    if(_showJNEExtraFeeTextField) {
        if(((long)_shipment.jne.jne_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan JNE harus diisi."];
        }
        else if(((long)_shipment.jne.jne_fee) > 5000) {
            [errorMessage addObject:@"Maksimum Biaya JNE adalah Rp 5.000,-"];
        }
    }
    
    if(_showTikiExtraFee) {
        if(((long)_shipment.tiki.tiki_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan Tiki harus diisi."];
        }
        else if(((long)_shipment.tiki.tiki_fee) > 5000) {
            [errorMessage addObject:@"Maksimum Biaya Tiki adalah Rp 5.000,-"];
        }
    }
    
    if(_showPosExtraFee) {
        if(((long)_shipment.pos.pos_fee) == 0) {
            [errorMessage addObject:@"Biaya Tambahan Pos Indonesia harus diisi."];
        }
        else if(((long)_shipment.pos.pos_fee) > 5000) {
            [errorMessage addObject:@"Maksimum Biaya Pos Indonesia adalah Rp 5.000,-"];
        }
    }
    
    if(errorMessage.count == 0) {
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


- (void)tap:(id)sender
{
    if(createShopViewController != nil)
    {
        [self validateShipment];
    }
    else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
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
        } else {
            _shipment.jne.jne_tiket = @"0";
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
    else if ([sender isEqual:_shipmentRPXNextDaySwitch]) {
        if (sender.isOn) {
            _RPXPackageNextDay.active = @"1";
        } else {
            _RPXPackageNextDay.active = @"0";
        }
    }
    else if ([sender isEqual:_shipmentRPXEconomySwitch]) {
        if (sender.isOn) {
            _RPXPackageEconomy.active = @"1";
        } else {
            _RPXPackageEconomy.active = @"0";
        }
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
    
    [self.tableView reloadData];
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_postCodeTextField]) {
        _shipment.shop_shipping.postal_code = textField.text;
        [self validateEnableRightBarButtonItem];
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

#pragma mark - General table delegate

- (void)didSelectObject:(id)object
{
    _hasSelectKotaAsal = YES;
    [self validateEnableRightBarButtonItem];

    NSInteger index = [_districts indexOfObject:object];
    District *district = [_shipment.district objectAtIndex:index];
    _provinceLabel.text = district.district_name;
    
    if(createShopViewController!=nil && _shipment.shop_shipping==nil)
        _shipment.shop_shipping = [ShopShipping new];
    
    
    _shipment.shop_shipping.district_name = district.district_name;
    _shipment.shop_shipping.district_id = district.district_id;

    _availableShipments = district.district_shipping_supported;

    [self.tableView reloadData];
}

#pragma mark - Restkit

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
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
    [tikiMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APITIKIFEEKEY,]];
    
    RKObjectMapping *posWeightMapping = [RKObjectMapping mappingForClass:[PosMinWeight class]];
    [posWeightMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY,
                                                      kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY]];
    
    RKObjectMapping *shopShippingMapping = [RKObjectMapping mappingForClass:[ShopShipping class]];
    [shopShippingMapping addAttributeMappingsFromArray:@[
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY,
                                                         kTKPDSHOPSHIPMENT_APIORIGINKEY,
                                                         kTKPDSHOPSHIPMENT_APISHIPPINGIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISCTRICTSUPPORTEDKEY
                                                         ]];
    
    // Relationship Mapping
    RKRelationshipMapping *districtRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTKEY
                                                                                     toKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTKEY
                                                                                   withMapping:districtMapping];
    [resultMapping addPropertyMapping:districtRel];
    
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
    
    RKRelationshipMapping *shipmentpackagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY
                                                                                             toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY
                                                                                           withMapping:shipmentsPackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackagesRel];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY
                                                                                  toKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY
                                                                                withMapping:posWeightMapping]];
    
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

- (void)requestSuccessResult:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation
{
    ShippingInfo *shippingInfo = [result.dictionary objectForKey:@""];
    BOOL status = [shippingInfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        
        UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
        if(createShopViewController == nil)
        {
            saveButton.tintColor = [UIColor whiteColor];
            saveButton.enabled = YES;
        }
        
        _shipment = shippingInfo.result;
        _availableShipments = _shipment.shop_shipping.district_shipping_supported;
        
        
        //Set Note for pay
        for (Payment *payment in _shipment.payment_options) {
            if ([_shipment.loc objectForKey:payment.payment_id]) {
                payment.payment_info = [_shipment.loc objectForKey:payment.payment_id];
            }
        }
        
        NSMutableArray *districts = [NSMutableArray new];
        for (District *district in _shipment.district) {
            [districts addObject:district.district_name];
        }
        _districts = districts;
        
        if (_shipment.shop_shipping.district_name) {
            _provinceLabel.text = _shipment.shop_shipping.district_name;
            _hasSelectKotaAsal = YES;
        }
        
        _postCodeTextField.text = _shipment.shop_shipping.postal_code;
        
        if(createShopViewController != nil)
        {
            if(_shipment.jne == nil)
            {
                _shipment.jne = [JNE new];
                _shipment.jne.jne_fee = 0;
                _shipment.jne.jne_diff_district = @"0";
                _shipment.jne.jne_min_weight = @"";
                _shipment.jne.jne_tiket = @"0";
            }
            if(_shipment.tiki == nil)
            {
                _shipment.tiki = [Tiki new];
                _shipment.tiki.tiki_fee = 0;
            }
            if(_shipment.pos == nil) {
                _shipment.pos = [POSIndonesia new];
                _shipment.pos.pos_fee = 0;
                _shipment.pos.pos_min_weight = 0;
            }
        }
        
        
        for (ShippingInfoShipments *shipment in _shipment.shipment) {
            if ([shipment.shipment_name isEqualToString:@"JNE"]) {
                _JNE = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"YES"]) {
                        _JNEPackageYes = package;
                    } else if ([package.name isEqualToString:@"Reguler"]) {
                        _JNEPackageReguler = package;
                    } else  if ([package.name isEqualToString:@"OKE"]) {
                        _JNEPackageOke = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"TIKI"]) {
                _tiki = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Reguler"]) {
                        _tikiPackageReguler = package;
                    } else if ([package.name isEqualToString:@"Over Night Service"]) {
                        _tikiPackageONS = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"RPX"]) {
                _RPX = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Next Day Package"]) {
                        _RPXPackageNextDay = package;
                    } else if ([package.name isEqualToString:@"Economy Package"]) {
                        _RPXPackageEconomy = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"Wahana"]) {
                _wahana = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Service Normal"]) {
                        _wahanaPackageNormal = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"Pos Indonesia"]) {
                _posIndonesia = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Pos Kilat Khusus"]) {
                        _posPackageKhusus = package;
                    } else if ([package.name isEqualToString:@"Paket Biasa"]) {
                        _posPackageBiasa = package;
                    } else if ([package.name isEqualToString:@"Pos Express"]) {
                        _posPackageExpress = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"Cahaya"]) {
                _cahaya = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Service Normal"]) {
                        _cahayaPackageNormal = package;
                    }
                }
            } else if ([shipment.shipment_name isEqualToString:@"Pandu"]) {
                _pandu = shipment;
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:@"Reguler"]) {
                        _panduPackageRegular = package;
                    }
                }
            }
            
            if (_JNE) {
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
            
            if (_tiki) {
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
            
            if (_RPX) {
                _shipmentRPXNameLabel.text = _RPX.shipment_name;
                NSURL *url = [NSURL URLWithString:_RPX.shipment_image];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [_shipmentRPXLogoImageView setImageWithURLRequest:request
                                                  placeholderImage:nil
                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                               _shipmentRPXLogoImageView.image = image;
                                                           } failure:nil];
                
                if (_RPXPackageEconomy) {
                    _shipmentRPXEconomySwitch.on = [_RPXPackageEconomy.active boolValue];
                }
                
                if (_RPXPackageNextDay) {
                    _shipmentRPXNextDaySwitch.on = [_RPXPackageNextDay.active boolValue];
                }
            }
            
            if (_wahana) {
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
            
            if (_posIndonesia) {
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
            
            if (_cahaya) {
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
            
            if (_pandu) {
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
        }
    }
}

- (void)requestError:(NSError *)error withOperation:(RKObjectRequestOperation *)operation
{
    
}


#pragma mark - Method
- (ShippingInfoShipments *)getPandu
{
    return _pandu;
}

- (NSArray *)getAvailShipment
{
    return _availableShipments;
}

- (ShippingInfoShipments *)getRpx
{
    return _RPX;
}

- (ShippingInfoShipments *)getCahaya
{
    return _cahaya;
}

- (ShippingInfoShipments *)getWahana
{
    return _wahana;
}

- (ShippingInfoShipmentPackage *)getTikiPackageOn
{
    return _tikiPackageONS;
}

- (ShippingInfoShipmentPackage *)getTikiPackageRegular
{
    return _tikiPackageReguler;
}

- (ShippingInfoShipmentPackage *)getRpxPackageEco
{
    return _RPXPackageEconomy;
}

- (ShippingInfoShipmentPackage *)getPosPackageBiasa
{
    return _posPackageBiasa;
}

- (ShippingInfoShipmentPackage *)getCahayaPackageNormal
{
    return _cahayaPackageNormal;
}

- (ShippingInfoShipmentPackage *)getPanduPackageRegular
{
    return _panduPackageRegular;
}

- (ShippingInfoShipmentPackage *)getPosPackageExpress
{
    return _posPackageExpress;
}

- (ShippingInfoShipmentPackage *)getPosPackageKhusus
{
    return _posPackageKhusus;
}

- (ShippingInfoShipmentPackage *)getWahanaPackNormal
{
    return _wahanaPackageNormal;
}

- (ShippingInfoShipmentPackage *)getRpxPackageNextDay
{
    return _RPXPackageNextDay;
}

- (ShippingInfoShipmentPackage *)getJnePackageOke
{
    return _JNEPackageOke;
}

- (ShippingInfoShipmentPackage *)getJnePackageReguler
{
    return _JNEPackageReguler;
}

- (ShippingInfoShipmentPackage *)getJnePackageYes
{
    return _JNEPackageYes;
}

- (ShippingInfoResult *)getShipment
{
    return _shipment;
}

- (ShippingInfoShipments *)getJne
{
    return _JNE;
}

- (ShippingInfoShipments *)getTiki
{
    return _tiki;
}

- (ShippingInfoShipments *)getPosIndo
{
    return _posIndonesia;
}

- (int)getCourirOrigin
{
    return (int)_shipment.shop_shipping.district_id;
}

- (BOOL)getJneExtraFeeTextField
{
    return _showJNEExtraFeeTextField;
}

- (BOOL)getJneMinWeightTextField
{
    return _showJNEMinimumWeightTextField;
}

- (BOOL)getTikiExtraFee
{
    return _showTikiExtraFee;
}

- (BOOL)getPosMinWeight
{
    return _showPosMinimumWeight;
}

- (BOOL)getPosExtraFee
{
    return _showPosExtraFee;
}

- (NSString *)getPostalCode
{
    return _postCodeTextField.text;
}

- (void)validateEnableRightBarButtonItem
{
    if(_hasSelectKotaAsal && _postCodeTextField.text.length > 4)
    {
        UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
        saveButton.tintColor = [UIColor whiteColor];
        saveButton.enabled = YES;
    }
    else
    {
        UIBarButtonItem *saveButton = self.navigationItem.rightBarButtonItem;
        saveButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        saveButton.enabled = NO;
    }
}


#pragma mark - Restkit Action

- (void)configureRestKitAction
{
    _objectManagerAction = [RKObjectManager sharedClient];

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
        }
        if ([_RPXPackageEconomy.active boolValue]) {
            [rpx setValue:@"1" forKey:_RPXPackageEconomy.sp_id];
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
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:shipments
                                                   options:0
                                                     error:nil];
    
    NSString *shipments_ids = [[NSString alloc] initWithBytes:[data bytes]
                                                       length:[data length]
                                                     encoding:NSUTF8StringEncoding];
    
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
    };
    
    return parameters;
}

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
    }
    
    MyShopShipmentInfoViewController *controller = (MyShopShipmentInfoViewController *)segue.destinationViewController;
    controller.title = title;
    controller.shipment_packages = shipmentPackages;
}

@end