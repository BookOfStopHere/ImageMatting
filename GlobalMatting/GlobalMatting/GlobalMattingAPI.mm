//
//  GlobalMattingAPI.m
//  GlobalMatting
//
//  Created by 1 on 17/1/2.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "GlobalMattingAPI.h"
#import <opencv2/opencv.hpp>
#import <AVFoundation/AVFoundation.h>
//#include <cv.h>
//#include <highgui.h>
#include "globalmatting.h"
// you can get the guided filter implementation
// from https://github.com/atilimcetin/guided-filter
#include "guidedfilter.h"
#import "UIImage+FixOrientation.h"
#include <opencv2/highgui/ios.h>

using namespace cv;


@implementation GlobalMattingAPI

+(dispatch_queue_t)queue
{
    static dispatch_queue_t one;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        one = dispatch_queue_create("global.matting", DISPATCH_QUEUE_CONCURRENT);
    });
    return one;
}

+ (void)feedSrc:(NSString *)path trimapPath:(NSString *)tpath pixels:(int)p response:(void(^)(UIImage *foreground,UIImage *alpha, BOOL isOk))response
{
    dispatch_async(self.queue, ^{
        [self loadSrc:path trimapPath:tpath pixels:p response:^(UIImage *foreground, UIImage *alpha, BOOL isOk) {
            dispatch_async(dispatch_get_main_queue(), ^{
                response(foreground,alpha,YES);
            });
        }];
    });
}

+ (void)loadSrc:(NSString *)path trimapPath:(NSString *)tpath pixels:(int)p response:(void(^)(UIImage *foreground,UIImage *alpha, BOOL isOk))response
{
//    cv::Mat image = cv::imread(path.UTF8String,CV_LOAD_IMAGE_COLOR);
    
    
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    
    //    cv::Mat image;
    cv::Mat image0(img.size.width, img.size.height, CV_8UC4);
    UIImageToMat(img,image0);
    cv::Mat image;
    cv::cvtColor(image0 , image , CV_RGBA2RGB);
    
    cv::Mat trimap = cv::imread(tpath.UTF8String,CV_LOAD_IMAGE_GRAYSCALE);
    //    cv::Mat image = cv::imread([path0 UTF8String], CV_LOAD_IMAGE_COLOR);
    //    cv::Mat trimap = cv::imread([path1 UTF8String], CV_LOAD_IMAGE_GRAYSCALE);
    
    // (optional) exploit the affinity of neighboring pixels to reduce the
    // size of the unknown region. please refer to the paper
    // 'Shared Sampling for Real-Time Alpha Matting'.
    expansionOfKnownRegions(image, trimap, p);
    
    cv::Mat foreground, alpha;
    double cu = CFAbsoluteTimeGetCurrent()*1000;
    globalMatting(image, trimap, foreground, alpha);
    
    // filter the result with fast guided filter
    alpha = guidedFilter(image, alpha, 10, 1e-5);
    for (int x = 0; x < trimap.cols; ++x)
        for (int y = 0; y < trimap.rows; ++y)
        {
            if (trimap.at<uchar>(y, x) == 0)
                alpha.at<uchar>(y, x) = 0;
            else if (trimap.at<uchar>(y, x) == 255)
                alpha.at<uchar>(y, x) = 255;
        }
    double end = CFAbsoluteTimeGetCurrent()*1000;
    [[NSUserDefaults standardUserDefaults] setDouble:end - cu forKey:@"time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    response (MatToUIImage(foreground),MatToUIImage(alpha),YES);
}
@end
