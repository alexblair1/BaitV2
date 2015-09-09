//
//  HoneyHoleTableViewController.m
//  Bait
//
//  Created by Stephen Blair on 8/15/15.
//  Copyright (c) 2015 Stephen Blair. All rights reserved.
//

#import "HoneyHoleTableViewController.h"

@interface HoneyHoleTableViewController ()

@property (nonatomic, strong) HoneyHole *honeyHoleObject;

@end

@implementation HoneyHoleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initializeLoginViewController];
    [self initializeRevealView];
    [self initializeNavigationImage];
    [self initializeLocationManager];
    [self fetchRequest];
    
    self.searchBar.delegate = self;

//    [self performParseSave];
//    [self performParseQuery];
}

//Parse Test
//TODO: Remove before submitting next version

//-(void)initializeLoginViewController{
//    if (![PFUser currentUser]) {
//        
//        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
//        [logInController setDelegate:self];
//        
//        PFSignUpViewController *signUpContoller = [[PFSignUpViewController alloc] init];
//        [signUpContoller setDelegate:self];
//        
//        [logInController setSignUpController:signUpContoller];
//        
//        [self presentViewController:logInController animated:YES completion:nil];
//        
//    }
//}
//
//-(void)performParseSave{
//    PFObject *testNumber = [PFObject objectWithClassName:@"TestNumber"];
//    testNumber[@"score"] = @1000;
//    
//    [testNumber saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//        if (succeeded){
//            NSLog(@"Object was saved");
//        } else {
//            //there was a problem. check the error
//        }
//    }];
//}
//
//-(void)performParseQuery{
//    PFQuery *parseQuery = [PFQuery queryWithClassName:@"TestNumber"];
//    [parseQuery getObjectInBackgroundWithId:@"GvkAJMdUei" block:^(PFObject *testNumberTwo, NSError *error){
//        NSLog(@"%@", testNumberTwo);
//        int saveNumberTest = [[testNumberTwo objectForKey:@"score"] intValue];
//        NSLog(@"SAVED NUMBER TEST: %d", saveNumberTest);
//    }];
//}
//
//- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
//    // Check if both fields are completed
//    if (username && password && username.length != 0 && password.length != 0) {
//        return YES; // Begin login process
//    }
//    
//    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
//                                message:@"Make sure you fill out all of the information!"
//                               delegate:nil
//                      cancelButtonTitle:@"ok"
//                      otherButtonTitles:nil] show];
//    return NO; // Interrupt login process
//}
//
//-(void)logInViewController:(PFLogInViewController * __nonnull)logInController didLogInUser:(PFUser * __nonnull)user{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - Init Methods

-(void) initializeRevealView{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void) initializeNavigationImage{
    UIImage *fishHookImage = [UIImage imageNamed:@"baitText.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fishHookImage];
    self.navigationItem.titleView = imageView;
}

-(void) initializeLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager startUpdatingLocation];
}

-(void)fetchRequest{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HoneyHole"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"name" cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    self.fetchResultItems = [NSMutableArray arrayWithArray:[self.fetchedResultsController fetchedObjects]];
    NSLog(@"fetch result items: %@", self.fetchResultItems);
}

#pragma mark - Search Bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    CLLocationCoordinate2D startCoord;
    startCoord.latitude = self.locationManager.location.coordinate.latitude;
    startCoord.longitude = self.locationManager.location.coordinate.longitude;
    
    NSString *textFromSearchBar = self.searchBar.text;
    
    [[DataSource sharedInstance] saveHoneyHoleWithName:textFromSearchBar withY:startCoord.latitude withX:startCoord.longitude];
    self.searchBar.text = nil;
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.searchBar.text = nil;
}

#pragma mark - Fetched results controller delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    //Fetch Record
    self.honeyHoleObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *nameString = [NSString stringWithFormat:@"%@", self.honeyHoleObject.name];
    float x = [self.honeyHoleObject.xCoordinate floatValue];
    float y = [self.honeyHoleObject.yCoordinate floatValue];
    
    cell.textLabel.text = nameString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"X:%f   Y:%f", y, x];
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"honeyHoleCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"honeyHoleCell"];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"fishHook.png"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view editing

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (record) {
            [self.fetchedResultsController.managedObjectContext deleteObject:record];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.honeyHoleObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *alertTitle = [NSString stringWithFormat:@"Would you like to route to: %@", self.honeyHoleObject.name];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    float x = [self.honeyHoleObject.xCoordinate floatValue];
    float y = [self.honeyHoleObject.yCoordinate floatValue];
    
    CLLocationCoordinate2D endingCoordinate = CLLocationCoordinate2DMake(y, x);
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoordinate addressDictionary:nil];
    MKMapItem *endingMapItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    endingMapItem.name = self.honeyHoleObject.name;
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    
    if (buttonIndex == 1) {
        [endingMapItem openInMapsWithLaunchOptions:launchOptions];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
