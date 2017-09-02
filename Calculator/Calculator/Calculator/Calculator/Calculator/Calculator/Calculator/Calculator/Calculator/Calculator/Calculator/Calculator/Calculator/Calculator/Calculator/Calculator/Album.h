//
//  Album.h
//  Calculator
//
//  Created by Kumangus on 2013/12/12.
//  Copyright (c) 2013年 Kumangus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Album : NSManagedObject

@property (nonatomic) NSString * albumName;
@property (nonatomic) double seq;
@property (nonatomic) NSString * folder;

@end
