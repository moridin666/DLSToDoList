//
//  DLSToDoListTableViewController.m
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14 in the name of Dark Lord Software.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSToDoListTableViewController.h"
#import "DLSToDoItem.h"
#import "DLSAddToDoItemViewController.h"

@interface DLSToDoListTableViewController ()

@property (strong) NSMutableArray *toDoItems;
@property (strong) NSArray *fetchResults;
@property (strong) NSManagedObject *helper;


- (IBAction)unwindToList:(UIStoryboardSegue *)segue;


@end

@implementation DLSToDoListTableViewController


/*
///
////
///// View Methods
////
///
*/

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
    self.view.backgroundColor = [UIColor blackColor];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // fetch to do items from the persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DLSToDoItem"];
    [fetchRequest setSortDescriptors:@[displayOrder]];
    self.toDoItems = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    
    //reload the table
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (void)scrollToBottom
{
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if ( bottomOffset.y > 0 ) {
        [self.tableView setContentOffset:bottomOffset animated:YES];
    }
}

/*
 //
 ///
 ////
 /////
 ///// Segues
 ////
 ///
 //
*/



- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    DLSAddToDoItemViewController *source = [segue sourceViewController];
    DLSToDoItem *item = source.toDoItem;
    NSNumber *displayOrder = [NSNumber numberWithInt:[self.toDoItems count]];
    
    // Save the object's position in the array
    if (item != nil) {
        [self.toDoItems addObject:item];
        self.toDoItems = [NSEntityDescription insertNewObjectForEntityForName:@"DLSToDoItem" inManagedObjectContext:context];
        // Set the displayOrder value
        [item setValue:displayOrder forKey:@"displayOrder"];
    }
}


/*
///
////
/////
////// Table View
/////
////
///
*/

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
    NSManagedObject *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    
    // Configure the cell to display properly with a check mark for completed items and without for incomplete items
    BOOL completed = [[toDoItem valueForKey:@"completed"] boolValue];
    if (completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Set text according to toDoItem name
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [toDoItem valueForKey:@"itemName"]]];
    // Customize font, text color, and size
    cell.textLabel.textColor = [UIColor whiteColor];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
    cell.textLabel.font = cellFont;
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


//
///
////
///// Editing the tableView
////
///
//



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Allow the item to be edited by returning YES or true
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSManagedObject *toDoToMove = [self.toDoItems objectAtIndex:sourceIndexPath.row];
    [self.toDoItems removeObjectAtIndex:sourceIndexPath.row];
    [self.toDoItems insertObject:toDoToMove atIndex:destinationIndexPath.row];
    
    NSInteger sourceIndex = sourceIndexPath.row;
    NSInteger destinationIndex = destinationIndexPath.row;
    NSValue *rowNumber = [self convertNSIntegerToNSValue:&destinationIndex];
    [self.tableView reloadData];
    
    // Save new row indices for all displaced objects
    
    [self savePosition:toDoToMove withDisplayOrderKey:rowNumber];
    
    if (destinationIndex > sourceIndex) {
        for (int i = sourceIndex + 1; i < destinationIndex; i++) {
            NSManagedObject *bubbleUp = [self.toDoItems objectAtIndex:i];
            NSValue *rowNumber = [self convertNSIntegerToNSValue:&i];
            [self savePosition:bubbleUp withDisplayOrderKey:rowNumber];
            
        }
    }
    if (destinationIndex < sourceIndex) {
        for (int i = destinationIndex - 1; i > sourceIndex; i--) {
            NSManagedObject *bubbleDown = [self.toDoItems objectAtIndex:i];
            NSValue *rowNumber = [self convertNSIntegerToNSValue:&i];
            [self savePosition:bubbleDown withDisplayOrderKey:rowNumber];
        }
    }
    
    [self.tableView reloadData];
    
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(!editing) {
        int i = 0;
        for(DLSToDoItem *toDoItem in self.toDoItems) {
            toDoItem.displayOrder = [NSNumber numberWithInt:i++];
        }
        NSError *error = nil;
        [self.managedObjectContext save:&error]; // basically calls [managedObjectContext save:&error];
    }
}



/*
///
////
/////
////// Memory Management
/////
////
///
*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 ///
 ////
 /////
 ////// Helper Methods
 /////
 ////
 ///
 */

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

- (NSMutableArray *)getRowObjects
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Configure the request's entity, and optionally its predicate (via Apple)
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RowObj" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *fetchedListController = [[NSFetchedResultsController alloc]
                                                         initWithFetchRequest:fetchRequest
                                                         managedObjectContext:context
                                                         sectionNameKeyPath:nil
                                                         cacheName:nil];


    self.fetchResults = [fetchedListController fetchedObjects];
    if (self.fetchResults == nil) {
        return nil;
    }
    else
    {
        NSMutableArray *mutableFetchResults = [self returnMutableFetchResults:self.fetchResults];
        return mutableFetchResults;
    }
}

- (NSMutableArray *)returnMutableFetchResults:(NSArray *)fetchResults
{
    return [NSMutableArray arrayWithArray:fetchResults];
}
     
- (NSValue *)convertNSIntegerToNSValue:(NSInteger *)input
{
    NSValue *index = [NSNumber numberWithInt:*input];
    return index;
}

- (void)savePosition:(NSManagedObject *)toDoToMove withDisplayOrderKey:(NSValue *)index
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [toDoToMove setValue:index forKey:@"displayOrder"];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

@end
