//
//  MinionClosingStream.m
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionClosingStream.h"
#import "MinionConstants.h"

@implementation MinionClosingStream

- (NSData *)data
{
    NSMutableData *data = [NSMutableData dataWithCapacity:MinionDataCapacity];
    [data appendData:self.headerData];
    
    NSUInteger status = EndianU32_NtoB(self.applicationStatus);
    [data appendBytes:&status length:4];
    
    [data appendBytes:&status length:1];
    
    unsigned char carrier = 0x00;
    [data appendBytes:&carrier length:1];
    [data appendBytes:&carrier length:1];
    [data appendBytes:&carrier length:1];
    
    return [data copy];
}

@end
