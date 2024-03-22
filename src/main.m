#include <GLFW/glfw3.h>

#include <renderer.h>

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if (!glfwInit()) {
			NSLog(@"Failed to initialize GLFW");
			return -1;
		}
		
		glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
		glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
		GLFWwindow* glfwWindow = glfwCreateWindow(800, 600, "hello mettul", NULL, NULL);
		if (!glfwWindow) {
			NSLog(@"Failed to create GLFW window");
			glfwTerminate();
			return -1;
		}

		glfwShowWindow(glfwWindow);

		MetalRenderer *renderer = [[MetalRenderer alloc] initWithGLFWWindow:glfwWindow];
		
		while (!glfwWindowShouldClose(glfwWindow)) {
			glfwPollEvents();
			[renderer draw];
		}
		
		glfwDestroyWindow(glfwWindow);
		glfwTerminate();
	}
	return 0;
}
