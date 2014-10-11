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
    //    NSLog(@"parser ended. Read %lu bytes: %@",
    //      (unsigned long)[parser totalBytesRead],
    //      [[parser delegate] performSelector:@selector(lines)]);
}
- (void)parser:(CHCSVParser *)parser
didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
    _lines = nil;
}
@end

