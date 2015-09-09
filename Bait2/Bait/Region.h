//
//  Region.h
//  Bait
//
//  Created by Stephen Blair on 9/4/15.
//  Copyright (c) 2015 Stephen Blair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * xCoordinate;
@property (nonatomic, retain) NSNumber * yCoordinate;

@end
