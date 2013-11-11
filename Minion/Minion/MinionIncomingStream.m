//
//  MinionIncomingStream.m
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionIncomingStream.h"

@implementation MinionIncomingStream
@synthesize role    = _role;
@synthesize flags   = _flags;

- (NSString *)description
{
    NSString *superDescription = [super description];
    
    return [NSString stringWithFormat:@"IncomingStream with Role: %ld, Flags: %ld, %@", self.role, self.flags, superDescription];
}

- (void)processContentData:(NSData *)data
{
    NSUInteger role;
    
    [data getBytes:&role range:NSMakeRange(0, 2)];
    
    _role = EndianU16_BtoN(role);
    
    [data getBytes:&_flags range:NSMakeRange(2, 1)];
}

@end
