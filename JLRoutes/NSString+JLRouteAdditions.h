//
//  NSString+JLRouteAdditions.h
//  JLRoutes
//
//  Created by Joel Levin on 9/17/15.
//  Copyright © 2015 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (JLRouteAdditions)

- (NSString *)JLRoutes_URLDecodedString;
- (NSDictionary *)JLRoutes_URLParameterDictionary;

@end
