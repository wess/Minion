//
//  main.m
//  MinionExample
//
//  Created by Wess Cope on 11/7/13.
//  Copyright (c) 2013 Nudge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Minion/Minion.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool
    {
        MinionServer *server = [[MinionServer alloc] initWithPort:8000];
        
        server.paramsHandler = ^(MinionRequest *request) {
            NSLog(@"PARAMS: %@", request.parameters);
        };
        
        server.incomingHandler = ^(MinionRequest *request) {

            NSString *headers   = @"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 8\r\n\r\nHello World";
            NSData *headersData = [headers dataUsingEncoding:NSASCIIStringEncoding];
            NSString *content   = @"Hello World";
            NSData *contentData = [content dataUsingEncoding:NSASCIIStringEncoding];
            
            [request writeData:headersData isError:NO];
            [request writeData:contentData isError:NO];
            [request completeWithRequestStatus:FCGI_REQUEST_COMPLETE applicationStatus:0];
        };
        
        NSError *error = nil;
        
        [server start:&error];
        
        if(error)
            NSLog(@"ERROR: %@", error);
    }
    
    dispatch_main();
    return 0;
}

