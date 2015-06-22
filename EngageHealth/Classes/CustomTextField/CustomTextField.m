//
//  CustomTextField.m
//  IBHREUniversal
//
//  Created by Nassif on 11/09/13.
//  Copyright (c) 2013 Mobomo. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField



- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
    }
    return self;
}

- (void)awakeFromNib
{
    if ([self.attributedPlaceholder length])
    {
        // Extract attributes
        NSDictionary * attributes = (NSMutableDictionary *)[ (NSAttributedString *)self.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];
        
        NSMutableDictionary * newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
        float placeHolderColorValue = 154.0/255.0;
        [newAttributes setObject:[UIColor colorWithRed:placeHolderColorValue green:placeHolderColorValue blue:placeHolderColorValue alpha:1.0] forKey:NSForegroundColorAttributeName];
        
        // Set new text with extracted attributes
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.attributedPlaceholder string] attributes:newAttributes];
        float textColorValue = 81.0/255.0;
        self.textColor = [UIColor colorWithRed:textColorValue green:textColorValue blue:textColorValue alpha:1.0];
    }
}
@end
