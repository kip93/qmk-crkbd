/***************************************************************************************************************\
* RGB macro definitions.                                                                                        *
*                                                                                                               *
* Copyright 2021-2022  Leandro Emmanuel Reina Kiperman <@kip93>                                                 *
*                                                                                                               *
* This program is free software: you can redistribute it and/or modify it under the terms of the GNU General    *
* Public License as published by the Free Software Foundation, either version 3 of the License, or (at your     *
* option) any later version.                                                                                    *
*                                                                                                               *
* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the    *
* implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License   *
* for more details.                                                                                             *
*                                                                                                               *
* You should have received a copy of the GNU General Public License along with this program. If not, see        *
* <http://www.gnu.org/licenses/>.                                                                               *
\***************************************************************************************************************/

// https://docs.qmk.fm/#/feature_macros
// https://docs.qmk.fm/#/feature_rgb_matrix

#pragma once

#include QMK_KEYBOARD_H

void rgb_next_colour(void) {
    static uint8_t       colour = 0;
    static const uint8_t hues[] = {
        0x80, // Cyan.
        0xEB, // Magenta.
        0x03, // Orange.

        0x00, // White.
    };

    uint8_t hue        = hues[colour];
    uint8_t saturation = colour < sizeof(hues) - 1 ? 0xFF : 0x00;
    uint8_t value      = 0xFF;
    rgblight_sethsv_noeeprom(hue, saturation, value);

    colour = (colour + 1) % sizeof(hues);
}

void rgb_next_mode(void) {
    static uint8_t       mode    = 0;
    static const uint8_t modes[] = {
        RGB_MATRIX_SOLID_REACTIVE_SIMPLE,
        RGB_MATRIX_SOLID_COLOR,
        RGB_MATRIX_CUSTOM_OFF,
    };

    rgblight_mode_noeeprom(modes[mode]);

    mode = (mode + 1) % sizeof(modes);
}
