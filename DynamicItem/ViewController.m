//
//  ViewController.m
//  DynamicItem
//
//  Created by 张奥 on 2019/10/17.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#define SCREEN_Width [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height [UIScreen mainScreen].bounds.size.height
static NSString * const buttonKey = @"buttonKey";

@interface ViewController ()<UIScrollViewDelegate>{
    NSArray    * _dataSources;
    NSMutableArray     * _buttons;
}
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat startCenter_X;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _buttons = [NSMutableArray array];
    _dataSources = @[@"一星",@"二星",@"三星",@"四星",@"五星",@"六星",@"七星",@"八星"];
    
    [self createItem];
    [self creaScrollView];
}


-(UIView*)redView{
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.backgroundColor = [UIColor redColor];
        _redView.bounds = CGRectMake(0, 0, 20, 4);
    }
    return _redView;
}

-(void)createItem{
    
    for (int i=0; i<_dataSources.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor purpleColor];
        button.frame = CGRectMake(i%_dataSources.count*(SCREEN_Width/_dataSources.count), 20, SCREEN_Width/_dataSources.count, 40);
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_dataSources[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
        [self.view addSubview:button];
        [_buttons addObject:button];
        objc_setAssociatedObject(button, &buttonKey, @(i), OBJC_ASSOCIATION_ASSIGN);
        
        if (i == 0) {
            self.redView.center = CGPointMake(button.center.x, CGRectGetMaxY(button.frame) - 3);
            self.startCenter_X = self.redView.center.x;
            self.selectBtn = button;
            self.scale = CGRectGetWidth(button.frame)/SCREEN_Width;
            button.selected = YES;
        }
    }
    
    [self.view addSubview:_redView];
}

-(void)creaScrollView{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_Width, SCREEN_Height - 64)];
    scrollView.backgroundColor = [UIColor greenColor];
    scrollView.pagingEnabled = YES;
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(_dataSources.count*SCREEN_Width, 0);
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat x = scrollView.contentOffset.x*self.scale;
    self.redView.center = CGPointMake(self.startCenter_X+x, self.redView.center.y);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offSet = scrollView.contentOffset.x/SCREEN_Width;
    NSInteger index = (NSInteger)ceilf(offSet);
    UIButton *button = _buttons[index];
    if (self.selectBtn == button) {
        return;
    }
    button.selected = YES;
    self.selectBtn.selected = NO;
    self.selectBtn = button;
}


-(void)clickButton:(UIButton*)button{
    if (self.selectBtn == button) {
        return;
    }
    NSInteger index = [objc_getAssociatedObject(button, &buttonKey) integerValue];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.redView.center = CGPointMake(button.center.x, self.redView.center.y);
        
    } completion:^(BOOL finished) {
        button.selected = YES;
        self.selectBtn.selected = NO;
        self.selectBtn = button;
        self.scrollView.contentOffset = CGPointMake(index*SCREEN_Width, 0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
