//
//  DLSAddToDoItemViewController.m
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14 in the name of Dark Lord Software.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSAddToDoItemViewController.h"
#import "DLSToDoListTableViewController.h"

@interface DLSAddToDoItemViewController ()


@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation DLSAddToDoItemViewController


// set the managed object context
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == self.cancelButton)
    {
        return;
    }
    if ((sender == self.textField.delegate) || (sender == self.doneButton))
    {
        if (self.textField.text.length > 0)
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            //Create and save a new Managed Object
            DLSToDoListTableViewController *destination = [segue destinationViewController];
            NSManagedObject *toDoItem = [NSEntityDescription insertNewObjectForEntityForName:@"DLSToDoItem" inManagedObjectContext:context];
            [toDoItem setValue:self.textField.text forKey:@"itemName"];
            [toDoItem setValue:[NSNumber numberWithInt:[destination.toDoItems count]] forKey:@"displayOrder"];
            self.toDoItem.completed = NO;
            
            NSError *error = nil;
            if (![context save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
        else
        {
            return;
        }
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.textField becomeFirstResponder];
    self.textField.delegate = self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"keyboardReturn" sender:self];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
