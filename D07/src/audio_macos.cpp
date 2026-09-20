#include "audio.h"
#include <fmt/core.h>
#include <CoreAudio/CoreAudio.h>

void print_audio_info()
{
    AudioObjectPropertyAddress addr = {
        kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    UInt32 size = 0;
    OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &addr, 0, nullptr, &size);
    if (status != noErr)
    {
        fmt::print("AudioObjectGetPropertyDataSize failed: {}\n", status);
        return;
    }

    fmt::print("Backend: CoreAudio\n");
    fmt::print("  {} audio devices\n", size / sizeof(AudioObjectID));
}
