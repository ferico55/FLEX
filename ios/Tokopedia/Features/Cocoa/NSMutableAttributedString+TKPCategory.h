//
//  NSMutableAttributedString+TKPCategory.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/15/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (TKPCategory)

-(void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color withFont:(UIFont*) font;

@end
