//
//  Document.h
//  Scratchpad
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPDocument : NSDocument <NSTableViewDelegate, NSTableViewDataSource, NSControlTextEditingDelegate>

@property NSString *csvString;
@property (assign) IBOutlet NSTextView *csvTextView;
@property NSMutableArray *parsedCSVArray;
@property (weak) IBOutlet NSTableView *table;

- (NSInteger)numberOfColumnsInTableView:(NSTableView *) tableView;

@end

