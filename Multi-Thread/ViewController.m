//
//  ViewController.m
//  Multi-Thread
//
//  Created by zjsruxxxy3 on 15/4/20.
//  Copyright (c) 2015年 WR. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import "WRDownloadOperation.h"
@interface ViewController ()

@property(nonatomic,weak)IBOutlet UIImageView *imageView;

@property(nonatomic,weak)IBOutlet UIImageView *subImageViewA;

@property(nonatomic,weak)IBOutlet UIImageView *subImageViewB;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@-%f",[NSThread currentThread],[NSThread threadPriority]);//mianThreadPriority-.75,default-.5;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.subImageViewA.contentMode = UIViewContentModeScaleToFill;
    self.subImageViewB.contentMode = UIViewContentModeScaleToFill;
    
//    [self pthreadFunc];
//    [self NSThreadFunc];
//    [self GCDFunc];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self imaegLoadAsync];
    
//    [self intervalRun];
    
//    [self onlyRunOnce];
    
//    [self imaegLoadUsingQueueGroup];
    
//    [self operationFunc];
    
    [self downloadOperation];
    
}

#pragma mark WRDownloadOperation
-(void)downloadOperation
{
    WRDownloadOperation *downloadOper = [[WRDownloadOperation alloc]init];
    
    downloadOper.completionHandle=^(){
        
        dispatch_async(dispatch_get_main_queue(), ^{

            // update UI
            NSLog(@"%@--downloadOper",[NSThread currentThread]);

        });
        
    };
    
    downloadOper.completionBlock=^()
    {
        NSLog(@"%@--completionBlock",[NSThread currentThread]);
    };
    
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [queue addOperation:downloadOper];
    
}

#pragma mark NSOperation
-(void)operationFunc
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSBlockOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@---operationA-",[NSThread currentThread]);
        
    }];
    
    NSBlockOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@---operationB-",[NSThread currentThread]);
        
    }];
    
    [operationA addExecutionBlock:^{
        NSLog(@"%@---operationA-2",[NSThread currentThread]);

    }];
    
//    [operationA start];
//    [operationB start];
    queue.maxConcurrentOperationCount = 3;
    
    [operationB addDependency:operationA];
    // 顺序未知，除非通过依赖
    [queue addOperation:operationA];
    [queue addOperation:operationB];
    
    
}

#pragma mark 图片的异步加载
-(void)imaegLoadAsync
{
    NSURL *picURL = [NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D310/sign=921e59c0f9f2b211e42e834ffa816511/77c6a7efce1b9d167fdca5d2f1deb48f8c54646d.jpg"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 回到主线程显示pic
    dispatch_async(queue, ^{
        NSLog(@"%@---",[NSThread currentThread]);
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:picURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            NSLog(@"%@---",[NSThread currentThread]);
        
        });
        
    });
}

//函数名含有create,new,retain,copy 字眼需要release(在MRC中)
//(CF)CoreFoundation 在ARCx下也需要release

#pragma mark NSThread
-(void)NSThreadFunc
{
    
    /**
     *  同步锁(onlyOne)
     */
    @synchronized(self){
            //code;
    }
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(makeNewThread:) object:@"wrcj"];
    thread.name = @"wrcj";
    [thread setThreadPriority:.8];
    
    [thread start];
    
    NSThread *threadB = [[NSThread alloc]initWithTarget:self selector:@selector(makeNewThread:) object:@"wrcj2"];
    threadB.name = @"wrcj2";
    [threadB setThreadPriority:.8];
    
    [threadB start];

    //[NSThread detachNewThreadSelector:@selector(makeNewThread:) toTarget:self withObject:@"haha"];
    
    // 后台执行 ===（恒等于） 子线程执行
    //[self performSelectorInBackground:@selector(makeNewThread:) withObject:@"lili"];
}
-(void)makeNewThread:(NSString *)obj
{
    NSLog(@"%@-%@--%f",[NSThread currentThread],obj,[NSThread threadPriority]);
}

#pragma mark pthread  inclue lib&header files
-(void)pthreadFunc
{
    pthread_t x;
    
    pthread_create(&x, Nil, run, Nil);
    
}
/**
 *  带函数指针参数的函数
 *
 *  @param data 函数指针参数
 *
 *  @return void 返回NIl-NULL
 */
void *run(void *data)
{
    
    NSLog(@"%@",[NSThread currentThread]);
    
    return Nil;
    
}

#pragma mark GCD
-(void)GCDFunc
{
    // 全局并行队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    dispatch_async(globalQueue, ^{
        
        NSLog(@"%@-dispatch_async",[NSThread currentThread]);
        
    });
    
    dispatch_sync(globalQueue, ^{
        NSLog(@"%@-dispatch_sync",[NSThread currentThread]);
        
    });
    
    // 串行队列
    dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", Nil);
    
    dispatch_async(serial_queue, ^{
        
        NSLog(@"%@-dispatch_async-serial_queue",[NSThread currentThread]);
        
    });
    
    dispatch_async(serial_queue, ^{
        
        NSLog(@"%@-dispatch_async-serial_queue222",[NSThread currentThread]);
        
    });
    
    dispatch_sync(serial_queue, ^{
        NSLog(@"%@-dispatch_sync-serial_queue",[NSThread currentThread]);
        
    });
    
    //串行主队列(不会创子线程)
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    
#warning 主队列的异步执行（特殊情况）
    //在主线程中异步，等待执行
    dispatch_async(main_queue, ^{
        NSLog(@"%@-dispatch_sync-main_queue",[NSThread currentThread]);
        
    });
    
#warning 死循环(死锁)
    /*
     队列:先进先出，串行:后面的等前面执行完才能执行
     dispatch_sync(main_queue, ^{
     NSLog(@"%@-dispatch_sync-main_queue",[NSThread currentThread]);
     });
     */
    
    
}

#pragma mark GCD扩展
-(void)intervalRun
{
    // 主线程延时操作
    [self performSelector:@selector(run2) withObject:nil afterDelay:5.0];
    
    //格式一定要一致
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
    
    // 创建线程延时操作
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self run2];
    });
    
    
    

}

-(void)onlyRunOnce
{
    // 单例专用
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"%s",__func__);
        
    });
}
-(void)run2
{
    NSLog(@"%@------run2",[NSThread currentThread]);
}

-(void)imaegLoadUsingQueueGroup
{
     dispatch_group_t group = dispatch_group_create();
    
    __block UIImage *image1 = nil;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
        NSURL *url = [NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D310/sign=921e59c0f9f2b211e42e834ffa816511/77c6a7efce1b9d167fdca5d2f1deb48f8c54646d.jpg"];
        image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        NSLog(@"%@-dispatch_async-",[NSThread currentThread]);

    });
    
    
    __block UIImage *image2 = nil;
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D310/sign=921e59c0f9f2b211e42e834ffa816511/77c6a7efce1b9d167fdca5d2f1deb48f8c54646d.jpg"]]];
        NSLog(@"%@-dispatch_async-",[NSThread currentThread]);

    });
    
    dispatch_group_notify(group, mainQueue, ^{
        
        self.subImageViewA.image = image1;
        self.subImageViewB.image = image2;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(500,200), NO, 0.0);
        [image1 drawInRect:CGRectMake(0, 0, 250, 200)];
        [image2 drawInRect:CGRectMake(250, 0, 250, 200)];
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    });



    
}

@end
