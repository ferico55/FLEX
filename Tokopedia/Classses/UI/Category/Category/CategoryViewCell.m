//
//  CategoryViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//


#import "category.h"
#import "CategoryViewCell.h"

@interface CategoryViewCell()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lable;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *view;


@end


@implementation CategoryViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    for (UIView *view in _view) {
        view.multipleTouchEnabled = NO;
        view.exclusiveTouch = YES;
    }

}


#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CategoryViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - View Gesture
- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        NSIndexPath *indexpath = [_data objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
        NSInteger row = indexpath.row;
        NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:row inSection:gesture.view.tag-10];
        [_delegate CategoryViewCellDelegateCell:self withindexpath:indexpath1];
    }
}


#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *column = [_data objectForKey:kTKPDCATEGORY_DATACOLUMNSKEY];
        
        for (int i = 0; i<column.count; i++) {
            
            ((UIView*)_view[i]).hidden = NO;
            NSString *title =[column[i] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
            ((UILabel*)_lable[i]).text = title;
            
           NSString *icon = [column[i] objectForKey:kTKPDCATEGORY_DATAICONKEY];
            ((UIImageView*)_thumb[i]).image = [UIImage imageNamed:icon];
        }
    }
    else
    {
        [self reset];
    }
}

#pragma mark - Methods
-(void)reset
{
    [_thumb makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
}


@end
