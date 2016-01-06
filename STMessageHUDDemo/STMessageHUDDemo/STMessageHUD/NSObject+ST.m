//
//  NSObject+ST.m
//  STMessageHUDDemo
//
//  Created by https://github.com/STShenZhaoliang/STMessageHUD on 16/1/6.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "NSObject+ST.h"

@implementation NSObject (ST)


static id instance_;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

@end
