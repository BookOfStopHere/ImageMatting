//
//  ImageItemView.m
//  GlobalMatting
//
//  Created by 1 on 17/1/2.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ImageItemView.h"
#include <math.h>
@implementation ImageItemView
{
    double initTime;
}
@synthesize timer;
- (UILabel *)textLabel
{
    if(!_textLabel)
    {
        _textLabel = UILabel.new;
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (UILabel *)bLabel
{
    if(!_bLabel)
    {
        _bLabel = UILabel.new;
        _bLabel.font = [UIFont systemFontOfSize:13];
        _bLabel.textColor = [UIColor whiteColor];
        _bLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
        _bLabel.layer.borderWidth = 1;
//        _bLabel.layer.borderColor = UIColor 
        [self addSubview:_bLabel];
    }
    return _bLabel;
}

- (UILabel *)timeLabel
{
    if(!_timeLabel)
    {
        _timeLabel = UILabel.new;
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
//        _timeLabel.text = [NSString stringWithFormat:@"00分:00秒"];
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (void)startTimer
{
    if(timer)
    {
        dispatch_source_cancel(timer);
        timer = nil;
    }
    [self.loadingView startAnimating];
    __weak typeof(self) weakself = self;
    self.timeLabel.text = [NSString stringWithFormat:@"00分:00秒"];
    initTime = CFAbsoluteTimeGetCurrent();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(),^{
            [weakself updateTime];
        });
    });
    dispatch_resume(timer);
    [self setNeedsLayout];
}

- (NSString *)calTimer
{
    double kk = (CFAbsoluteTimeGetCurrent() - initTime);
    long m = (long)(floor(kk) /(60));
    long s = (kk - m * 60);
    return [NSString stringWithFormat:@"%02ld分:%02ld秒",m,s];
}


- (void)updateTime
{
    self.timeLabel.text = [self calTimer];
    [self setNeedsLayout];
}

- (void)stopTimer
{
    if(timer)
    {
        dispatch_source_cancel(timer);
        timer = nil;
    }
    [self setNeedsLayout];
    [self.loadingView stopAnimating];
}


- (UIActivityIndicatorView *)loadingView
{
     if(!_loadingView)
     {
         _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
         _loadingView.color = [UIColor greenColor];
         [self addSubview:_loadingView];
     }
    return _loadingView;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [_textLabel sizeToFit];
    _textLabel.frame = CGRectMake(5, 0, _textLabel.frame.size.width, _textLabel.frame.size.height);
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(self.bounds.size.width - _timeLabel.frame.size.width - 5, 0, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    [_bLabel sizeToFit];
    _bLabel.frame = CGRectMake((self.bounds.size.width - _bLabel.frame.size.width)/2, (self.bounds.size.height - _bLabel.frame.size.height -10), _bLabel.frame.size.width, _bLabel.frame.size.height);
    _bLabel.layer.cornerRadius = 3;
    _bLabel.clipsToBounds = YES;
    if(self.loadingView.isAnimating)
    {
        self.loadingView.frame = CGRectMake((self.bounds.size.width - 50)/2, (self.bounds.size.height - 50)/2, 50, 50);
    }
}
@end
