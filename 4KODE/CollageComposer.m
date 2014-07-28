//
//  CollageComposer.m
//  4KODE
//
//  Created by Ruslan on 7/25/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import "CollageComposer.h"

@implementation CollageComposer

+ (NSMutableArray *)getSimpleValuesForImagesCount:(NSArray*)images {
    int imagesCount = images.count;
    NSMutableArray *array = [NSMutableArray new];
    int i = 2;
    int t = imagesCount;
    if  (i > t) {
        [array addObject:[NSNumber numberWithInt:t]];
    }
    int remainder = t % 2;
    if (remainder > 0) {
        t = t - remainder;
    }
    while(i<=t) {
        if(t%i==0) {
            t=t/i;
            [array addObject:[NSNumber numberWithInt:i]];
        } else
            i=i+1;
    }
    return array;
}

+ (CGSize)getSizeForCollage:(NSArray*)images {
    NSMutableArray *array = [CollageComposer getSimpleValuesForImagesCount:images];
    CGSize size = CGSizeZero;
    int minDiff = -1;
    if (array.count == 1) {
        size.width = ((NSNumber*)array.firstObject).integerValue;
        size.height = 1;
    } else {
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
                        if (minDiff > MIN(minDiff, abs(n - r)) && abs(n-r) > 0 && n * r == images.count) {
                            size.width = n;
                            size.height = r;
                        }
                        minDiff = MIN(minDiff, abs(n - r));
                    }
                }
            }
        }
    }
    if ([images.firstObject isKindOfClass:[UIImage class]]) {
        UIImage *img = images.firstObject;
        size.width = size.width * img.size.width;
        size.height = size.height * img.size.height;
    }
    return size;
}

+ (UIImage*)getCollageForImages:(NSArray*)images {
    CGSize collageSize = [CollageComposer getSizeForCollage:images];
    float width = collageSize.width;
    float height = collageSize.height;

    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    int rowsMax = width / ((UIImage*)images.firstObject).size.width;
    int columnMax = height / ((UIImage*)images.firstObject).size.height;
    for (int i = 0; i < rowsMax; i++) {
        for (int j = 0; j < columnMax; j++) {
            if (images.count <= i*columnMax + j) {
                continue;
            }
            UIImage *img = images[i*columnMax + j];
            CGPoint imagePoint = CGPointMake(i * img.size.width, j * img.size.height);
            [img drawAtPoint:imagePoint];
        }
    }
    UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

@end
