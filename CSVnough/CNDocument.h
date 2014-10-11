//
//  CNDocument.h
//  CSVnough
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CNDocument : NSDocument <NSTableViewDelegate, NSTableViewDataSource, NSControlTextEditingDelegate>

@property NSMutableArray *parsedCSVArray;
@property (weak) IBOutlet NSTableView *table;

@end

