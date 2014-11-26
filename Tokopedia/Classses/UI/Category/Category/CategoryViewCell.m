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
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *verticalBorderView;

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
    
    _view = [NSArray sortViewsWithTagInArray:_view];

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
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                NSIndexPath *indexpath = [_data objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
                NSInteger row = indexpath.row;
                NSIndexPath *indexpath1 = [NSIndexPath indexPathForRow:row inSection:gesture.view.tag-10];
                [_delegate CategoryViewCellDelegateCell:self withindexpath:indexpath1];
                break;
            }
        }
    }
}


#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *column = [_data objectForKey:kTKPDCATEGORY_DATACOLUMNSKEY];
        
        for (int i = 0; i<column.count; i++) {
            ((UIView *)_verticalBorderView[i]).hidden = NO;
            ((UIImageView*)_thumb[i]).image = nil;
            ((UIView*)_view[i]).hidden = NO;
            NSString *title =[column[i] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setLineSpacing:5];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [title length])];
            ((UILabel*)_lable[i]).attributedText = attributedString ;
            ((UILabel*)_lable[i]).textAlignment = NSTextAlignmentCenter;
            NSString *icon = [column[i] objectForKey:kTKPDCATEGORY_DATAICONKEY];
            ((UIImageView*)_thumb[i]).image = [UIImage imageNamed:icon];
        }
        for (int i = 1; i < (3-column.count); i++) {
            ((UIView *)_verticalBorderView[i]).hidden = YES;
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
    [_lable makeObjectsPerformSelector:@selector(setText:) withObject:nil];
}


@end
