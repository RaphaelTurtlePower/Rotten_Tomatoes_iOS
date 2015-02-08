//
//  MoviesViewController.m
//  RottenTomatoes
//
//  Created by Chris Mamuad on 2/6/15.
//  Copyright (c) 2015 Chris Mamuad. All rights reserved.
//

#import "MovieCell.h"
#import "MovieCollectionViewCell.h"
#import "MoviesDetailedViewController.h"
#import "MoviesViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "AFNetworkReachabilityManager.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *movies;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSSet *keys;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *errorView;
@property (strong, nonatomic) NSString *movieType;
@property (strong, nonatomic) NSString *api_string;
@property (strong, nonatomic) UISearchController *searchResultsController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@end

@implementation MoviesViewController

- (id) initWithMovieType: (NSString*) movieType{
    if(self = [super init]){
        movieType = [NSString stringWithString:movieType];
        if([movieType isEqualToString:@"DVD"]){
            self.api_string = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=hx9p6c45srn26wb493sbyxat&limit=30&country=us";
            self.title = @"DVD Top Rentals";
            
        }else{
            self.title = @"Box Office Hits";
            self.api_string = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=hx9p6c45srn26wb493sbyxat&limit=30&country=us";
        }
    }
    return self;
}
- (IBAction)onClick:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [self.gridView setHidden:YES];
        [self.tableView setHidden:NO];
    }
    else{
        [self.gridView setHidden:NO];
        [self.tableView setHidden:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.gridView.delegate = self;
    self.gridView.dataSource = self;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    [self.gridView registerNib:[UINib nibWithNibName:@"MovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier: @"MovieCollectionCell"];
    self.tableView.rowHeight = 100;
    
    [self loadTables:false];
    
    self.keys = [[NSSet alloc] init];
    self.movies = [[NSMutableArray alloc] init];
    
    //refreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.alpha = 0.5;
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.searchResultsController = [[UISearchController alloc] initWithSearchResultsController:nil];
   // [self.searchResultsController.searchResultsUpdater self];
    [self.searchResultsController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchResultsController.searchBar;
    self.searchResultsController.hidesNavigationBarDuringPresentation = false;
    self.searchResultsController.dimsBackgroundDuringPresentation = true;
    
    self.searchResultsController.searchBar.frame = CGRectMake(0, 44, self.tableView.frame.size.width, 44);
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth, 44)];
    [self.errorView setHidden:YES];
    [self.errorView setBackgroundColor: [UIColor redColor]];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,screenWidth, 44)];
    [label setText: @"Network Error."];
    [label setTextColor: [UIColor orangeColor]];
    [self.errorView addSubview: label];
    [self.tableView addSubview:self.errorView];

}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}



- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSLog(@"Updating Search results called.");
    self.searchResults = [[NSMutableArray alloc] init];
    for(int i=0; i<[self.movies count] ; i++){
        if([self.movies[i][@"title"] containsString:searchController.searchBar.text]){
            [self.searchResults insertObject:self.movies[i] atIndex:0];
        }
    }
    
    [self.tableView reloadData];
}

-(void) loadTables: (Boolean *) append{
    [SVProgressHUD show];
    NSURL *url = [NSURL URLWithString:self.api_string];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError){
         if(connectionError){
             [self loadError];
             return;
         }
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
         NSInteger statusCode = httpResponse.statusCode;
         if(statusCode == 200){
             [self removeError];
          }else{
             [self loadError];
          }
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
         if(append){
             NSUInteger count = [responseDictionary[@"movies"] count];
             for(int i=0; i<count; i++){
                 if(![self.keys containsObject:responseDictionary[@"movies"][i]]){
                     [self.movies insertObject:responseDictionary[@"movies"][i] atIndex:0];
                 }
             }
             
         }else{
             self.movies =responseDictionary[@"movies"];
             self.keys = [NSSet setWithArray: self.movies];
         }
         NSLog(@"response:%@", self.movies);
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
     }];
}

- (void) onRefresh {
    NSLog(@"PULL TO REFERSH CALLED.");
    [self loadTables:TRUE];
    
}

-(void) removeError{
    [self.errorView setHidden:YES];
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
}

-(void) loadError {
    [self.errorView setHidden:NO];
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.searchResultsController.active){
        return self.searchResults.count;
    }
    return self.movies.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    if(self.searchResultsController.active){
        movie = self.searchResults[indexPath.row];
    }
    
    cell.title.text = movie[@"title"];
    cell.synopsis.text = movie[@"synopsis"];
    
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    
    NSURL *myUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:myUrl];
    [cell.posterView setImageWithURLRequest:req
                               placeholderImage:[UIImage imageNamed:@"films"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            [UIView transitionWithView:cell.posterView
                                                              duration:0.5
                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{
                                                                cell.posterView.image = image;
                                                                cell.posterView.layer.cornerRadius = 5.0;
                                                            }
                                                            completion:NULL];
                                        }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
                                    }];

    
    //style the selction
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:180.0f/255.0f alpha:0.5];
//[UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1];
    
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MoviesDetailedViewController *detailView = [[MoviesDetailedViewController alloc] init];
    
    detailView.movie = self.movies[indexPath.row];
    
    [self.navigationController pushViewController:detailView animated:YES];
}



#pragma mark - check network connection
-(BOOL) isConnected{
    return [AFNetworkReachabilityManager sharedManager].reachable; }

-(BOOL)connected {
    
    __block BOOL reachable;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"No Internet Connection");
                reachable = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                
                reachable = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                reachable = YES;
                break;
            default:
                NSLog(@"Unkown network status");
                reachable = NO;
                break;
                
        }
    }];
    
    (reachable) ? [self removeError] : [self loadError];
    return reachable;
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MovieCollectionViewCell";
    
   MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    
    
    NSURL *myUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:myUrl];
    [cell.movieImageView setImageWithURLRequest:req
                           placeholderImage:[UIImage imageNamed:@"films"]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        [UIView transitionWithView:cell.movieImageView
                                                          duration:0.5
                                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                                        animations:^{
                                                            cell.movieImageView.image = image;
                                                            cell.movieImageView.layer.cornerRadius = 5.0;
                                                        }
                                                        completion:NULL];
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                        
                                    }];
    

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
