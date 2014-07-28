//
//  Document.h
//  Scratchpad
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPDocument : NSDocument

-(NSString *)csvString;
-(void)setcsvString:(NSString *)data;

@property (unsafe_unretained) IBOutlet NSTableCellView *csvTextTableCell;
@property (weak) IBOutlet NSTextField *csvTextField;


@end
