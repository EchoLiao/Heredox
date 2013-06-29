//
//  NSMutableArray+UDAdditions.m
//
//  Created by Rolandas Razma on 12/28/11.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSMutableArray+UDAdditions.h"


@implementation NSMutableArray (UDAdditions)


- (void)shuffleWithSeed:(unsigned int)seed {
    if( seed == 0 ) seed = (unsigned int)time(NULL);
    
    srandom(seed);
    
    NSUInteger elementsCount = [self count];
    for (NSUInteger x = 0; x<elementsCount; x++) {
        NSUInteger randInt = (NSUInteger)roundf((random() %((long)elementsCount -(long)x)) +(long)x);
        [self exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
}


@end
