//
//  UIConstant.h
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#ifndef UIConstant_h
#define UIConstant_h

#define SCR_WIDTH           ([UIScreen mainScreen].bounds.size.width)
#define SCR_HEIGHT          ([UIScreen mainScreen].bounds.size.height)
#define SCALE_X(x)          ((x) * SCR_WIDTH  / 375.0f)
#define SCALE_Y(y)          ((y) * SCR_HEIGHT / 667.0f)
#define SCALE_XY_RECT(r)    (CGRectMake(SCALE_X(r.origin.x), SCALE_Y(r.origin.y), SCALE_X(r.size.width), SCALE_Y(r.size.height)))
#define SCALE_XX_RECT(r)    (CGRectMake(SCALE_X(r.origin.x), SCALE_X(r.origin.y), SCALE_X(r.size.width), SCALE_X(r.size.height)))
#define SCALE_RECT(x,y,w,h) (CGRectMake(SCALE_X(x), SCALE_X(y), SCALE_X(w), SCALE_X(h)))
#define EPS                 1.0f
#define EQUAL_RECT(a,b)     (fabs(a.origin.x-b.origin.x)<EPS && fabs(a.origin.y-b.origin.y)<EPS && fabs(a.size.width-b.size.width)<EPS && fabs(a.size.height-b.size.height)<EPS)
#define BORDER_WIDTH        ((SCR_HEIGHT>735)?0.33333f:0.5f)

#define handle_tap(view, selector) {\
view.userInteractionEnabled = YES;\
[view addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:selector]];\
}
#define handle_longtap(view, selector) {\
view.userInteractionEnabled = YES;\
[view addGestureRecognizer: [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector]];\
}

#endif /* UIConstant_h */
