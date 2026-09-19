#include "audio.h"
#include <fmt/core.h>
#include <portaudio.h>

void print_audio_info()
{
    if (Pa_Initialize() != paNoError)
    {
        fmt::print("Pa_Initialize failed\n");
        return;
    }

    fmt::print("Backend: {}\n", Pa_GetVersionInfo()->versionText);

    int count = Pa_GetDeviceCount();
    for (int i = 0; i < count; ++i)
    {
        const PaDeviceInfo* info = Pa_GetDeviceInfo(i);
        fmt::print("  [{}] {}\n", i, info->name);
    }

    Pa_Terminate();
}
