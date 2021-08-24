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
    RGB_MODE,
    RGB_COLOUR,
};

// Aliases.
enum {
    KC_BSDL = BACKSPACE_DELETE,
    KC_RGBM = RGB_MODE,
    KC_RGBC = RGB_COLOUR,
};

// Macro definitions.
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case BACKSPACE_DELETE: {
            static bool control = false;
            if (record -> event.pressed) {
                control = get_mods() & MOD_MASK_CTRL;
                register_code(control ? KC_DEL : KC_BSPC);

            } else {
                unregister_code(control ? KC_DEL : KC_BSPC);
            }

            return false;
        }

        case RGB_MODE: {
            if (record -> event.pressed) {
                rgb_next_mode();
            }

            return false;
        }

        case RGB_COLOUR: {
            if (record -> event.pressed) {
                rgb_next_colour();
            }

            return false;
        }

        default: {
            return true;
        }
    }
}
