//
//  MinionIncomingStream.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinionStream.h"

@interface MinionIncomingStream : MinionStream
@property (assign, nonatomic) NSUInteger role;
@property (assign, nonatomic) NSUInteger flags;
@end
