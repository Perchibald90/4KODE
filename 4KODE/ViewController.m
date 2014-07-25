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
#import "UIImage+mergeImage.h"

@interface ViewController () {
    float maxX;
    float maxY;
    
}

@property (atomic) InstagramEngine *engine;
@property (nonatomic, strong) NSArray *media;
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, weak) IBOutlet UIImageView *collage;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UIButton *giveMeCollage;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.images = [NSMutableArray new];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud hide:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.labelText = @"Loading";
    self.engine = [InstagramEngine sharedEngine];
    [self.engine getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.media = media;
    } failure:^(NSError *error) {}];
}

- (void)viewDidAppear:(BOOL)animated {}

-(void)setMedia:(NSArray *)media {
    _media = media;
    [self.hud show:YES];
    self.hud.progress = 0.f;
    self.hud.labelText = @"Images downloading";
    __block NSUInteger mediaSize = _media.count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (int i = 0; i < mediaSize; i++) {
            InstagramMedia *m = _media[i];
            [self.images addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:m.standardResolutionImageURL]]];
            float progress = ((float)i / mediaSize);
            [self setProgressToHud:(progress)];
        }
        [self hideLoadingProgressHud];
        [self createCollageFromDownloadedImages];
    });
}

- (NSMutableArray *)getSimpleValuesForImagesCount {
    int imagesCount = self.images.count;
    NSMutableArray *array = [NSMutableArray new];
    int i = 2;
    int t = imagesCount;
    while(i<=t) {
        if(t%i==0) {
            t=t/i;
            [array addObject:[NSNumber numberWithInt:i]];
        } else
            i=i+1;
    }
    return array;
}

- (CGSize)getSizeForCollage {
    NSMutableArray *array = [self getSimpleValuesForImagesCount];
    CGSize size = CGSizeZero;
    int minDiff = -1;
    for (int i = 0; i < array.count; i++) {
        int n = ((NSNumber*)array[i]).integerValue;
        for (int j = 0; j < array.count; j++) {
            if (i == j) continue;
            int m = ((NSNumber*)array[j]).integerValue;
            n = n * m;
            int r = 1;
            if (j + 1 < array.count) {
                for (int k = j + 1; k < array.count; k++) {
                    int b = ((NSNumber*)array[k]).integerValue;
                    r = b * r;
                }
                if (minDiff < 0) {
                    minDiff = abs(n - r);
                    size.width = n;
                    size.height = r;
                } else {
                    if (minDiff > MIN(minDiff, abs(n - r)) && abs(n-r) > 0 && n * r == self.images.count) {
                        size.width = n;
                        size.height = r;
                    }
                    minDiff = MIN(minDiff, abs(n - r));
                }
            }
        }
    }
    UIImage *img = self.images.firstObject;
    size.width = size.width * img.size.width;
    size.height = size.height * img.size.height;
    NSLog(@"%@", NSStringFromCGSize(size));
    return size;
}

- (void)createCollageFromDownloadedImages {
    CGSize collageSize = [self getSizeForCollage];
    float width = collageSize.width;
    float height = collageSize.height;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    int rowsMax = width / ((UIImage*)self.images.firstObject).size.width;
    int columnMax = height / ((UIImage*)self.images.firstObject).size.height;
    for (int i = 0; i < rowsMax; i++) {
        for (int j = 0; j < columnMax; j++) {
            UIImage *img = self.images[i*columnMax + j];
            CGPoint imagePoint = CGPointMake(i * img.size.width, j * img.size.height);
            [img drawAtPoint:imagePoint];
        }
    }
    UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collage setImage:finalImage];
    });
}

-(UIImage*) makeImage {
    UIGraphicsBeginImageContext(CGSizeMake(2560, 3200));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
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

@end
