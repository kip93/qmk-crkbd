/**********************************************************************************************************************\
* Macro definitions.                                                                                                   *
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

// https://docs.qmk.fm/#/feature_macros

# pragma once

# include QMK_KEYBOARD_H

# include "rgb_macros.h"


// Macro declarations.
enum {
    BACKSPACE_DELETE = SAFE_RANGE,
    BACKSPACE_ESCAPE,
    RGB_MODE,
    RGB_COLOUR,
};

// Aliases.
enum {
    KC_BSDL = BACKSPACE_DELETE,
    KC_BSES = BACKSPACE_ESCAPE,
    KC_RGBM = RGB_MODE,
    KC_RGBC = RGB_COLOUR,
};


void custom_modifier(keyrecord_t *record, uint8_t mask, uint16_t kc1, uint16_t kc2) {
    static bool modifiers = false;
    if (record -> event.pressed) {
        modifiers = get_mods() & mask;
        register_code(modifiers ? kc2 : kc1);

    } else {
        unregister_code(modifiers ? kc2 : kc1);
    }
}

// Macro definitions.
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case BACKSPACE_DELETE: {
            custom_modifier(record, MOD_MASK_SHIFT, KC_BSPC, KC_DEL);
        }

        case BACKSPACE_ESCAPE: {
            custom_modifier(record, MOD_MASK_CTRL, KC_BSPC, KC_ESC);
        }

        case RGB_MODE: {
            if (record -> event.pressed) {
                rgb_next_mode();
            }
        }

        case RGB_COLOUR: {
            if (record -> event.pressed) {
                rgb_next_colour();
            }
        }

        default: {
            return true;
        }
    }

    return false;
}
