/**********************************************************************************************************************\
* Configuration for the keymap and its layers.                                                                         *
*                                                                                                                      *
* Copyright 2021-2022  Leandro Emmanuel Reina Kiperman <@kip93>                                                        *
*                                                                                                                      *
* This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public    *
* License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later *
* version.                                                                                                             *
*                                                                                                                      *
* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied   *
* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more         *
* details.                                                                                                             *
*                                                                                                                      *
* You should have received a copy of the GNU General Public License along with this program. If not, see               *
* <http://www.gnu.org/licenses/>.                                                                                      *
\**********************************************************************************************************************/

# pragma once


// ---------------------------------------------------- Handiness --------------------------------------------------- //
// https://docs.qmk.fm/#/config_options?id=setting-handedness

# define MASTER_LEFT

// ------------------------------------------------------- RGB ------------------------------------------------------ //
// https://docs.qmk.fm/#/feature_rgb_matrix
// https://github.com/qmk/qmk_firmware/tree/master/quantum/rgb_matrix_animations/

# ifdef RGB_MATRIX_ENABLE

// Global settings.
#     define RGB_DISABLE_WHEN_USB_SUSPENDED  true                    // Disable lighting when suspended.
#     define RGB_MATRIX_LED_FLUSH_LIMIT      (1000 / 24)             // 24 FPS animations.
#     define RGB_MATRIX_LED_PROCESS_LIMIT    (DRIVER_LED_TOTAL / 9)  // Limit LED effects' overhead.
#     define RGB_MATRIX_MAXIMUM_BRIGHTNESS   140                     // Max brightness (uint8_t, best if <= 150).
#     define RGB_MATRIX_DISABLE_KEYCODES                             // Disable default RGB controls.

// RGB effects.
#     define RGB_MATRIX_KEYPRESSES
#     define RGB_MATRIX_KEYRELEASES

#     define ENABLE_RGB_MATRIX_SOLID_COLOR
#     define ENABLE_RGB_MATRIX_SOLID_REACTIVE_SIMPLE

# endif  // RGB_MATRIX_ENABLE

// ----------------------------------------------------- Others ----------------------------------------------------- //

# define TAPPING_TERM  150

# define PERMISSIVE_HOLD
