//
//  ParserDelegate.m
//  CSVnough
//
//  'Created' by Chris Black on 2014-08-08,
//  by copy-pasting from the reference implementation of Dave DeLong's CSCSVParser:
//
//  Copyright (c) 2014 Dave DeLong
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ParserDelegate.h"
#import "CHCSVParser.h"

@implementation ParserDelegate {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
    NSStringEncoding _encodingUsedByParser;
}
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser
  didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser
  didReadField:(NSString *)field
       atIndex:(NSInteger)fieldIndex {
    //NSLog(@"'%@' at %lu", field, fieldIndex);
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser
    didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"parser ended. Read %lu bytes, interpreted as %@: %@",
          (unsigned long)[parser totalBytesRead],
          CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(_encodingUsedByParser)),
          _lines);
}
- (void)parser:(CHCSVParser *)parser
didFailWithError:(NSError *)error {
    if([error code] == CHCSVErrorCodeBadCharacters){
        NSData *badbyte = [error.userInfo objectForKey:@"CHCSVBadData"];
        NSMutableString *possibleCharacters = [[NSMutableString alloc] initWithString:@""];
        for (int e=1; e<=30; e++) {
            NSStringEncoding encoding = e;
            NSString *readString = [[NSString alloc] initWithBytes:[badbyte bytes] length:[badbyte length] encoding:encoding];
            if (readString != nil){
                NSString *encstr = [NSString stringWithFormat:@"%@: \"%@\"\n",
                      CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding)),
                      readString];
                [possibleCharacters appendString:encstr];
            }
        }
        NSAlert *charAlert = [NSAlert alertWithError:error];
        [charAlert setInformativeText:[NSString stringWithFormat:@"Probable bad character %@ at byte %@ may be interpretable in one of the following encodings... %@", [badbyte description], [error.userInfo objectForKey:@"CHCSVBadDataByteOffset"], possibleCharacters]];
        NSLog(@"ERROR: %@ %@", [charAlert messageText], [charAlert informativeText]);
        [charAlert runModal];
        return;
    }
	NSLog(@"ERROR: %@", error);
    _lines = nil;
}


-(id)initParserAndDelegateFromStream:(NSInputStream *)stream usedEncoding:(NSStringEncoding)encoding delimiter:(unichar)delimiter {
    self = [super init];
    if(self == nil){
        NSLog(@"Initialization failed ¯\\_(ツ)_/¯");
        // TODO: Handle the error more sensibly.
    } else {
        if(encoding){
            _encodingUsedByParser = encoding;
        }
        _parser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&_encodingUsedByParser delimiter:delimiter];
        [_parser setDelegate:self];
    }
    return self;
}

@end

