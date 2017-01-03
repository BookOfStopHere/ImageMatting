//
//  Utils.h
//  GlobalMatting
//
//  Created by 1 on 17/1/2.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+ (float)cpu_usage;
+ (double)totalMemory;
// 获取当前设备可用内存(单位：MB）
+ (double)availableMemory;
// 获取当前任务所占用的内存（单位：MB）
+ (double)usedMemory;
@end
