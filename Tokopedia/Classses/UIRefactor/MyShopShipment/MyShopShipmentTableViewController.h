//
//  MyShopShipmentTableViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CreateShopViewController;
@class ShippingInfoShipments;
@class ShippingInfoShipmentPackage;
@class ShippingInfoResult;

@interface MyShopShipmentTableViewController : UITableViewController
@property (nonatomic, unsafe_unretained) CreateShopViewController *createShopViewController;

- (NSString *)getPostalCode;
- (int)getCourirOrigin;

- (NSArray *)getAvailShipment;
- (ShippingInfoResult *)getShipment;
- (ShippingInfoShipments *)getJne;
- (ShippingInfoShipments *)getTiki;
- (ShippingInfoShipments *)getPosIndo;
- (ShippingInfoShipments *)getWahana;
- (ShippingInfoShipments *)getRpx;
- (ShippingInfoShipments *)getCahaya;
- (ShippingInfoShipments *)getPandu;

- (ShippingInfoShipmentPackage *)getJnePackageYes;
- (ShippingInfoShipmentPackage *)getJnePackageReguler;
- (ShippingInfoShipmentPackage *)getJnePackageOke;

- (ShippingInfoShipmentPackage *)getTikiPackageRegular;
- (ShippingInfoShipmentPackage *)getTikiPackageOn;

- (ShippingInfoShipmentPackage *)getRpxPackageNextDay;
- (ShippingInfoShipmentPackage *)getRpxPackageEco;

- (ShippingInfoShipmentPackage *)getWahanaPackNormal;

- (ShippingInfoShipmentPackage *)getPosPackageKhusus;
- (ShippingInfoShipmentPackage *)getPosPackageBiasa;
- (ShippingInfoShipmentPackage *)getPosPackageExpress;

- (ShippingInfoShipmentPackage *)getCahayaPackageNormal;
- (ShippingInfoShipmentPackage *)getPanduPackageRegular;

- (BOOL)getJneExtraFeeTextField;
- (BOOL)getJneMinWeightTextField;
- (BOOL)getPosMinWeight;
- (BOOL)getTikiExtraFee;
- (BOOL)getPosExtraFee;

@end
