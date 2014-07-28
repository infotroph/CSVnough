//
//  Document.m
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
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

+ (BOOL)autosavesDrafts
{
    return NO;
}

- (void)setcsvString:(NSString *)data {
    [self.csvTextField setStringValue:data];
}

- (NSString *)csvString {
    return [self.csvTextField stringValue];
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
        [self setcsvString:fileContents];
    }
    NSLog(@"%@", fileContents);
    NSLog(@"%@", self.csvString);
    return readSuccess;
}

- (NSData *)dataOfType:(NSString *)CSV error:(NSError **)outError {
    NSData *data;
    data = [self.csvString dataUsingEncoding:NSASCIIStringEncoding];
    if (!data) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileWriteUnknownError userInfo:nil];
    }
    return data;
}


@end
