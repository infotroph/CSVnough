//
//  SPDocument.m
//  Scratchpad
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SPDocument.h"
#import "CHCSVParser.h"
#import "ParserDelegate.h"

// TODO: be flexible with this, parser already knows how
#define DELIMITER ','

@implementation SPDocument

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
    return @"SPDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    if([self parsedCSVArray]){
        [[self csvTextView] setString:[[self parsedCSVArray] componentsJoinedByString:@"\n"]];
    }
    [self.table setTarget:self];
    [self.table setDelegate:self];
    [self.table setGridStyleMask:NSTableViewGridNone];
    [self.table setIntercellSpacing:NSMakeSize(1,1)];
    [self.table setRowSizeStyle:NSTableViewRowSizeStyleMedium];
    [self.table setSelectionHighlightStyle: NSTableViewSelectionHighlightStyleRegular];
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
    BOOL readSuccess = NO;
    //NSLog(@"Trying to parse %lu bytes", [data length]);
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    CHCSVParser *p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:nil delimiter:DELIMITER];
    ParserDelegate * pd = [[ParserDelegate alloc] init];
    [p setDelegate:pd];
    [p parse];
    [self setParsedCSVArray:[pd lines]];
    
    if (![self parsedCSVArray]) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadUnknownError userInfo:nil];
    } else {
        readSuccess = YES;
//        NSLog(@"%@ %@", NSStringFromSelector(_cmd), [self parsedCSVArray]);
    }
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
    // NSLog(@"controlTextDidEndEditing: stringValue == %@, row == %d, col==%d", [notification.object stringValue], rowi, coli);
    // NSLog(@"previously: %@", [[_parsedCSVArray objectAtIndex:rowi] objectAtIndex:coli]);
    [[_parsedCSVArray objectAtIndex:rowi] replaceObjectAtIndex:coli withObject:[notification.object stringValue]];
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
    
    if ((colidx) < [rowarr count]){ // is this check necessary?
//        NSLog(@"row %ld col %ld equals %@", (long)row, (long)colidx, rowarr[colidx]);
        cell.stringValue = rowarr[colidx];
    }
    [cell setNeedsDisplay:YES];
    return cell;    
}


@end
