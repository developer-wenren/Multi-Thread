//
//  WRDownloadOperation.m
//  Multi-Thread
//
//  Created by zjsruxxxy3 on 15/4/22.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import "WRDownloadOperation.h"

@implementation WRDownloadOperation

-(void)main
{
    
    @autoreleasepool {
        
        
        if (self.isCancelled) return;
        // initialize code
        if (self.url)
        {
            NSData *data = [NSData dataWithContentsOfURL:self.url];
            if (self.isCancelled) return;
            
            
        }else
        {
            if (self.isCancelled) return;
            NSLog(@"had donw");

        }
        
        if (self.completionHandle)
        {
            if (self.isCancelled) return;
            self.completionHandle();
            
        }
        
        [super main];

    }
    
}
@end
