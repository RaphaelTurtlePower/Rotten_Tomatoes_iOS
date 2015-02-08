//
//  MoviesDetailedViewController.m
//  RottenTomatoes
//
//  Created by Chris Mamuad on 2/6/15.
//  Copyright (c) 2015 Chris Mamuad. All rights reserved.
//

#import "MoviesDetailedViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"

@interface MoviesDetailedViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *movieScrollView;
@property (weak, nonatomic) IBOutlet UILabel *moviesTitle;
@property (weak, nonatomic) IBOutlet UIImageView *movieImageView;
@property (weak, nonatomic) IBOutlet UILabel *moviesSynopsis;
@property (weak, nonatomic) IBOutlet UIImageView *lowRes;

@end

@implementation MoviesDetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movie Details";
    self.moviesTitle.text = self.movie[@"title"];
    self.moviesSynopsis.text = self.movie[@"synopsis"];
    NSString *url = [self.movie valueForKeyPath:@"posters.original"];
    NSURL *lowResUrl = [[NSURL alloc] initWithString:url];
    
    [self.lowRes setImageWithURL:lowResUrl];
    
    url = [url stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    NSURL *myUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:myUrl];
    [SVProgressHUD show];
    [self.movieImageView setImageWithURLRequest:req
                        placeholderImage:nil
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                     [UIView transitionWithView:self.movieImageView
                                                       duration:0.5
                                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                                     animations:^{
                                                         self.movieImageView.image = image;
                                                     }
                                                     completion:NULL];
                                      [SVProgressHUD dismiss];
                                 }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                             [SVProgressHUD dismiss];
                                        }];
   
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
