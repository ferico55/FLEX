//
//  EtalaseCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EtalaseCellDelegate <NSObject>
@required
-(void)deleteEtalaseWithIndexPath:(NSIndexPath*)indexpath;

@end

@interface EtalaseCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) IBOutlet UIImageView *deleteImageView;

@property (strong, nonatomic) NSIndexPath *indexpath;
@property (nonatomic, weak) id<EtalaseCellDelegate> delegate;

@property (nonatomic) BOOL showDetail;
@property (nonatomic) BOOL showCheckImage;
@property (nonatomic) BOOL isEditable;

@end
