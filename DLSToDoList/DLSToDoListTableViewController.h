//
//  DLSToDoListTableViewController.h
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14 in the name of Dark Lord Software.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLSToDoItem.h"

@interface DLSToDoListTableViewController : UITableViewController

@property DLSToDoItem *toDoItem;
@property (strong) NSMutableArray *toDoItems;

@end