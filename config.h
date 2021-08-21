/**********************************************************************************************************************\
* Configuration for the keymap and its layers.                                                                         *
*                                                                                                                      *
* Copyright 2021  Leandro Emmanuel Reina Kiperman <@kip93>                                                             *
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
#     define RGB_DISABLE_WHEN_USB_SUSPENDED  true                          // Disable lighting when suspended.
#     define RGB_MATRIX_LED_FLUSH_LIMIT      (1000 / 60)                   // 24 FPS animations.
#     define RGB_MATRIX_LED_PROCESS_LIMIT    ((DRIVER_LED_TOTAL + 4) / 5)  // Limit LED effects' overhead.
#     define RGB_MATRIX_MAXIMUM_BRIGHTNESS   150                           // Max brightness (uint8_t, best if <= 150).
#     define RGB_MATRIX_DISABLE_KEYCODES                                   // Disable default RGB controls.

// Basic effects.
#     define DISABLE_RGB_MATRIX_ALPHAS_MODS
#     define DISABLE_RGB_MATRIX_BAND_PINWHEEL_SAT
#     define DISABLE_RGB_MATRIX_BAND_PINWHEEL_VAL
#     define DISABLE_RGB_MATRIX_BAND_SAT
#     define DISABLE_RGB_MATRIX_BAND_SPIRAL_SAT
#     define DISABLE_RGB_MATRIX_BAND_SPIRAL_VAL
#     define DISABLE_RGB_MATRIX_BAND_VAL
#     define DISABLE_RGB_MATRIX_BREATHING
#     define DISABLE_RGB_MATRIX_CYCLE_ALL
#     define DISABLE_RGB_MATRIX_CYCLE_LEFT_RIGHT
#     define DISABLE_RGB_MATRIX_CYCLE_OUT_IN
#     define DISABLE_RGB_MATRIX_CYCLE_OUT_IN_DUAL
#     define DISABLE_RGB_MATRIX_CYCLE_PINWHEEL
#     define DISABLE_RGB_MATRIX_CYCLE_SPIRAL
#     define DISABLE_RGB_MATRIX_CYCLE_UP_DOWN
#     define DISABLE_RGB_MATRIX_DUAL_BEACON
#     define DISABLE_RGB_MATRIX_GRADIENT_LEFT_RIGHT
#     define DISABLE_RGB_MATRIX_GRADIENT_UP_DOWN
#     define DISABLE_RGB_MATRIX_HUE_BREATHING
#     define DISABLE_RGB_MATRIX_HUE_PENDULUM
#     define DISABLE_RGB_MATRIX_HUE_WAVE
#     define DISABLE_RGB_MATRIX_JELLYBEAN_RAINDROPS
#     define DISABLE_RGB_MATRIX_RAINBOW_BEACON
#     define DISABLE_RGB_MATRIX_RAINBOW_MOVING_CHEVRON
#     define DISABLE_RGB_MATRIX_RAINBOW_PINWHEELS
#     define DISABLE_RGB_MATRIX_RAINDROPS

// Dynamic effects.
#     undef  RGB_MATRIX_FRAMEBUFFER_EFFECTS
#     define RGB_MATRIX_KEYPRESSES

#     define DISABLE_RGB_MATRIX_MULTISPLASH
#     define DISABLE_RGB_MATRIX_SOLID_MULTISPLASH
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_CROSS
#     undef  DISABLE_RGB_MATRIX_SOLID_REACTIVE_SIMPLE
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_MULTICROSS
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_MULTINEXUS
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_MULTIWIDE
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_NEXUS
#     define DISABLE_RGB_MATRIX_SOLID_REACTIVE_WIDE
#     define DISABLE_RGB_MATRIX_SOLID_SPLASH
#     define DISABLE_RGB_MATRIX_SPLASH

# endif  // RGB_MATRIX_ENABLE

// ----------------------------------------------------- Others ----------------------------------------------------- //

# define USE_SERIAL_PD2

# define TAPPING_TERM  180

# define PERMISSIVE_HOLD
