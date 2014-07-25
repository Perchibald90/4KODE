//
//  ViewController.m
//  4KODE
//
//  Created by Ruslan on 7/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import "ViewController.h"
#import "InstagramKit.h"
#import "MBProgressHUD.h"
#import "CollageComposer.h"

@interface ViewController () <UITextFieldDelegate>{
    float maxX;
    float maxY;
    
}

@property (atomic) InstagramEngine *engine;
@property (nonatomic, strong) NSArray *media;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) IBOutlet UIScrollView *content;
@property (nonatomic, weak) IBOutlet UIImageView *collage;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UIButton *giveMeCollage;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud hide:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.labelText = @"Loading";
    self.engine = [InstagramEngine sharedEngine];
    self.collage.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidAppear:(BOOL)animated {}

-(void)setMedia:(NSArray *)media {
    _media = media;
    if (media.count == 0)
        return;
    [self.hud show:YES];
    self.hud.progress = 0.f;
    self.hud.labelText = @"Images downloading...";
    __block NSUInteger mediaSize = _media.count;
    NSLog(@"%u images downloaded", mediaSize);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < mediaSize; i++) {
            InstagramMedia *m = _media[i];
            [temp addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:m.standardResolutionImageURL]]];
            float progress = ((float)i / mediaSize);
            [self setProgressToHud:(progress)];
        }
        self.images = temp;
        [self hideLoadingProgressHud];
    });
}

-(void)setImages:(NSMutableArray *)images {
    _images = images;
    self.hud.labelText = @"Collage creating...";
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *collageImage = [CollageComposer getCollageForImages:_images];
        [self.collage setImage:collageImage];

    });
}

- (IBAction)fullSize:(id)sender {
    self.content.contentSize =CGSizeMake(self.collage.image.size.width, self.collage.image.size.height);
    self.collage.frame = CGRectMake(0., 0., self.collage.image.size.width, self.collage.image.size.height);
}

- (IBAction)fittedSize:(id)sender {
    self.content.contentSize =CGSizeMake(self.content.frame.size.width, self.content.frame.size.height);
    self.collage.frame = CGRectMake(0., 0., self.content.frame.size.width, self.content.frame.size.height);
}

- (void)setProgressToHud:(double)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.progress = progress;
    });
}

- (void)hideLoadingProgressHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (IBAction)giveMeCollage:(id)sender {
    if (self.usernameTextField.text.length > 0) {
        [self.hud show:YES];
        self.hud.labelText = [NSString stringWithFormat:@"Search %@", self.usernameTextField.text];
        [self.engine searchUsersWithString:self.usernameTextField.text withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
            InstagramUser *user = users.firstObject;
            [self.engine getMediaForUser:user.Id withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                self.media = media;
            } failure:^(NSError *error) {}];
        } failure:^(NSError *error) {
            [self.hud hide:YES];
        }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
