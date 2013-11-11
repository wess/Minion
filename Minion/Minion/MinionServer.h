//
//  MinionServer.h
//  Minion
//
//  Created by Wess Cope on 11/8/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinionConstants.h"

@class MinionStream, GCDAsyncSocket;

@interface MinionServer : NSObject
@property (readonly, nonatomic) BOOL isRunning;
@property (copy, nonatomic) MinionRequestHandler paramsHandler;
@property (copy, nonatomic) MinionRequestHandler incomingHandler;

- (instancetype)initWithPort:(NSUInteger)port;
- (BOOL)start:(__autoreleasing NSError **)error;
- (void)stop;
- (void)processStream:(MinionStream *)stream fromSocket:(GCDAsyncSocket *)socket;
@end
