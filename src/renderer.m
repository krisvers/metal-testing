#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#include <GLFW/glfw3native.h>

#include <renderer.h>

typedef void(*internaldraw_func)(NSObject* object);

@interface MetalViewDelegate : NSObject<MTKViewDelegate>

@end

@implementation MetalViewDelegate {
	internaldraw_func _internalDrawFunc;
	NSObject *_internalDrawFuncObject;
}

- (void)internalDrawFunc:(internaldraw_func)func {
	_internalDrawFunc = func;
}

- (void)internalDrawObject:(NSObject *)obj {
	_internalDrawFuncObject = obj;
}

- (instancetype)initWithMetalKitView:(MTKView *)view {
	self = [super init];
	if (self) {
		view.delegate = self;
	}

	return self;
}

- (void)drawInMTKView:(nonnull MTKView *)view {
	_internalDrawFunc(_internalDrawFuncObject);
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
	
}

@end

void internalDrawStatic(NSObject *object);

@implementation MetalRenderer {
	MTKView *_metalView;
	MetalViewDelegate *_metalViewDelegate;
	NSWindow *_cocoaWindow;

	id<MTLDevice> _device;
	id<MTLCommandQueue> _commandQueue;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLBuffer> _vertexBuffer;
}

- (instancetype)initWithGLFWWindow: (GLFWwindow *)glfwWindow {
	self = [super init];

	_device = MTLCreateSystemDefaultDevice();
	if (_device == nil) {
		NSLog(@"Failed to create Metal device");
		return nil;
	}
		
	_metalView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, 800, 600) device:_device];
	_metalView.layer.opaque = YES;

	_metalViewDelegate = [[MetalViewDelegate alloc] initWithMetalKitView:_metalView];
	[_metalViewDelegate internalDrawFunc:internalDrawStatic];
	[_metalViewDelegate internalDrawObject:(NSObject *)self];

	_cocoaWindow = glfwGetCocoaWindow(glfwWindow);
	[_cocoaWindow.contentView addSubview:_metalView];

	_commandQueue = [_device newCommandQueue];
	_metalView.delegate = _metalViewDelegate;

	[self setupPipeline];
	[self setupVertexBuffer];

	[self setupPipeline];
	[self setupVertexBuffer];

	return self;
}

- (void)setupPipeline {
	NSError *error = nil;
	id<MTLLibrary> library = [_device newLibraryWithFile:@"Shader.air" error:&error];
	
	if (!library) {
		NSLog(@"Failed to load Metal library: %@", error);
		return;
	}
	
	id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_shader"];
	id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_shader"];

	MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
	vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
	vertexDescriptor.attributes[0].bufferIndex = 0;
	vertexDescriptor.attributes[0].offset = 0;
	vertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
	vertexDescriptor.attributes[1].bufferIndex = 0;
	vertexDescriptor.attributes[1].offset = sizeof(float) * 3;
	vertexDescriptor.layouts[0].stride = sizeof(float) * 3 * 2;
	
	MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
	pipelineDescriptor.vertexFunction = vertexFunction;
	pipelineDescriptor.fragmentFunction = fragmentFunction;
	pipelineDescriptor.colorAttachments[0].pixelFormat = _metalView.colorPixelFormat;
	pipelineDescriptor.vertexDescriptor = vertexDescriptor;
	
	_pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
	if (!_pipelineState) {
		NSLog(@"Failed to create render pipeline state: %@", error);
	}
}

- (void)setupVertexBuffer {
	static const float vertexData[] = {
		0.0f,  1.0f, 0.0f,		1.0f, 1.0f, 0.0f,
	   -1.0f, -1.0f, 0.0f,		1.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 0.0f,		0.0f, 1.0f, 1.0f,
	};
	
	_vertexBuffer = [_device newBufferWithBytes:vertexData length:sizeof(vertexData) options:MTLResourceStorageModeShared];
}

- (void)draw {
	[_metalView draw];
}

- (void)internalDraw {
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	MTLRenderPassDescriptor *renderPassDescriptor = _metalView.currentRenderPassDescriptor;
	
	if (renderPassDescriptor != nil) {
		id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
		[renderEncoder setRenderPipelineState:_pipelineState];
		[renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
		[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
		[renderEncoder endEncoding];
		
		[commandBuffer presentDrawable:_metalView.currentDrawable];
	}
	
	[commandBuffer commit];
}

@end

void internalDrawStatic(NSObject *object) {
	[((MetalRenderer *) object) internalDraw];
}
