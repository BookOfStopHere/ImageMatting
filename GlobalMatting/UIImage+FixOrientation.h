//
//  UIImage+FixOrientation.h
//  GlobalMatting
//
//  Created by 1 on 17/1/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
using namespace cv;

@interface UIImage (FixOrientation)
-(cv::Mat)CVMat;
@end
