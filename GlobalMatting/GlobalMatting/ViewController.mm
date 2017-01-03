//
//  ViewController.m
//  GlobalMatting
//
//  Created by yang on 17/1/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ViewController.h"
#import "ImageItemView.h"
#import "GlobalMattingAPI.h"
#import "Utils.h"
#import <math.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ImageItemView *sImgV;
@property (nonatomic, strong) ImageItemView *tImgV;
@property (nonatomic, strong) ImageItemView *aImgV;
@property (nonatomic, strong) ImageItemView *fImgV;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *sliderText;
@property (weak, nonatomic) IBOutlet UILabel *memLabel;
@property (weak, nonatomic) IBOutlet UILabel *cpuLabel;

@end
#define scale 563.0/800
#define width self.view.frame.size.width
#define heght self.view.frame.size.height

#define kHeight ((self.view.frame.size.height - 20 - 10)/2)
#define kWidth (kHeight *800/563.0)
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    loadMatting();
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateSystemInfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self slider];
    [self change:self.slider];
}
- (UISlider *)slider
{
    if(!_slider)
    {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake((width - 160) /2, 5, 160, 20)];;
        _slider.minimumValue = 0;
        _slider.maximumValue = 50;
        _slider.value = 9;
        [self.view addSubview:_slider];
        [_slider addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)sliderText
{
    if(!_sliderText)
    {
        _sliderText = [[UILabel alloc] initWithFrame:CGRectMake((width - 160) /2 + 160 + 10, 5, 20, 20)];
        _sliderText.layer.borderColor = [UIColor grayColor].CGColor;
        _sliderText.layer.borderWidth = 1;
        _sliderText.layer.masksToBounds = YES;
        _sliderText.layer.cornerRadius = 10;
        _sliderText.textAlignment = NSTextAlignmentCenter;
        _sliderText.clipsToBounds = YES;
        _sliderText.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_sliderText];
    }
    return _sliderText;
}
- (void)change:(UISlider *)slider
{
    self.sliderText.text = [NSString stringWithFormat:@"%ld",(long)slider.value];
    
    self.sliderText.textColor = [UIColor colorWithRed:(abs(rand() + 100)%255)/255.0 green:(abs(rand() + 300)%255)/255.0 blue:(abs(rand() + 28)%255)/255.0 alpha:1];
}
- (void)updateSystemInfo
{
    self.memLabel.text = [NSString stringWithFormat:@"Mem:%.2fM",[Utils usedMemory]];
    self.cpuLabel.text = [NSString stringWithFormat:@"cpu:%ld%%100",(long)([Utils cpu_usage]*100)];
}
- (ImageItemView *)imageItemView
{
    ImageItemView *_srcImgV;
    _srcImgV = [[ImageItemView alloc] initWithFrame:CGRectZero];
    _srcImgV.layer.borderWidth = 1;
    _srcImgV.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_srcImgV];
    return _srcImgV;
}


- (ImageItemView *)sImgV
{
    if(!_sImgV)
    {
        _sImgV = self.imageItemView;
        _sImgV.frame = CGRectMake(0, 20,kWidth, kHeight);
        _sImgV.textLabel.text = @"输入：原始GT04.png";
    }
    return _sImgV;
}


- (ImageItemView *)tImgV
{
    if(!_tImgV)
    {
        _tImgV = self.imageItemView;
        _tImgV.frame = CGRectMake(width - kWidth, 20, kWidth,kHeight);
        _tImgV.textLabel.text = @"输入：matting-GT04_t.png";
    }
    return _tImgV;
}


- (ImageItemView *)aImgV
{
    if(!_aImgV)
    {
        _aImgV = self.imageItemView;
        _aImgV.frame = CGRectMake(0, kHeight + 10 + 20, kWidth, kHeight);
        _sImgV.textLabel.text = @"结果：alpha图";
    }
    return _aImgV;
}


- (ImageItemView *)fImgV
{
    if(!_fImgV)
    {
        _fImgV = self.imageItemView;
        _fImgV.frame = CGRectMake(width - kWidth, kHeight + 10 + 20, kWidth, kHeight);
        _fImgV.textLabel.text = @"结果：前景图";
    }
    return _fImgV;
}


- (IBAction)openAction:(id)sender {
    [self mattingProcess];
}


- (void)mattingProcess
{
    self.aImgV.image = nil;
    [self.aImgV startTimer];
    self.fImgV.image = nil;
    [self.fImgV startTimer];
    
    __weak typeof(self) weakself = self;
    self.sImgV.image = [UIImage imageNamed:@"GT04.png"];
    self.tImgV.image = [UIImage imageNamed:@"GT04_t.png"];
//    [self.sImgV startTimer];
//    [self.tImgV startTimer];
    [GlobalMattingAPI feedSrc:[[NSBundle mainBundle] pathForResource:@"GT04" ofType:@"png"] trimapPath:[[NSBundle mainBundle] pathForResource:@"GT04_t" ofType:@"png"] pixels:(int)self.slider.value response:^(UIImage *foreground, UIImage *alpha, BOOL isOk) {
        weakself.aImgV.image = alpha;
        weakself.fImgV.image = foreground;
        [weakself.sImgV stopTimer];
        [weakself.tImgV stopTimer];
        [weakself.aImgV stopTimer];
        [weakself.fImgV stopTimer];
        ;
        weakself.aImgV.bLabel.text = [NSString stringWithFormat:@"耗时:%lf ms",[[NSUserDefaults standardUserDefaults] doubleForKey:@"time"]];
        weakself.fImgV.bLabel.text = [NSString stringWithFormat:@"耗时:%lf ms",[[NSUserDefaults standardUserDefaults] doubleForKey:@"time"]];
        [weakself.aImgV layoutIfNeeded];
        [weakself.fImgV layoutIfNeeded];
    }];
}


- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}
@end
