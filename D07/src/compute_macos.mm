#include "compute.h"
#include <fmt/base.h>

#import <Metal/Metal.h>

void print_compute_info()
{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (device == nil)
    {
        fmt::print("No Metal device found\n");
        return;
    }

    fmt::print("Platform: Metal\n");
    fmt::print("  [{}]\n", [[device name] UTF8String]);
}