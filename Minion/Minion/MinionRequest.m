//
//  MinionRequest.m
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionRequest.h"
#import "MinionConstants.h"
#import "MinionIncomingStream.h"
#import "MinionWriteStream.h"
#import "MinionClosingStream.h"
#import "GCDAsyncSocket.h"

@interface MinionRequest()
@property (strong, nonatomic) GCDAsyncSocket        *socket;
@property (strong, nonatomic) NSMutableData         *incomingData;
@property (strong, nonatomic) NSMutableDictionary   *mutableParameters;
@end

@implementation MinionRequest

- (instancetype)initWithIncoming:(MinionIncomingStream *)incomingStream onSocket:(GCDAsyncSocket *)socket
{
    self = [super init];
    if(self)
    {
        self.socket             = socket;
        self.identifier         = incomingStream.identifier;
        self.role               = incomingStream.role;
        self.keepConnection     = ((incomingStream.flags & FCGI_KEEP_CONN) != 0);
        self.mutableParameters  = [[NSMutableDictionary alloc] init];
        self.incomingData       = [NSMutableData dataWithCapacity:MinionDataCapacity];
    }
    return self;
}

- (void)setParameters:(NSDictionary *)parameters
{
    self.mutableParameters = [parameters copy];
}

- (NSDictionary *)parameters
{
    return [self.mutableParameters copy];
}

- (void)appendIncomingData:(NSData *)data
{
    [self.incomingData appendData:data];
}

- (void)writeData:(NSData *)data isError:(BOOL)error
{
    MinionWriteStream *writeStream  = [[MinionWriteStream alloc] init];
    writeStream.version             = FCGI_VERSION_1;
    writeStream.type                = error? FCGI_STDERR : FCGI_STDOUT;
    writeStream.identifier          = self.identifier;
    writeStream.contentLength       = data.length;
    writeStream.paddingLength       = 0;
    writeStream.data                = data;
    
    [self.socket writeData:writeStream.outputData withTimeout:-1 tag:0];
}

- (void)completeWithRequestStatus:(NSUInteger)status applicationStatus:(NSUInteger)appStatus
{
    MinionClosingStream *closeStream    = [[MinionClosingStream alloc] init];
    closeStream.version                 = FCGI_VERSION_1;
    closeStream.type                    = FCGI_END_REQUEST;
    closeStream.identifier              = self.identifier;
    closeStream.contentLength           = 8;
    closeStream.paddingLength           = 0;
    closeStream.requestStatus           = status;
    closeStream.applicationStatus       = appStatus;
    
    [self.socket writeData:closeStream.data withTimeout:-1 tag:0];
    
    if(self.keepConnection)
        [self.socket readDataToLength:MinionFixedPartLength withTimeout:MinionTimeout tag:MinionSocketWaitingForHeaderTag];
    else
        [self.socket disconnectAfterWriting];
}


@end
