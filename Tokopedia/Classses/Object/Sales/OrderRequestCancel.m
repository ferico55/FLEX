//
//  OrderRequestCancel.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "OrderRequestCancel.h"

@implementation OrderRequestCancel

-(NSAttributedString*)reasonFormattedString{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[self reasonString]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [self status].length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont microThemeMedium] range:NSMakeRange(0, [self status].length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([self status].length, [self time].length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont microTheme] range:NSMakeRange([self status].length, [self time].length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([self status].length+[self time].length, _reason.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont microThemeMedium] range:NSMakeRange([self status].length+[self time].length, _reason.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 0.6;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.string.length)];
    
    return attributedString;
}

-(NSString*)status{
    return @"Pembeli mengajukan pembatalan pesanan\n";
}

-(NSString*)time{
    return [NSString stringWithFormat:@"pada tanggal %@ dengan alasan:\n",_reason_time];
}

-(NSString*)reasonString{
    return [NSString stringWithFormat:@"%@%@\"%@\"",[self status], [self time], self.reason];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"cancel_request",
                      @"reason_time",
                      @"reason"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
