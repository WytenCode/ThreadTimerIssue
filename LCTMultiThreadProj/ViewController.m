//
//  ViewController.m
//  LCTMultiThreadProj
//
//  Created by VladimirVK on 04.04.19.
//  Copyright © 2019 VladimirVK. All rights reserved.
//

#import "ViewController.h"
static const int MaxValue = 100000;


@interface ViewController ()

@property (nonatomic, assign) NSInteger secondsCounter;
@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) NSTimer *myTimer;

@end

@implementation ViewController

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 20)];
    self.myLabel.text = @"000";
    [self.view addSubview:_myLabel];
    
    // задача с таймером, который не запускался
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(countTime) object:nil];
    [thread start];

    [self performSelectorInBackground:@selector(doSomeStuff) withObject:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)countTime
{
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    NSRunLoop *myRL = [NSRunLoop currentRunLoop];
    [myRL addTimer:_myTimer forMode:NSRunLoopCommonModes];
    while ([myRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

-(void)incrementTimer
{
    self.secondsCounter++;
    [self performSelectorOnMainThread:@selector(refreshLabel) withObject:nil waitUntilDone:NO];
}

-(void)refreshLabel
{
    if (self.secondsCounter < 10)
    {
        self.myLabel.text = [NSString stringWithFormat:@"00%ld", (long)self.secondsCounter];
    }
    else if (self.secondsCounter < 100)
    {
        self.myLabel.text = [NSString stringWithFormat:@"0%ld", (long)self.secondsCounter];
    }
    else
    {
        self.myLabel.text = [NSString stringWithFormat:@"%ld", (long)self.secondsCounter];
    }
    
    if (self.secondsCounter == 5)
    {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}


-(void)doSomeStuff
{
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animationSomething];
        });
    }
    for (int i=0; i < MaxValue; i++)
    {
        NSLog(@"Value - %d", i);
    }
    
    
}

- (void)doSomeDeadLockStuff
{
    dispatch_queue_t deadLockExampleQueue = dispatch_queue_create("deadlock queue", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"1");
    dispatch_async(deadLockExampleQueue, ^{
        NSLog(@"2");
        dispatch_sync(deadLockExampleQueue, ^{
            NSLog(@"3");
            // Внешний блок ожидает завершения внутреннего блока,
            // Внутренний блок не стартанет, пока не завершится внешний
            // => deadlock
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

#pragma mark - UI

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([NSThread isMainThread])
    {
        NSLog(@"Главный поток");
    }
    else
    {
        NSLog(@"Не-не-не");
    }
    // определяем координату нажатия
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    // берем пропорцию
    CGFloat colorPoint = point.x/CGRectGetWidth(self.view.frame);
    // устанавливаем цвет
    self.view.backgroundColor = [UIColor colorWithRed:colorPoint green:colorPoint blue:colorPoint alpha:1.0];
}

-(void)animationSomething
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    [UIView animateWithDuration:5.0 animations:^{
        view.frame = CGRectMake(100, 100, 500, 800);
    }completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
