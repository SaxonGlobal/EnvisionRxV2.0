//
//  VenueAnnotation.h

//
//  Created by jancy on 03/03/11.
//  Copyright 2011 Mobomo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VenueAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate; 
	NSString *title;
	NSString *subtitle;
	
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end
