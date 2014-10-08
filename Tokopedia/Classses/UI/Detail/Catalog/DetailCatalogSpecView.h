//
//  DetailCatalogSpecView.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCatalogSpecView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tabel;
@property (nonatomic, strong) NSDictionary *data;

+ (id)newview;

@end
