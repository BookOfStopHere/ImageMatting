//
//  GlobalMattingAPI.h
//  GlobalMatting
//
//  Created by 1 on 17/1/2.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GlobalMattingAPI : NSObject

+ (void)feedSrc:(NSString *)path trimapPath:(NSString *)tpath pixels:(int)p response:(void(^)(UIImage *foreground,UIImage *alpha, BOOL isOk))response;

@end
