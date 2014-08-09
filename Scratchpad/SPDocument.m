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
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SPDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    if([self parsedCSVArray]){
        [[self csvTextView] setString:[[self parsedCSVArray] componentsJoinedByString:@"HOOOOOBOY"]];
    }
    
    NSLog(@"%@, csvString: " @"%@", NSStringFromSelector(_cmd), [self csvString]);
    NSLog(@"%@, csvTextView: " @"%@", NSStringFromSelector(_cmd), [[self csvTextView] string] );
    
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

+ (BOOL)autosavesDrafts
{
    return NO;
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)CSV error:(NSError *__autoreleasing *)outError{
    BOOL readSuccess = NO;
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
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), [self parsedCSVArray]);
    }
    return readSuccess;
}

- (NSData *)dataOfType:(NSString *)CSV error:(NSError **)outError {
    NSData *data;
    [self setCsvString:[self.csvTextView string]];
    data = [[self csvString] dataUsingEncoding:NSASCIIStringEncoding];
    if (!data) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileWriteUnknownError userInfo:nil];
    }
    NSLog(@"csvString: " @"%@", [self csvString]);
    NSLog(@"csvTextView.string: "@"%@", [[self csvTextView] string]);
    return data;
}
- (void) textDidChange: (NSNotification *) notification {
    NSLog(@"textDidChange: %@ --> %@", [self csvString], [[self.csvTextView textStorage] string] );
    self.csvString = [[self.csvTextView textStorage] string];
}

@end
