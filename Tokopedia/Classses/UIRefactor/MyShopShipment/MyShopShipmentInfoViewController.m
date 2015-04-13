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

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0
                                                                                      green:117.0/255.0
                                                                                       blue:117.0/255.0
                                                                                      alpha:1],
                                     };
        
        descLabel.attributedText = [[NSAttributedString alloc] initWithString:package.desc attributes:attributes];
        descLabel.numberOfLines = 0;
        descLabel.hidden = NO;
        [descLabel sizeToFit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
