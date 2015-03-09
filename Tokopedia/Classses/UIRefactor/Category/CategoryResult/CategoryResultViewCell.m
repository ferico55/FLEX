//
//  CategoryResultViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "category.h"
#import "CategoryResultViewCell.h"

@implementation CategoryResultViewCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CategoryResultViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSArray *column = [_data objectForKey: kTKPDCATEGORY_DATACOLUMNSKEY];
        
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
