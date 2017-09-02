//
//  PageContentViewController.h
//  Calculator
//
//  Created by Kumangus on 2013/12/29.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
