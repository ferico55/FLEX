//
//  Alert1ButtonView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "alert.h"
#import "Alert1ButtonView.h"

@interface Alert1ButtonView ()
@property (weak, nonatomic) IBOutlet UILabel *labelmessage;

@end

@implementation Alert1ButtonView

#pragma mark - properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSString *message;
        if ([[_data objectForKey:kTKPDALERTVIEW_DATALABELKEY] isKindOfClass:[NSArray class]]) {
            NSArray *messages =[_data objectForKey:kTKPDALERTVIEW_DATALABELKEY];
            message = [[messages valueForKey:@"description"] componentsJoinedByString:@"\n"];
        }
        else
        {
            message = [_data objectForKey:kTKPDALERTVIEW_DATALABELKEY];
        }
    
        _labelmessage.text = message;
    }
}

@end
