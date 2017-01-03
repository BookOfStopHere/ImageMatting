//
//  ImageItemView.h
//  GlobalMatting
//
//  Created by 1 on 17/1/2.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageItemView : UIImageView
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *timeLabel;


@property (nonatomic, strong) UILabel *bLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

- (void)startTimer;

- (void)stopTimer;

@end
