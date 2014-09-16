//
//  DetailProductViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"

#import "Product.h"

#import "DetailProductViewController.h"
#import "DetailProductWholesaleCell.h"
#import "DetailProductDescriptionCell.h"

@interface DetailProductViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableDictionary *_detailproduct;
    NSMutableIndexSet *expandedSections;
    BOOL _isexpanded;
    NSInteger _heightOfSection;
}


@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UILabel *countview;
@property (weak, nonatomic) IBOutlet UIButton *reviewbutton;
@property (weak, nonatomic) IBOutlet UIButton *talaboutbutton;
@property (weak, nonatomic) IBOutlet UILabel *productdescriptionlabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopthumb;
@property (weak, nonatomic) IBOutlet UILabel *shopname;
@property (weak, nonatomic) IBOutlet UILabel *shoplocation;


@end

@implementation DetailProductViewController

@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _detailproduct = [NSMutableDictionary new];
    _isexpanded = NO;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 200;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 120;
        _table.contentInset = inset;
    }
    
    _table.tableHeaderView = _headerview;
    
    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    [self configureRestKit];
    [self loadData];
    
}

#pragma mark -Table view delegate
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    if (section>0) return YES;
    
    return NO;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self tableView:tableView canCollapseSection:indexPath.section])
//    {
//        if (!indexPath.row)
//        {
//            // only first row toggles exapand/collapse
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            NSInteger section = indexPath.section;
//            BOOL currentlyExpanded = [expandedSections containsIndex:section];
//            NSInteger rows;
//            
//            NSMutableArray *tmpArray = [NSMutableArray array];
//            
//            if (currentlyExpanded)
//            {
//                rows = [self tableView:tableView numberOfRowsInSection:section];
//                [expandedSections removeIndex:section];
//                
//            }
//            else
//            {
//                [expandedSections addIndex:section];
//                rows = [self tableView:tableView numberOfRowsInSection:section];
//            }
//            
//            if (currentlyExpanded)
//            {
//                [tableView deleteRowsAtIndexPaths:tmpArray
//                                 withRowAnimation:UITableViewRowAnimationTop];
//            }
//            else
//            {
//                [tableView insertRowsAtIndexPaths:tmpArray
//                                 withRowAnimation:UITableViewRowAnimationTop];
//            }
//        }
//    }
//}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *mView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 200)];
    [mView setBackgroundColor:[UIColor greenColor]];
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    [logoView setImage:[UIImage imageNamed:@"carat.png"]];
    [mView addSubview:logoView];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(0, 0, 150, 20)];
    [bt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [bt setTag:section];
    [bt.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [bt.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [bt.titleLabel setTextColor:[UIColor blackColor]];
    [bt setTitle: @"More Info" forState: UIControlStateNormal];
    [bt addTarget:self action:@selector(addCell:) forControlEvents:UIControlEventTouchUpInside];
    [mView addSubview:bt];
    
    NSLog(@"SECTION %d BUTTON %@",section, bt.titleLabel);
    
    return mView;
    
}

#pragma mark - Suppose you want to hide/show section 2... then
#pragma mark  add or remove the section on toggle the section header for more info

- (void)addCell:(UIButton *)bt{
    
    // If section of more information
    //if (bt.tag) {
        // Initially more info is close, if more info is open
        if(_isexpanded) {
            // Set height of section
            _heightOfSection = 0;
            // Reset the parameter that more info is closed now
            _isexpanded = NO;
        }else {
            // Set height of section
            _heightOfSection = 145.0f;
            // Reset the parameter that more info is closed now
            _isexpanded = YES;
        }
        //[self.tableView reloadData];
        [_table reloadSections:[NSIndexSet indexSetWithIndex:bt.tag] withRowAnimation:UITableViewRowAnimationFade];
    //}
}

#pragma mark -
#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //if (indexPath.section == 1) {
        return _heightOfSection;
    //}else {
     //   return 0;
    //}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (_isexpanded) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            cell = (DetailProductDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductDescriptionCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
        }
        return cell;
    }
    if (indexPath.section == 1) {
        if (_isexpanded) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            cell = (DetailProductDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductDescriptionCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
        }
        return cell;
    }
    if (indexPath.section == 2) {
         if (_isexpanded) {
            NSString *cellid = kTKPDDETAILPRODUCTCELLIDENTIFIER;
            cell = (DetailProductDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [DetailProductDescriptionCell newcell];
                //((DetailProductWholesaleCell*)cell).delegate = self;
            }
            
            return cell;
        }
    }
    return cell;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mapping

- (void)configureRestKit
{
    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedManager];
    
    // setup object mappings
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
    [productMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APISTATUSKEY:kTKPDDETAIL_APISTATUSKEY,kTKPRDETAIL_APISERVERPROCESSTIMEKEY:kTKPRDETAIL_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
    RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[Info class]];
    [infoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTWEIGHTUNITKEY:kTKPDDETAILPRODUCT_APIPRODUCTWEIGHTUNITKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTDESCRIPTIONKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTINSURANCEKEY:kTKPDDETAILPRODUCT_APIPRODUCTINSURANCEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTCONDITIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTCONDITIONKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTMINORDERKEY:kTKPDDETAILPRODUCT_APIPRODUCTMINORDERKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                      kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY
                                                      }];
    
    RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
    [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTRATINGKEY:kTKPDDETAILPRODUCT_APIPRODUCTRATINGKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                           kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY
                                                           }];
    
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPIDKEY:kTKPDDETAILPRODUCT_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];
    
    RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
    [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,kTKPDDETAILPRODUCT_APIDEPARTMENTIDKEY]];
    
    RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
    [otherproductMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIPRODUCTPRICEKEY,kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];

    RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
    [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY withMapping:infoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
    
    [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responsebreadcrumbDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:breadcrumbMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"result.breadcrumb" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseotherproductDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:otherproductMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"result.other_product" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseproductimagesDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imagesMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"result.product_images" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addResponseDescriptor:responsebreadcrumbDescriptor];
    [objectManager addResponseDescriptor:responseotherproductDescriptor];
    [objectManager addResponseDescriptor:responseproductimagesDescriptor];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responsebreadcrumbDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseotherproductDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseproductimagesDescriptor.keyPath ?: [NSNull null])];
    
}

- (void)loadData
{
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(requesttimeout)
                                   userInfo:nil
                                    repeats:NO];
    
	NSDictionary* param = @{
                            @"action" : @"get_detail",
                            @"product_id" : @(9622)
                            };
    
    [[RKObjectManager sharedManager] getObjectsAtPath:kTKPDDETAILPRODUCT_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
    }];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    Product *product = stats;
    BOOL status = [product.status isEqualToString:@"OK"];
    
    if (status) {
        NSArray* breadcrumb = [result objectForKey:@"result.breadcrumb"];
        NSArray* otherproduct = [result objectForKey:@"result.other_product"];
        NSArray* productimage = [result objectForKey:@"result.product_images"];

        [_detailproduct setObject:result forKey:@"product"];
        [_detailproduct setObject:breadcrumb forKey:@"breadcrumb"];
        [_detailproduct setObject:otherproduct forKey:@"oterproduct"];
        [_detailproduct setObject:productimage forKey:@"productimages"];
        
        [self setHeaderviewData:(id)product];
    }
}

-(void)requesttimeout
{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

-(void)requestfailure:(id)object
{
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - Methods
-(void) setHeaderviewData:(id)product{
    
    Product *p = product;
    _productnamelabel.text = p.result.info.product_name;
    _pricelabel.text = p.result.info.product_price;

}


@end
