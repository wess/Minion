//
//  MinionParams.h
//  Minion
//
//  Created by Wess Cope on 11/8/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinionStream.h"

@interface MinionParams : MinionStream
@property (readonly, nonatomic) NSDictionary *params;
@end
