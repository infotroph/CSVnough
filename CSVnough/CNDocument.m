//
//  SPDocument.m
//  CSVnough
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "CNDocument.h"
#import "CHCSVParser.h"
#import "ParserDelegate.h"

// TODO: be flexible with this, parser already knows how
#define DELIMITER ','

@implementation CNDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"CNDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    if(![self parsedCSVArray]){
        // No file open, set up an empty one-cell 'grid' instead.
        // Will add more rows & cols as needed.
        // TODO: check more carefully that it's 'no file' and not 'open failed.'
        NSString *estr = @"\n";
        NSData *empty = [estr dataUsingEncoding:NSUTF8StringEncoding];
        [self readFromData:empty ofType:nil error:nil];
    }
    [self.table setTarget:self];
    [self.table setDelegate:self];
    [self.table setGridStyleMask:NSTableViewGridNone];
    [self.table setIntercellSpacing:NSMakeSize(1,1)];
    [self.table setRowSizeStyle:NSTableViewRowSizeStyleMedium];
    [self.table setSelectionHighlightStyle: NSTableViewSelectionHighlightStyleRegular];
    [self.table editColumn:0 row:0 withEvent:nil select:NO];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

+ (BOOL)autosavesDrafts
{
    return NO;
}

- (BOOL)readFromData:(NSData *)data
              ofType:(NSString *)CSV
               error:(NSError *__autoreleasing *)outError{
    [[self undoManager] disableUndoRegistration];
    BOOL readSuccess = NO;
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    ParserDelegate * pd = [[ParserDelegate alloc] initParserAndDelegateFromStream:stream usedEncoding:4 delimiter:DELIMITER];
    [[pd parser] parse];
    [self setParsedCSVArray:[pd lines]];
    if (![self parsedCSVArray]) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    } else {
        readSuccess = YES;
//        NSLog(@"%@ %@", NSStringFromSelector(_cmd), [self parsedCSVArray]);
    }
    [[self undoManager] enableUndoRegistration];
    return readSuccess;
}

- (NSData *)dataOfType:(NSString *)CSV
                 error:(NSError **)outError {
    NSOutputStream *dstr = [[NSOutputStream alloc] initToMemory];
    CHCSVWriter *w = [[CHCSVWriter alloc] initWithOutputStream:dstr encoding:NSUTF8StringEncoding delimiter:DELIMITER];
    for(NSArray *row in self.parsedCSVArray){
       // NSLog(@"%@", row);
        [w writeLineOfFields:row];
    }
    NSData *data = [dstr propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    // NSLog(@"%@", [data description]);
    if (!data) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
    }
    [w closeStream];
    return data;
}

- (void) controlTextDidEndEditing: (NSNotification *) notification {
    int rowi = (int)[_table rowForView:[notification object]];
    int coli = (int)[_table columnForView:[notification object]];
    int textMovement = [[[notification userInfo] valueForKey:@"NSTextMovement"] intValue];

    [self addCellsIfNeededAtColumn:coli row:rowi];
    [[_parsedCSVArray objectAtIndex:rowi] replaceObjectAtIndex:coli withObject:[notification.object stringValue]];
    [self updateChangeCount:NSChangeDone];

    // At edge of grid? Add more!
    if ((rowi+1 == [_table numberOfRows])
        && (textMovement == NSReturnTextMovement  || textMovement == NSDownTextMovement)) {
        [self addCellsIfNeededAtColumn:coli row:rowi+1];
        [_table reloadData];
    }
    if ((coli+1 == [_table numberOfColumns])
        && (textMovement == NSTabTextMovement  || textMovement == NSRightTextMovement)) {
        [self addCellsIfNeededAtColumn:coli+1 row:rowi];
        [_table reloadData];
    }
}

- (void) addCellsIfNeededAtColumn:(NSInteger)col row:(NSInteger) row {
    // Extend parsed array as needed to contain new cells
    while(row >= [_parsedCSVArray count]){
        NSMutableArray *newrow = [[NSMutableArray alloc] init];
        for(int i=0; i<col; i++){
            [newrow addObject:@""];
        }
        [_parsedCSVArray addObject:newrow];
    }
    while(col >= [[_parsedCSVArray objectAtIndex:row] count]){
        [[_parsedCSVArray objectAtIndex:row] addObject:@""];
    }
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.parsedCSVArray.count;
}

- (NSInteger)numberOfColumnsInTableView:(NSTableView *)tableView {
    NSInteger ntablecol = 0;
    for(NSArray *tablerow in self.parsedCSVArray){
        if ([tablerow count] > ntablecol){
            ntablecol = [tablerow count];
        }
    }
    return (NSInteger) ntablecol;
}

- (NSView *)tableView:(NSTableView *)tv viewForTableColumn:(NSTableColumn *)tc row:(NSInteger)row {
    
    NSArray *rowarr = [[self parsedCSVArray] objectAtIndex:row];
    NSInteger colidx = [tv columnWithIdentifier:[tc identifier]];
    
    if(colidx == -1){ // have never seen this happen -- safe to remove check?
        NSLog(@"Couldn't find a column matching that identifier. Aborting!");
        return nil;
    }
    [tc.headerCell setStringValue:[[NSNumber numberWithInteger:colidx+1] stringValue]];
    
    while (rowarr.count > [tv numberOfColumns]){
//        NSLog(@"%ld columns in view, %lu fields in row %ld. Adding a column.", (long)[tv numberOfColumns], (unsigned long)[rowarr count], (long)row);
        NSTableColumn *newtc = [[NSTableColumn alloc]
                                initWithIdentifier:[NSString stringWithFormat:@"%ld",
                                                    (long)[tv numberOfColumns]+1]];
        [tv addTableColumn:newtc];
        [tv reloadData];
    }
    
    NSTextField *cell = [tv makeViewWithIdentifier:@"tablecellview" owner:self];
    
    if (cell == nil) {
        cell = [[NSTextField alloc] initWithFrame:NSRectFromString(@"100,100")];
        cell.identifier = @"tablecellview";
        cell.delegate = (id)self; //(id) to suppress protocol mismatch messages. Hacky!
    }
    
    [cell setNeedsDisplay:YES];
    return cell;    
}

- (id) tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(NSInteger)row {
    NSArray *rowarr = [_parsedCSVArray objectAtIndex:row];
    NSInteger colidx = [tv columnWithIdentifier:[tc identifier]];
    [self addCellsIfNeededAtColumn:colidx row:row];
    return rowarr[colidx];
}


@end
