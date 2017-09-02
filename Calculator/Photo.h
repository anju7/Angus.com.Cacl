//
//  Photo.h
//  Calculator
//
//  Created by Kumangus on 2013/12/19.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoName;
@property (nonatomic) double seq;

@end
