//
//  GridTableView.m
//  CSVnough
//
//  Created by Chris Black on 2014-08-08.
//  Copyright (c) 2014 Chris Black. All rights reserved.
//

#import "GridTableView.h"

@implementation GridTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSLog(@"Yes, table init code is being run");
        [self.table setGridStyleMask:NSTableViewGridNone];
        [self.table setIntercellSpacing:NSMakeSize(20,20)];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
