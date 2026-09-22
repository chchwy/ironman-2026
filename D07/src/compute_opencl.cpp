#include "compute.h"
#include <fmt/base.h>

#define CL_TARGET_OPENCL_VERSION 300
#include <CL/cl.h>

#include <vector>

void print_compute_info()
{
    cl_uint platform_count = 0;
    clGetPlatformIDs(0, nullptr, &platform_count);

    std::vector<cl_platform_id> platforms(platform_count);
    clGetPlatformIDs(platform_count, platforms.data(), nullptr);

    for (cl_platform_id platform : platforms)
    {
        char platform_name[256] = {};
        clGetPlatformInfo(platform, CL_PLATFORM_NAME, sizeof(platform_name), platform_name, nullptr);
        fmt::print("Platform: {}\n", platform_name);

        cl_uint device_count = 0;
        clGetDeviceIDs(platform, CL_DEVICE_TYPE_ALL, 0, nullptr, &device_count);

        std::vector<cl_device_id> devices(device_count);
        clGetDeviceIDs(platform, CL_DEVICE_TYPE_ALL, device_count, devices.data(), nullptr);

        for (cl_device_id device : devices)
        {
            char device_name[256] = {};
            clGetDeviceInfo(device, CL_DEVICE_NAME, sizeof(device_name), device_name, nullptr);
            fmt::print("  [{}]\n", device_name);
        }
    }
}