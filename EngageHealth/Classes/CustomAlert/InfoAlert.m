//
//  InfoAlert.m
//  RADKAT
//
//  Created by Adarsh M on 10/23/13.
//
//

#import "InfoAlert.h"

@implementation InfoAlert

+ (InfoAlert*)InfoAlert {
    
    static InfoAlert *alert = nil;
    static dispatch_once_t onceInst;
    
    dispatch_once(&onceInst, ^{
        alert = [[InfoAlert alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    });
    
    return alert;
}

+ (void)info:(NSString *)msg {
    
    [[self class] InfoAlert].message = msg;
    
    if([[self class] InfoAlert].isVisible == NO) {
        [[[self class] InfoAlert] show];
    }
}

+ (void)dismiss {
    
    if([[self class] InfoAlert].isVisible == YES) {
        [[[self class] InfoAlert] dismissWithClickedButtonIndex:0 animated:YES];
    }
}

@end

