//
//  MinionWriteStream.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinionStream.h"

@interface MinionWriteStream : MinionStream
@property (strong, nonatomic) NSData    *data;
@property (readonly, nonatomic) NSData  *outputData;

- (void)processContentData:(NSData *)data;

@end
