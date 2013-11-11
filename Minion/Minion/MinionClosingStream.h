//
//  MinionClosingStream.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinionStream.h"

@interface MinionClosingStream : MinionStream
@property (assign, nonatomic) NSUInteger applicationStatus;
@property (assign, nonatomic) NSUInteger requestStatus;
@property (readonly, nonatomic) NSData   *data;
@end
