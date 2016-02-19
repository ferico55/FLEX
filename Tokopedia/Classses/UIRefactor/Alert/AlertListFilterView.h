//
//  AlertListFilterView.h
//  Tokopedia
//
//  Created by Renny Runiawati on 9/28/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlert.h"

@interface AlertListFilterView : TKPDAlert <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *list;
@property id selectedObject;

@end
