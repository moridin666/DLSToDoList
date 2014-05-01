//
//  DLSToDoListTableViewController.m
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSToDoListTableViewController.h"
#import "DLSToDoItem.h"
#import "DLSAddToDoItemViewController.h"

@interface DLSToDoListTableViewController ()


@property (strong) NSMutableArray *toDoItems;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;


@end

@implementation DLSToDoListTableViewController

// grab the managed object context
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    DLSAddToDoItemViewController *source = [segue sourceViewController];
    DLSToDoItem *item = source.toDoItem;
    if (item != nil) {
        [self.toDoItems addObject:item];
        self.toDoItems = [NSEntityDescription insertNewObjectForEntityForName:@"DLSToDoItem" inManagedObjectContext:context];
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.toDoItems = [[NSMutableArray alloc] init];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // fetch to do items from the persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DLSToDoItem"];
    self.toDoItems = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.toDoItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell to display properly with a check mark for completed items and without for incomplete items
    NSManagedObject *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    BOOL completed = [[toDoItem valueForKey:@"completed"] boolValue];
    if (completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [toDoItem valueForKey:@"itemName"]]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSManagedObject *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    // Set the value for completed upon tapping a cell
    
    BOOL completed = [[tappedItem valueForKey:@"completed"] boolValue];
    if (completed) {
        [tappedItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [tappedItem setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Allow the item to be edited by returning YES
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete Object from the database
        [context deleteObject:[self.toDoItems objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        //Remove the toDo from the table View
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
