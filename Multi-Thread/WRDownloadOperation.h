//
//  WRDownloadOperation.h
//  Multi-Thread
//
//  Created by zjsruxxxy3 on 15/4/22.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRDownloadOperation : NSOperation

@property(nonatomic,strong)NSURL *url;

@property(nonatomic,copy)void(^completionHandle)();

@end
