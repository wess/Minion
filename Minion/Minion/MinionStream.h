//
//  MinionStream.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinionStream : NSObject
@property (assign, nonatomic) NSUInteger    version;
@property (assign, nonatomic) NSUInteger    type;
@property (assign, nonatomic) NSUInteger    identifier;
@property (assign, nonatomic) NSUInteger    contentLength;
@property (assign, nonatomic) NSUInteger    paddingLength;
@property (readonly, nonatomic) NSData      *headerData;

+ (instancetype)streamWithHeaderData:(NSData *)data;
- (void)processContentData:(NSData *)data;

@end
