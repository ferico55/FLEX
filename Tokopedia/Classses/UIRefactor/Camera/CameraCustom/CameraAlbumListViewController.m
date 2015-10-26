//
//  CameraAlbumListViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "CameraAlbumListCell.h"

@interface CameraAlbumListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation CameraAlbumListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Album";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    [self getAsset];
}

-(void)getAsset
{
    [_table registerClass:[CameraAlbumListCell class] forCellReuseIdentifier:@"CameraAlbumListCellIdentifier"];
    
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [_groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
            {
                errorMessage = @"You can enable access in Privacy Setting";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This app does not have access to your photos or videos." message:errorMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                break;
            }
            default:
                errorMessage = @"Reason unknown.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                break;
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [_groups addObject:group];
        }
        else
        {
            [_table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;
    [_assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

#pragma mark - UITableViewDataSource

// determine the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _groups.count;
}

// determine the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CameraAlbumListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *groupForCell = _groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell.imageView.image = posterImage;
    cell.textLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [@(groupForCell.numberOfAssets) stringValue];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CameraCollectionViewController *vc = [CameraCollectionViewController new];
    vc.assetsGroup = _groups[indexPath.row];
    if ([_delegate conformsToProtocol:@protocol(CameraCollectionViewControllerDelegate)]) {
        vc.delegate = (id <CameraCollectionViewControllerDelegate>)_delegate;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tap:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
