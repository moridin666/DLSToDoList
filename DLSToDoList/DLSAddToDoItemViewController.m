//
//  DLSAddToDoItemViewController.m
//  DLSToDoList
//
//  Created by Jason Schneider on 4/29/14 in the name of Dark Lord Software.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSAddToDoItemViewController.h"

@interface DLSAddToDoItemViewController ()


@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation DLSAddToDoItemViewController


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
            
            NSManagedObject *toDoItem = [NSEntityDescription insertNewObjectForEntityForName:@"DLSToDoItem" inManagedObjectContext:context];
            [toDoItem setValue:self.textField.text forKey:@"itemName"];
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
    self.textField.delegate = self;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
