//
//  ProdukFeedViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "ProductFeedViewCell.h"

@interface ProductFeedViewCell ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelprice;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labeldescription;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelalbum;


@end


@implementation ProductFeedViewCell

@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ProductFeedViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Initialization

//- (void)awakeFromNib
//{
//    for (int i = 0; i<_viewcell.count; i++) {
//        ((UIView*)_viewcell[i]).layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5].CGColor;
//        ((UIView*)_viewcell[i]).layer.borderWidth = 1.0f;
//    }
//}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *column = [_data objectForKey:kTKPDHOME_DATACOLUMNSKEY];
        
        for (int i = 0; i<column.count; i++) {
            ((UIView*)_viewcell[i]).hidden = NO;
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
    
}

@end
