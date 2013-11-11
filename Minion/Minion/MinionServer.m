//
//  MinionServer.m
//  Minion
//
//  Created by Wess Cope on 11/8/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionServer.h"
#import "GCDAsyncSocket.h"
#import "MinionStream.h"
#import "MinionIncomingStream.h"
#import "MinionWriteStream.h"
#import "MinionClosingStream.h"
#import "MinionRequest.h"
#import "MinionParams.h"

@interface MinionServer()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) NSMutableArray        *sockets;
@property (strong, nonatomic) NSMutableDictionary   *requests;
@property (strong, nonatomic) GCDAsyncSocket        *listeningSocket;
@property (nonatomic) NSUInteger                    port;
@property (nonatomic) dispatch_queue_t              queue;
@end

@implementation MinionServer
@synthesize isRunning   = _isRunning;
@synthesize requests    = _requests;

- (instancetype)initWithPort:(NSUInteger)port
{
    self = [super init];
    if(self)
    {
        self.port               = port;
        self.queue              = dispatch_queue_create("minion.socket.accept.queue", NULL);
        self.sockets            = [[NSMutableArray alloc] init];
        self.requests           = [[NSMutableDictionary alloc] init];
        self.listeningSocket    = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
        
        _isRunning = NO;
    }
    return self;
}

- (BOOL)start:(__autoreleasing NSError **)error
{
    if([self.listeningSocket acceptOnPort:self.port error:error])
    {
        NSLog(@"Server has started");
        _isRunning = YES;
        return YES;
    }

    return NO;
}

- (void)stop
{

}

- (void)processStream:(MinionStream *)stream fromSocket:(GCDAsyncSocket *)socket
{
    NSString *identifier = [NSString stringWithFormat:@"%ld.%d", stream.identifier, socket.connectedPort];

    NSLog(@"Processing Stream: %@", identifier);
    
    if([stream isKindOfClass:[MinionIncomingStream class]])
    {
        MinionIncomingStream *incomingStream    = (MinionIncomingStream *)stream;
        MinionRequest *request                  = [[MinionRequest alloc] initWithIncoming:incomingStream onSocket:socket];
        
        @synchronized(_requests)
        {
            _requests[identifier] = request;
        }
        
        [socket readDataToLength:MinionFixedPartLength withTimeout:MinionTimeout tag:MinionSocketWaitingForHeaderTag];
    }
    else if([stream isKindOfClass:[MinionParams class]])
    {
        MinionRequest *request;
        @synchronized(_requests)
        {
            request = [_requests objectForKey:identifier];
        }
        
        MinionParams *paramsStream  = (MinionParams *)stream;
        NSDictionary *params        = paramsStream.params;
        
        if(params.count > 0)
        {
            NSMutableDictionary *mutableParams = [request.parameters mutableCopy];
            [mutableParams addEntriesFromDictionary:params];
            
            request.parameters = [mutableParams copy];
        }
        else
        {
            if(self.paramsHandler)
                self.paramsHandler(request);
        }
        
        [socket readDataToLength:MinionFixedPartLength withTimeout:MinionTimeout tag:MinionSocketWaitingForHeaderTag];
    }
    else if([stream isKindOfClass:[MinionWriteStream class]])
    {
        MinionRequest *request;
        @synchronized(_requests)
        {
            request = [_requests objectForKey:identifier];
        }
        
        MinionWriteStream *writeStream = (MinionWriteStream *)stream;
        [request appendIncomingData:writeStream.data];
        
        if(self.incomingHandler)
            self.incomingHandler(request);
        
        @synchronized(_requests)
        {
            [_requests removeObjectForKey:identifier];
        }
    }
}

#pragma mark - GCDAsyncSocket Delegate -

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepting new socket");
    
    NSString *queueName     = [NSString stringWithFormat:@"minion.accept.on.%d.queue", newSocket.connectedPort];
    dispatch_queue_t queue  = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    
    [newSocket setDelegateQueue:queue];
    
    @synchronized(_sockets)
    {
        [_sockets addObject:newSocket];
    }
    
    [newSocket readDataToLength:MinionFixedPartLength withTimeout:MinionTimeout tag:MinionSocketWaitingForHeaderTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Did Disconnect");
    @synchronized(_sockets)
    {
        [_sockets removeObject:sock];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Did Read Data");
    
    if(tag == MinionSocketWaitingForHeaderTag)
    {
        MinionStream *stream = [MinionStream streamWithHeaderData:data];
        
        if(stream.contentLength > 0)
        {
            dispatch_set_context(sock.delegateQueue, (__bridge void *)(stream));
            [sock readDataToLength:(stream.contentLength + stream.paddingLength)  withTimeout:MinionTimeout tag:MinionSocketWaitingForContentAndPaddingTag];
        }
        else
        {
            [self processStream:stream fromSocket:sock];
        }
    }
    else if(tag == MinionSocketWaitingForContentAndPaddingTag)
    {
        MinionStream *stream = (__bridge MinionStream *)dispatch_get_context(sock.delegateQueue);
        
        [stream processContentData:data];
        [self processStream:stream fromSocket:sock];
    }
}

@end









