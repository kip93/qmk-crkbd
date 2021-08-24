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
    CONTROL_SHIFT_LEFT = 0,
    CONTROL_SHIFT_RIGHT,
};

// Aliases.
enum {
    LCS = CONTROL_SHIFT_LEFT,
    RCS = CONTROL_SHIFT_RIGHT,
};

// Tap dance definitions.
qk_tap_dance_action_t tap_dance_actions[] = {
    [CONTROL_SHIFT_LEFT]  = ACTION_TAP_DANCE_DOUBLE(KC_LCTL, KC_LSFT),
    [CONTROL_SHIFT_RIGHT] = ACTION_TAP_DANCE_DOUBLE(KC_RCTL, KC_RSFT),
};
