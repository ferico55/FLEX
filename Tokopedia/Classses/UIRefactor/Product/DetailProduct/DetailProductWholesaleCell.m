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

@interface DetailProductWholesaleCell ()
{
    NSMutableArray *_wholesales;
    BOOL _isnodata;
    BOOL _tableHeightUpdate;
}

@property (strong, nonatomic) IBOutlet UITableView *tabel;

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
    }
    return self;
}

- (void)awakeFromNib
{
    _isnodata = YES;
    _wholesales = [NSMutableArray new];
    
    self.tabel.layer.borderColor = [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1].CGColor;
    self.tabel.layer.borderWidth = 0.5;
    self.tabel.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    NSlog(@"asda");
    return _isnodata?1:_wholesales.count;
#else
    NSInteger rows = _isnodata?0:_wholesales.count;
    if (rows>0) rows = rows+1;
    return rows;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDDETAILPRODUCTWHOLESALETABLECELLIDENTIFIER;
    cell = (DetailProductWholesaleTableCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [DetailProductWholesaleTableCell newcell];
        //((DetailProductWholesaleCell*)cell).delegate = self;
    }
    
    if (indexPath.row == 0) {
        ((DetailProductWholesaleTableCell*)cell).quantity.text = @"Quality Range";
        ((DetailProductWholesaleTableCell*)cell).price.text = @"Price Per Item";
    } else {
        WholesalePrice *wholesale = _wholesales[indexPath.row-1];
        if (indexPath.row == _wholesales.count-1)
            ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@" >= %@", wholesale.wholesale_min];
        else
            ((DetailProductWholesaleTableCell*)cell).quantity.text = [NSString stringWithFormat:@"%@ - %@", wholesale.wholesale_min, wholesale.wholesale_max];
        
        ((DetailProductWholesaleTableCell*)cell).price.text = [NSString stringWithFormat:@"Rp. %@", wholesale.wholesale_price];
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
            [_tabel layoutIfNeeded];
            CGSize size = _tabel.contentSize;
            CGRect tableframe = _tabel.frame;
            tableframe.size.height = size.height;
            _tabel.frame = tableframe;
            
        }
    }
}

@end
