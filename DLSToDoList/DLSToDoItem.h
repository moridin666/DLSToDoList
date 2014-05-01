//
//  DLSToDoItem.h
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14 in the name of Dark Lord Software.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLSToDoItem : NSObject

@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

@end
