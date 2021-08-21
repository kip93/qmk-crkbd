/**********************************************************************************************************************\
* Tap dance definitions.                                                                                               *
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

// https://docs.qmk.fm/#/feature_tap_dance

# pragma once

# include QMK_KEYBOARD_H


// Tap dance declarations.
enum {
    CONTROL_SHIFT = 0,
};

// Aliases.
enum {
    C_S = CONTROL_SHIFT,
};

// Tap dance definitions.
qk_tap_dance_action_t tap_dance_actions[] = {
    [CONTROL_SHIFT] = ACTION_TAP_DANCE_DOUBLE(KC_LCTL, KC_LSFT),
};
