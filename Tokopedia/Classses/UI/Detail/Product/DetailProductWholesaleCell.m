//
//  DetailProductWholesaleCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "DetailProductWholesaleCell.h"
#import "DetailProductWholesaleTableCell.h"
#import "WholesalePrice.h"

@interface DetailProductWholesaleCell()
{
    NSMutableArray *_wholesales;
    BOOL _isnodata;
}
@property (weak, nonatomic) IBOutlet UITableView *tabel;

@end

@implementation DetailProductWholesaleCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DetailProductWholesaleCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _isnodata = YES;
    _wholesales = [NSMutableArray new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_wholesales.count;
#else
    return _isnodata?0:_wholesales.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        UITableViewCell* cell = nil;

        // Configure the cell...
        if (_wholesales.count > indexPath.row) {
            NSString *cellid = kTKPDDETAILPRODUCTWHOLESALETABLECELLIDENTIFIER;
            cell = (DetailProductWholesaleTableCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductWholesaleTableCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
            
            WholesalePrice *wholesale = _wholesales[indexPath.row];
            
            if (indexPath.row == _wholesales.count-1)
                ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@" >= %@", wholesale.wholesale_min];
            else
                ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@"%@ - %@", wholesale.wholesale_min, wholesale.wholesale_max];
            
            ((DetailProductWholesaleTableCell*)cell).price.text = [NSString stringWithFormat:@"Rp. %@", wholesale.wholesale_price];
            return cell;
        }
    }
    
    return cell;
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *wholesales = [_data objectForKey:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY];
        [_wholesales addObjectsFromArray:wholesales];
        
        if (_wholesales.count > 0) {
            _isnodata = NO;
        }
    }
}


@end
