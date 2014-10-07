//
//  DetailCatalogSpecView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogSpecs.h"

#import "detail.h"
#import "DetailCatalogSpecView.h"
#import "DetailCatalogSpecViewCell.h"
#import "CatalogSpecViewHeaderView.h"

@interface DetailCatalogSpecView()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isnodata;
    
    CatalogSpecs *_specs;
}
@property (weak, nonatomic) IBOutlet UIView *headerview;

@end

@implementation DetailCatalogSpecView

#pragma mark - Factory Method
+ (id)newview
{
	NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (id view in views) {
		if ([view isKindOfClass:[self class]]) {
			return view;
		}
	}
	return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Tableview Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *specs = (NSArray*)_specs;
    CatalogSpecs *spec = specs[section];
    CatalogSpecViewHeaderView *v = [CatalogSpecViewHeaderView newview];
    v.headerlabel.text = spec.spec_header;
    return v;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifdef kTKPDCATALOGSPECS_NODATAENABLE
    return _isnodata ? 1 : ((NSArray*)_specs).count;
#else
    return _isnodata ? 0 : ((NSArray*)_specs).count;
#endif
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *specs = (NSArray*)_specs;
    CatalogSpecs *spec = specs[section];
    NSArray *childs = spec.spec_childs;
#ifdef kTKPDCATALOGSPECS_NODATAENABLE
    return _isnodata ? 1 : childs.count;
#else
    return _isnodata ? 0 : childs.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        UITableViewCell* cell = nil;

        NSString *cellid = kTKPDDETAILCATALOGSPECVIEWCELLIDENTIFIER;
            
        cell = (DetailCatalogSpecViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [DetailCatalogSpecViewCell newcell];
        }
        
        NSArray *specs = (NSArray*)_specs;
        CatalogSpecs *spec = specs[indexPath.section];
        NSArray *childs = spec.spec_childs;
        
        if (childs.count > indexPath.row) {
            SpecChilds *child = childs[indexPath.row];
            ((DetailCatalogSpecViewCell*)cell).speckeylabel.text = child.spec_key;
            if (child.spec_val.count == 0) {
                ((DetailCatalogSpecViewCell*)cell).specvallabel.text = @"-";
            }
            else
                ((DetailCatalogSpecViewCell*)cell).specvallabel.text = [[child.spec_val valueForKey:@"description"] componentsJoinedByString:@","];
        }
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
}
    
#pragma mark - properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        id specs = [_data objectForKey:kTKPDDETAILCATALOG_APICATALOGSPECSKEY]?:@[];
        _specs = specs;
        _isnodata = NO;
    }
}

@end
