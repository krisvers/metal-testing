#ifndef KRISVERS_METAL_TEST_RENDERER_H
#define KRISVERS_METAL_TEST_RENDERER_H

#import <Foundation/Foundation.h>

@interface MetalRenderer : NSObject

- (instancetype)initWithGLFWWindow: (GLFWwindow *)glfwWindow;
- (void)draw;

@end

#endif
