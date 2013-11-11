//
//  MinionRequest.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MinionIncomingStream, GCDAsyncSocket;

@interface MinionRequest : NSObject
@property (assign, nonatomic) NSUInteger    identifier;
@property (assign, nonatomic) NSUInteger    role;
@property (assign, nonatomic) BOOL          keepConnection;
@property (strong, nonatomic) NSDictionary  *parameters;

- (instancetype)initWithIncoming:(MinionIncomingStream *)incomingStream onSocket:(GCDAsyncSocket *)socket;
- (void)writeData:(NSData *)data isError:(BOOL)error;
- (void)completeWithRequestStatus:(NSUInteger)status applicationStatus:(NSUInteger)appStatus;
- (void)appendIncomingData:(NSData *)data;

@end
