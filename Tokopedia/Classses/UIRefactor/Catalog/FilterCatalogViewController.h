//
//  FilterCatalogViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Catalog.h"

@protocol FilterCatalogDelegate <NSObject>

- (void)didFinishFilterCatalog:(Catalog *)catalog condition:(NSString *)condition location:(NSString *)location;

@end

@interface FilterCatalogViewController : UITableViewController

@property (strong, nonatomic) Catalog *catalog;
@property (weak, nonatomic) id<FilterCatalogDelegate> delegate;

@end
