//
//  MinionWriteStream.h
//  Minion
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionWriteStream.h"
#import "MinionConstants.h"

@implementation MinionWriteStream

- (NSString *)description
{
    NSString *superDescription = [super description];
    
    return [NSString stringWithFormat:@"Stdin Stream with data: %@, %@ ", self.data, superDescription];
}

- (void)processContentData:(NSData *)data
{
    self.data = [data subdataWithRange:NSMakeRange(0, self.contentLength)];
}

- (NSData *)outputData
{
    NSMutableData *data = [NSMutableData dataWithCapacity:MinionDataCapacity];
    [data appendData:self.headerData];
    [data appendData:self.data];
    
    return [data copy];
}

@end
