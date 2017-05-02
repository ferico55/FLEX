//
//  AlertListView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "AlertListView.h"
#import "AlertListViewCell.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;
@end

@interface AlertListView ()<UITableViewDataSource, UITableViewDelegate, AlertListViewCellDelegate>
{
    NSMutableArray *_list;
}
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation AlertListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

-(void)awakeFromNib
{
    _list = [NSMutableArray new];
    _table.delegate = self;
    _table.dataSource = self;
}

#pragma mark - properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *list = [_data objectForKey:kTKPDALERTVIEW_DATALISTKEY];
        [_list addObjectsFromArray:list];
        
    }
}

#pragma mark - Table Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    NSString *cellid = kTKPDALERTLISTVIEWCELL_IDENTIFIER;
    
    if (_list.count>0) {
        cell = (AlertListViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [AlertListViewCell newcell];
            ((AlertListViewCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            ((AlertListViewCell*)cell).label.text = _list[indexPath.row];
            ((AlertListViewCell*)cell).indexpath = indexPath;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Helper Methods
- (void)dismissAlertWithIndex:(NSInteger)index {
    
    [self dismissWithClickedButtonIndex:index animated:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

@end
