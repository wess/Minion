//
//  MinionParams.m
//  Minion
//
//  Created by Wess Cope on 11/8/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import "MinionParams.h"

@interface MinionParams()
@property (strong, nonatomic) NSMutableDictionary *mutableParams;
@end

@implementation MinionParams

- (id)init
{
    self = [super init];
    if (self)
    {
        self.mutableParams = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)description
{
    NSString *superDescription = [super description];
    return [NSString stringWithFormat:@"Params: %@, %@", self.params, superDescription];
}

- (NSDictionary *)params
{
    return [self.mutableParams copy];
}

- (void)processContentData:(NSData *)data
{
    uint8 pos[3];
    uint8 valuePos[4];
    uint8 namePos[4];
    NSUInteger nameLength;
    NSUInteger valueLength;
    
    NSMutableData *mutableData = [[data subdataWithRange:NSMakeRange(0, self.contentLength)] mutableCopy];
    
    while(mutableData.length > 0)
    {
        [mutableData getBytes:&pos[0] range:NSMakeRange(0, 1)];
        [mutableData getBytes:&pos[1] range:NSMakeRange(1, 1)];
        [mutableData getBytes:&pos[2] range:NSMakeRange(4, 1)];
        
        if(pos[0] >> 7 == 0)
        {
            nameLength = pos[0];
            
            if(pos[1] >> 7 == 0)
            {
                valueLength = pos[1];
                
                [mutableData replaceBytesInRange:NSMakeRange(0, 2) withBytes:NULL length:0];
            }
            else
            {
                [mutableData getBytes:&valuePos[3] range:NSMakeRange(1, 1)];
                [mutableData getBytes:&valuePos[2] range:NSMakeRange(2, 1)];
                [mutableData getBytes:&valuePos[1] range:NSMakeRange(3, 1)];
                [mutableData getBytes:&valuePos[0] range:NSMakeRange(4, 1)];
                
                valueLength = ((valuePos[3] & 0x7f) << 24) + (valuePos[2] << 16) + (valuePos[1] << 8) + valuePos[0];
                
                [mutableData replaceBytesInRange:NSMakeRange(0, 5) withBytes:NULL length:0];
            }
        }
        else
        {
            [mutableData getBytes:&namePos[3] range:NSMakeRange(0, 1)];
            [mutableData getBytes:&namePos[2] range:NSMakeRange(1, 1)];
            [mutableData getBytes:&namePos[1] range:NSMakeRange(2, 1)];
            [mutableData getBytes:&namePos[0] range:NSMakeRange(3, 1)];
            
            nameLength = ((namePos[3] & 0x7f) << 24) + (namePos[2] << 16) + (namePos[1] << 8) + namePos[0];
            
            if(pos[2] >> 7 == 0)
            {
                valueLength = pos[2];
                
                [mutableData replaceBytesInRange:NSMakeRange(0, 5) withBytes:NULL length:0];
            }
            else
            {
                [mutableData getBytes:&valuePos[3] range:NSMakeRange(4, 1)];
                [mutableData getBytes:&valuePos[2] range:NSMakeRange(5, 1)];
                [mutableData getBytes:&valuePos[1] range:NSMakeRange(6, 1)];
                [mutableData getBytes:&valuePos[0] range:NSMakeRange(7, 1)];
                
                valueLength = ((valuePos[3] & 0x7f) << 24) + (valuePos[2] << 16) + (valuePos[1] << 8) + valuePos[0];
                
                [mutableData replaceBytesInRange:NSMakeRange(0,8) withBytes:NULL length:0];
            }
        }
        
        NSData *nameData    = [mutableData subdataWithRange:NSMakeRange(0, nameLength)];
        NSString *name      = [[NSString alloc] initWithData:nameData encoding:NSASCIIStringEncoding];
        
        NSData *valueData   = [mutableData subdataWithRange:NSMakeRange(0, valueLength)];
        NSString *value     = [[NSString alloc] initWithData:valueData encoding:NSASCIIStringEncoding];
        
        self.mutableParams[[name copy]] = [value copy];
    }
}

@end
