//
//  MyShopShipmentInfoViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "MyShopShipmentInfoViewController.h"
#import "ShippingInfoShipmentPackage.h"

@interface MyShopShipmentInfoViewController ()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *descriptionLabel;

@end

@implementation MyShopShipmentInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < _shipment_packages.count; i++) {
        ShippingInfoShipmentPackage *package = [_shipment_packages objectAtIndex:i];
        
        UILabel *title = [self.titleLabel objectAtIndex:i];
        title.text = package.name;
        title.numberOfLines = 0;
        [title sizeToFit];
        [title setHidden:NO];

        UILabel *descLabel = [self.descriptionLabel objectAtIndex:i];
        descLabel.text = package.desc;
        descLabel.numberOfLines = 0;
        [descLabel sizeToFit];
        [descLabel setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
