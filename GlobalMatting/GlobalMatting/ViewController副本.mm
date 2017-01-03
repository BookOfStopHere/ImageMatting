//
//  ViewController.m
//  GlobalMatting
//
//  Created by yang on 17/1/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ViewController.h"
#import "ImageItemView.h"


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

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *srcImgV;
@property (nonatomic, strong) UIImageView *dstImgV;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    loadMatting();
}

- (UIImageView *)srcImgV
{
    if(!_srcImgV)
    {
        _srcImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - (self.view.bounds.size.width*180/320) , self.view.bounds.size.width, self.view.bounds.size.width*180/320)];
        _srcImgV.layer.borderWidth = 1;
        _srcImgV.contentMode = UIViewContentModeCenter;
        [self.view addSubview:_srcImgV];
        _srcImgV.userInteractionEnabled = YES;
        [_srcImgV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return _srcImgV;
}


- (UIImageView *)dstImgV
{
    if(!_dstImgV)
    {
        _dstImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,20,self.view.bounds.size.width,self.view.bounds.size.width * 180/320)];
        _dstImgV.layer.borderWidth = 1;
        _dstImgV.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:_dstImgV];
    }
    return _dstImgV;
}


- (IBAction)openAction:(id)sender {
    
    [self loadMatting:nil];return;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {
                    //第一次用户接受
                    [self openCamara];
                }else{
                    //用户拒绝
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            [self openCamara];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }

}

- (void)openCamara
{
    self.srcImgV.image = nil;
//    /先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
    //        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    }
    //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    picker.videoQuality = UIImagePickerControllerQualityTypeIFrame960x540;
     picker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
    CGFloat ratio = self.view.frame.size.width/image.size.width;

//    UIImage *result = [UIImage imageWithCGImage:image.CGImage scale:10 orientation:UIImageOrientationUp];
    UIImage *result = [self reSizeImage:image toSize:CGSizeMake(180, 320)];
    self.srcImgV.image = result;
    
//    CGImageRef imageRef = CGImageCreateWithImageInRect(result.CGImage, CGRectMake((self.view.frame.size.width - 100)/2, (self.view.frame.size.height - 200)/2, 100, 200));
//    self.srcImgV.image = result;//[UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark 处理

- (void)tap:(UITapGestureRecognizer *)tap
{
    if(self.srcImgV.image == nil) return;
    [self loadMatting:self.srcImgV.image];
}

- (void)loadMatting:(UIImage *)img
{
    
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"pattern" ofType:@"bmp"];
//    const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
//    cv::Mat img_object = imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
    
    
    
    //Creating Path to Documents-Directory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"ocv%03d.BMP", picNum]];
//    const char* cPath = [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
//    
//    const cv::string newPaths = (const cv::string)cPath;
//    
//    //Save as Bitmap to Documents-Directory
//    cv::imwrite(newPaths, frame);
    img = [UIImage imageNamed:@"GT04.png"];
    
//    cv::Mat image;
    cv::Mat image0(img.size.width, img.size.height, CV_8UC4);
    UIImageToMat(img,image0);
    cv::Mat image;
    cv::cvtColor(image0 , image , CV_RGBA2RGB);
    
//    img.CVMat; //cv::imread("GT04-image.png", CV_LOAD_IMAGE_COLOR);
    
    
    
    
    //    cv::Mat trimap(image.rows, image.cols, CV_8UC1);//大小与原图相同的八位单通道图
//    UIImage *trimpImage = [UIImage imageNamed:@"GT04_t.png"];
//    trimpImage = [self reSizeImage:trimpImage toSize:img.size];
//    cv::cvtColor(img.CVMat, trimap,CV_RGBA2GRAY);
//    self.dstImgV.image = [UIImage imageNamed:@"GT04_t.png"];
    
    
    
     cv::Mat trimap = cv::imread([[NSBundle mainBundle] pathForResource:@"GT04_t" ofType:@"png"].UTF8String,CV_LOAD_IMAGE_GRAYSCALE);
    self.dstImgV.image = MatToUIImage(trimap);

//////################################################################
//    UIImage *grayImg = [UIImage imageNamed:@"GT04_t.png"];
//    self.srcImgV.image = grayImg;
//    self.srcImgV.contentMode = UIViewContentModeScaleToFill;
//    cv::Mat matImage(grayImg.size.width, grayImg.size.height, CV_8UC4);
//    UIImageToMat(img,matImage);
////    self.dstImgV.image = MatToUIImage(matImage);
//    cv::Mat trimap;
//    
//    //5.cvtColor函数对matImage进行灰度处理
//    //取得IplImage形式的灰度图像
//    cv::cvtColor(matImage, trimap, CV_BGR2GRAY);// 转换成灰色
////    self.dstImgV.image = MatToUIImage(matImage);
//    return;
 //////################################################################
    
    
//    self.dstImgV.image = MatToUIImage(trimap);
//    cv::Mat trimap = [UIImage imageNamed:@"mm.jpg"].CVMat;//cv::imread("GT04-trimap.png", CV_LOAD_IMAGE_GRAYSCALE);
    
//    NSString *path0 = [[NSBundle mainBundle] pathForResource:@"GT04" ofType:@"png"];
//    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"GT04_t" ofType:@"png"];
    
    
//    cv::Mat image = cv::imread([path0 UTF8String], CV_LOAD_IMAGE_COLOR);
//    cv::Mat trimap = cv::imread([path1 UTF8String], CV_LOAD_IMAGE_GRAYSCALE);
    
    // (optional) exploit the affinity of neighboring pixels to reduce the
    // size of the unknown region. please refer to the paper
    // 'Shared Sampling for Real-Time Alpha Matting'.
    expansionOfKnownRegions(image, trimap, 9);
    
    cv::Mat foreground, alpha;
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
    self.dstImgV.image = MatToUIImage(alpha);
//    self.
}




- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}
@end
