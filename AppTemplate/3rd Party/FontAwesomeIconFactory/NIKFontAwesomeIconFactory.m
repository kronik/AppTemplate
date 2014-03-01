#import "NIKFontAwesomeIconFactory.h"

#import "NIKFontAwesomePathFactory.h"
#import "NIKFontAwesomePathRenderer.h"

#if TARGET_OS_IPHONE
typedef UIFont NIKFont;
typedef UIBezierPath NIKBezierPath;
#else
typedef NSFont NIKFont;
typedef NSBezierPath NIKBezierPath;
#endif

@implementation NIKFontAwesomeIconFactory

+ (NIKFontAwesomeIconFactory *)sharedInstance
{
   	static NIKFontAwesomeIconFactory *factory = nil;
    
	if (factory == nil) {
		@synchronized(self) {
			if (factory == nil) {
				factory = [[NIKFontAwesomeIconFactory alloc] init];
            }
        }
	}
	
	return factory;
}


- (id)init {
    self = [super init];
    if (self) {
        _size = 32.0;
        _colors = @[[NIKColor darkGrayColor]];
        _strokeColor = [NIKColor blackColor];
        _strokeWidth = 0.0;
    }
    return self;
}

- (NIKFont *)createFont {
    return [NIKFont fontWithName:@"FontAwesome" size:14.0];
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone {
    NIKFontAwesomeIconFactory *copy = [[[self class] allocWithZone:zone] init];
    if (copy != nil) {
        copy.size = self.size;
        copy.edgeInsets = self.edgeInsets;
        copy.colors = self.colors;
        copy.strokeColor = self.strokeColor;
        copy.strokeWidth = self.strokeWidth;
    }
    return copy;
}

- (NIKImage *)createImageForIcon:(NIKFontAwesomeIcon)icon {
    CGPathRef path = [self createPath:icon];
    NIKImage *image = [self createImageWithPath:path];
    CGPathRelease(path);
    return image;
}

- (CGPathRef)createPath:(NIKFontAwesomeIcon)icon CF_RETURNS_RETAINED {
    CGFloat width = _square ? _size : CGFLOAT_MAX;
    return [[NIKFontAwesomePathFactory new] createPathForIcon:icon height:_size maxWidth:width];
}

- (NIKImage *)createImageWithPath:(CGPathRef)path {
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPoint offset = CGPointZero;

    if (_square) {
        CGFloat diff = bounds.size.height - bounds.size.width;
        if (diff > 0) {
            offset.x += .5 * diff;
            bounds.size.width = bounds.size.height;
        } else {
            offset.y += .5 * -diff;
            bounds.size.height = bounds.size.width;
        }
    };

    CGFloat padding = _strokeWidth * .5;
    offset.x += padding + _edgeInsets.left;
    offset.y += padding + _edgeInsets.bottom;
    bounds.size.width += 2.0 * padding + _edgeInsets.left + _edgeInsets.right;
    bounds.size.height += 2.0 * padding + _edgeInsets.top + _edgeInsets.bottom;

    NIKFontAwesomePathRenderer *renderer = [self createRenderer:path];
    renderer.offset = offset;

#if TARGET_OS_IPHONE
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [renderer renderInContext:context];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;

#else

    if ([NSImage respondsToSelector:@selector(imageWithSize:flipped:drawingHandler:)]) {
        return [NSImage imageWithSize:bounds.size
                              flipped:NO
                       drawingHandler:^(CGRect rect) {
                           NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
                           [renderer renderInContext:[graphicsContext graphicsPort]];
                           return YES;
                       }];
    } else {
        NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
        [image lockFocus];
        NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
        [renderer renderInContext:[graphicsContext graphicsPort]];
        [image unlockFocus];
        return image;
    }
#endif
}

- (NIKFontAwesomePathRenderer *)createRenderer:(CGPathRef)path {
    NIKFontAwesomePathRenderer *renderer = [NIKFontAwesomePathRenderer new];
    renderer.path = path;

    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:_colors.count];
    for (NIKColor *color in _colors) {
        CGColorRef cgColor = copyCGColor(color);
        [colors addObject:(__bridge id) cgColor];
        CGColorRelease(cgColor);
    }
    renderer.colors = colors;
    CGColorRef cgColor = copyCGColor(_strokeColor);
    renderer.strokeColor = cgColor;
    CGColorRelease(cgColor);
    renderer.strokeWidth = _strokeWidth;

    return renderer;
}

CF_RETURNS_RETAINED
static CGColorRef copyCGColor(NIKColor *color) {
    CGColorRef cgColor;
#if TARGET_OS_IPHONE
    cgColor = CGColorCreateCopy(color.CGColor);
#else
    if ([color respondsToSelector:@selector(CGColor)]) {
        cgColor = CGColorCreateCopy(color.CGColor);
    } else {
        NSColor *deviceColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
        CGFloat components[4];
        [deviceColor getComponents:components];

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        cgColor = CGColorCreate(colorSpace, components);
        CGColorSpaceRelease(colorSpace);
    }
#endif
    return cgColor;
}

@end
