//
//  MinionStream.m
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionStream.h"
#import "MinionIncomingStream.h"
#import "MinionWriteStream.h"
#import "MinionParams.h"
#import "MinionConstants.h"

@implementation MinionStream

+ (instancetype)streamWithHeaderData:(NSData *)data
{
    NSUInteger type;
    [data getBytes:&type range:NSMakeRange(1, 1)];
    
    MinionStream *stream;
    
    switch (type)
    {
        case FCGI_BEGIN_REQUEST:
            stream = [[MinionIncomingStream alloc] init];
            break;
            
        case FCGI_PARAMS:
            stream = [[MinionParams alloc] init];
            break;
            
        case FCGI_STDIN:
            stream = [[MinionWriteStream alloc] init];
            break;
            
        default:
            stream = nil;
            break;
    }
    
    NSUInteger fcgiVersion;
    [data getBytes:&fcgiVersion range:NSMakeRange(0, 1)];
    
    NSUInteger paddingLength;
    [data getBytes:&paddingLength range:NSMakeRange(6, 1)];
    
    NSUInteger identifier;
    [data getBytes:&identifier range:NSMakeRange(2, 2)];
    
    NSUInteger contentLength;
    [data getBytes:&contentLength range:NSMakeRange(4, 2)];

    stream.type             = type;
    stream.version          = fcgiVersion;
    stream.paddingLength    = paddingLength;
    stream.identifier       = EndianU16_BtoN(identifier);
    stream.contentLength    = EndianU16_BtoN(contentLength);
    
    return stream;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Stream Version: %ld, Type: %ld, Identifier: %ld, Content Length: %ld, Padding: %ld", self.version, self.type, self.identifier, self.contentLength, self.paddingLength];
}

- (void)processContentData:(NSData *)data
{
}

- (NSData *)headerData
{
    NSMutableData *data = [NSMutableData dataWithCapacity:MinionDataCapacity];
    [data appendBytes:&_version length:1];
    [data appendBytes:&_type length:1];

    NSUInteger identifier = EndianU16_NtoB(self.identifier);
    [data appendBytes:&identifier length:2];
    
    [data appendBytes:&_paddingLength length:1];
    
    unsigned char carrier = 0x00;
    [data appendBytes:&carrier length:1];
    
    return [data copy];
}

@end
