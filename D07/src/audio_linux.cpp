#include "audio.h"
#include <cstdlib>
#include <fmt/core.h>
#include <alsa/asoundlib.h>

void print_audio_info()
{
    fmt::print("Backend: ALSA {}\n", snd_asoundlib_version());

    int card = -1;
    while (snd_card_next(&card) == 0 && card >= 0)
    {
        char* name = nullptr;
        if (snd_card_get_name(card, &name) == 0)
        {
            fmt::print("  [{}] {}\n", card, name);
            free(name);
        }
    }
}
