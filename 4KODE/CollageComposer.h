//
//  CollageComposer.h
//  4KODE
//
//  Created by Ruslan on 7/25/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollageComposer : NSObject

+ (UIImage*)getCollageForImages:(NSArray*)images;

+ (CGSize)getSizeForCollage:(NSArray*)images;
+ (NSMutableArray *)getSimpleValuesForImagesCount:(NSArray*)images;

@end
