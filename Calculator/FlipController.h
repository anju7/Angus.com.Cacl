//
//  FlipController.h
//  CustomTransition
//
//  Created by chronoer on 13/10/16.
//  Copyright (c) 2013年 Zencher Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlipController : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL reverse;
@end
