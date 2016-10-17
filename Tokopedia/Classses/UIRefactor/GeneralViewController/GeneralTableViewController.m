//
//  GeneralTableViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "category.h"
#import "EtalaseList.h"
#import "GeneralTableViewController.h"
#import "ResizeableImageCell.h"

@interface GeneralTableViewController ()
<
    UISearchBarDelegate
>
{
    NSIndexPath *_selectedIndexPath;
    NSDictionary *_textAttributes;
    NSMutableArray *_searchResults;
    NSMutableArray *_searchContents;
    NSString *strObjectName;
}

@end

@implementation GeneralTableViewController
@synthesize isObjectCategory;


- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;

    _textAttributes = @{
                        NSFontAttributeName            : [UIFont title2Theme],
                        NSParagraphStyleAttributeName  : style,
                        };
    
    if (!_tableViewCellStyle) {
        _tableViewCellStyle = UITableViewCellStyleDefault;
    }
    
    if (_enableSearch) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.placeholder = @"Cari";
        _searchBar.delegate = self;
        self.tableView.tableHeaderView = _searchBar;

        if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
            _searchContents = [NSMutableArray new];
            for (NSArray *array in _objects) {
                [_searchContents addObject:[array objectAtIndex:0]];
            }
        } else if (_tableViewCellStyle == UITableViewCellStyleDefault) {
            _searchContents = [NSMutableArray arrayWithArray:_objects];
        }
        
        _searchResults = [NSMutableArray new];
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 1;
    self.navigationItem.rightBarButtonItem = doneButton;
    if(_selectedObject == nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    

    if (_isPresentedViewController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(tap:)];
        cancelButton.tag = 2;
        self.navigationItem.leftBarButtonItem = cancelButton;
    } else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(tap:)];
        backButton.tag = 2;
        self.navigationItem.backBarButtonItem = backButton;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"General Table Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBar.text.length > 0) {
        return [_searchResults count];
    }
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (_objectImages.count > 0)
    {
        cell = (ResizeableImageCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (cell == nil) {
            cell = [ResizeableImageCell newCell];
        }
    }
    else
    {
        cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:_tableViewCellStyle reuseIdentifier:nil];
        }
    }

    id object;
    id objectImage;
    
    if (_searchBar.text.length > 0) {
        object = [_searchResults objectAtIndex:indexPath.row];
    } else {
        object = [_objects objectAtIndex:indexPath.row];
    }
    
    if (_objectImages.count > 0)
    {
        objectImage = [_objectImages objectAtIndex:indexPath.row];
    }
    
    if (_objectImages.count > 0)
    {
        //Set image product
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:objectImage] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        UIImageView *thumb = ((ResizeableImageCell*)cell).thumb;
        thumb.image = nil;
        [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@" " ofType:@"png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
            [thumb setContentMode:UIViewContentModeCenter];
            [thumb setImage:image];
#pragma clang diagnostic pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        
        ((ResizeableImageCell*)cell).textCellLabel.text= [object description];
    }
    
    else if (_tableViewCellStyle == UITableViewCellStyleDefault) {
        if(isObjectCategory) {
            cell.textLabel.text = [((NSDictionary *)object) objectForKey:kTKPDCATEGORY_DATATITLEKEY];
        }
        else if([object isMemberOfClass:[EtalaseList class]]) {
            cell.textLabel.text = ((EtalaseList *)object).etalase_name;
        }
        else {
            cell.textLabel.text = [object description];
            cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[object description]
                                                                        attributes:_textAttributes];
        }
        cell.textLabel.numberOfLines = 0;
    }
    
    else if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
        if ([object isKindOfClass:[NSArray class]]) {
            cell.textLabel.text = [object objectAtIndex:0];
            cell.textLabel.font = [UIFont title2Theme];
            
            cell.detailTextLabel.text = [object objectAtIndex:1];
            cell.detailTextLabel.font = [UIFont title2Theme];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
    }
    
    if(isObjectCategory && [[((NSDictionary *)object) objectForKey:kTKPDCATEGORY_DATADIDKEY] isEqualToString:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    }
    else if([object isMemberOfClass:[EtalaseList class]] && [((EtalaseList *) object).etalase_id isEqualToString:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    }
    else if ([object isEqual:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(! self.navigationItem.rightBarButtonItem.isEnabled) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_searchBar.text.length > 0) {
        _selectedObject = [_searchResults objectAtIndex:indexPath.row];
        NSInteger index = [_objects indexOfObject:_selectedObject];
        _selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];

        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        if(isObjectCategory) {
            _selectedObject = [((NSDictionary *) [_objects objectAtIndex:indexPath.row]) objectForKey:kTKPDCATEGORY_DATADIDKEY];
            strObjectName = [((NSDictionary *) [_objects objectAtIndex:indexPath.row]) objectForKey:kTKPDCATEGORY_DATATITLEKEY];
        }
        else if([[_objects objectAtIndex:indexPath.row] isMemberOfClass:[EtalaseList class]]) {
            _selectedObject = ((EtalaseList *) [_objects objectAtIndex:indexPath.row]).etalase_id;
            strObjectName = ((EtalaseList *) [_objects objectAtIndex:indexPath.row]).etalase_name;
        }
        else
            _selectedObject = [_objects objectAtIndex:indexPath.row];
        _selectedIndexPath = indexPath;

        cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (self.shouldPopBack) {
        if ([self.delegate respondsToSelector:@selector(didSelectObject:senderIndexPath:)]) {
            [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    if (_tableViewCellStyle == UITableViewCellStyleDefault) {
        _searchResults = [NSMutableArray arrayWithArray:[_searchContents filteredArrayUsingPredicate:resultPredicate]];
    } else if (_tableViewCellStyle == UITableViewCellStyleSubtitle) {
        NSArray *searchResult = [_searchContents filteredArrayUsingPredicate:resultPredicate];
        _searchResults = [NSMutableArray new];
        for (NSString *result in searchResult) {
            for (NSArray *arary in _objects) {
                if ([[arary objectAtIndex:0] isEqualToString:result]) {
                    [_searchResults addObject:arary];
                }
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            if([self.delegate respondsToSelector:@selector(didSelectObject:senderIndexPath:withObjectName:)]) {
                [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath withObjectName:strObjectName];
            }
            else if ([self.delegate respondsToSelector:@selector(didSelectObject:senderIndexPath:)]) {
                [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath];
            } else if ([self.delegate respondsToSelector:@selector(didSelectObject:)]) {
                [self.delegate didSelectObject:_selectedObject];
            } else if ([self.delegate respondsToSelector:@selector(viewController:didSelectObject:)]) {
                [self.delegate viewController:self didSelectObject:_selectedObject];
            }
            if (_isPresentedViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else if (button.tag == 2) {
            if (_isPresentedViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
