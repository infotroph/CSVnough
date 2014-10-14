//
//  ParserDelegate.h
//  CSVnough
//
//  Created by Chris Black on 2014-08-08.
//  Copyright (c) 2014 Chris Black. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface ParserDelegate : NSObject <CHCSVParserDelegate>

@property (readonly) NSMutableArray *lines;
@property NSStringEncoding encodingUsedByParser;

-(id)initParserAndDelegateFromStream:(NSInputStream *)stream usedEncoding:(NSStringEncoding)encoding delimiter:(unichar)delimiter;

@end

