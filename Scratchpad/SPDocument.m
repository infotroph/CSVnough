//
//  SPDocument.m
//  Scratchpad
//
//  Created by Chris Black on 2014-07-15.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SPDocument.h"

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
    if(![self csvString]){
        [self setCsvString:@"LOLDATA"];
    }
    [[self csvTextView] setString:[self csvString]];
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


/* This method lifted from the NSDocument subclassing tutorial. Rewrite with better error handling. */
- (BOOL)readFromData:(NSData *)csvdata ofType:(NSString *)CSV
               error:(NSError **)outError {
    BOOL readSuccess = NO;
    NSString *fileContents = [[NSString alloc]
                              initWithData:csvdata encoding:NSASCIIStringEncoding];
    if (!fileContents) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadUnknownError userInfo:nil];
    }
    if (fileContents) {
        readSuccess = YES;
        [self setCsvString:fileContents];
        [[self csvTextView] setString:[self csvString]];
    }
    NSLog(@"end of readFromData, csvString: " @"%@", [self csvString]);
    NSLog(@"end of readFromData, csvTextView: " @"%@", [[self csvTextView] string] );
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
