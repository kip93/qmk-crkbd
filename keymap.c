/**********************************************************************************************************************\
* Keymap definition.                                                                                                   *
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

// https://docs.qmk.fm/#/keymap
// https://docs.qmk.fm/#/keycodes

# include QMK_KEYBOARD_H

# include "layers.h"
# include "macros.h"
# include "rgb_macros.h"
# include "tapdance.h"


const uint16_t keymaps[][MATRIX_ROWS][MATRIX_COLS] PROGMEM = {

//////////////////////////////////////////////////////// Typing ////////////////////////////////////////////////////////

// ----------------------------------------------------- 0: Text ---------------------------------------------------- //

    [TYPING_0] = LAYOUT_split_3x6_3(
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,        KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSDL,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_ESC,  KC_A,    KC_S,    KC_D,    KC_F,    KC_G,        KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_APP,  KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,        KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_BSLS,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
                             TD(LCS), LT(T1,KC_SPC), KC_LALT,     KC_LGUI, LT(T2,KC_ENT), TD(RCS)
//                          +--------+--------------+--------+   +--------+--------------+--------+
    ),

// -------------------------------------------------- 1: Others #1 -------------------------------------------------- //

// - - - - - - - - - - - - - - - - Functions  - - - - - - - - - - - - - - - -  Numpad - - - - - - - - - - - - - - - - //

    [TYPING_1] = LAYOUT_split_3x6_3(
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_F1,   KC_F4,   KC_F7,   KC_F10,  KC_PSCR, KC_INS,      KC_NLCK, KC_P7,   KC_P8,   KC_P9,   KC_PMNS, KC_PSLS,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_F2,   KC_F5,   KC_F8,   KC_F11,  KC_HOME, KC_PGUP,     KC_PDOT, KC_P4,   KC_P5,   KC_P6,   KC_PPLS, KC_PAST,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_F3,   KC_F6,   KC_F9,   KC_F12,  KC_END,  KC_PGDN,     KC_P0,   KC_P1,   KC_P2,   KC_P3,   KC_PENT, KC_PEQL,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
                                   KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, TO(G0),  KC_TRNS
//                                +--------+--------+--------+   +--------+--------+--------+
    ),

// -------------------------------------------------- 2: Others #2 -------------------------------------------------- //

// - - - - - - - - - - - - - - Numbers & symbols - - - - - - - - - - - - - - - - Specials - - - - - - - - - - - - - - //

    [TYPING_2] = LAYOUT_split_3x6_3(
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_GRV,      KC_MPRV, KC_VOLD, KC_VOLU, KC_MNXT, KC_MSTP, KC_CAPS,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS,     KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_MPLY, KC_BRIU,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_CUT,  KC_COPY, KC_PSTE, KC_LBRC, KC_RBRC, KC_EQL,      KC_RGBM, KC_RGBC, KC_UNDO, KC_AGIN, KC_MUTE, KC_BRID,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
                                   KC_TRNS, TO(G0),  KC_TRNS,     KC_TRNS, KC_TRNS, KC_TRNS
//                                +--------+--------+--------+   +--------+--------+--------+
    ),

//////////////////////////////////////////////////////// Gaming ////////////////////////////////////////////////////////

// ---------------------------------------------------- 0: Basic ---------------------------------------------------- //

// - - - - - - - - - - - WASD & other basics - - - - - - - - - - - - - - Extended #1 (optional) - - - - - - - - - - - //

    [GAMING_0] = LAYOUT_split_3x6_3(
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_ESC,  KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,        KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_PGUP,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_J,    KC_LSFT, KC_A,    KC_S,    KC_D,    KC_F,        KC_6,    KC_7,    KC_8,     KC_9,   KC_0,    KC_PGDN,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_M,    KC_LCTL, KC_Z,    KC_X,    KC_C,    KC_V,        KC_MINS, KC_COMM, KC_DOT,  KC_SCLN, KC_SLSH, KC_BSLS,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
                                   MO(G1),  KC_LALT, KC_SPC,      KC_ENT,  KC_RALT, KC_RSFT
//                                +--------+--------+--------+   +--------+--------+--------+
    ),

// ---------------------------------------------------- 1: Extras --------------------------------------------------- //

// - - - - - - - - - - - - More keybindings - - - - - - - - - - - - -  Extended #2 (optional) - - - - - - - - - - - - //

    [GAMING_1] = LAYOUT_split_3x6_3(
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_TRNS, KC_TRNS, KC_L,    KC_TRNS, KC_T,    KC_O,        KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_P,    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_G,        KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_HOME, KC_END,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
        KC_I,    KC_TRNS, KC_B,     KC_N,   KC_H,    KC_K,        KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,
//     +--------+--------+--------+--------+--------+--------+   +--------+--------+--------+--------+--------+--------+
                                   KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, TO(T0)
//                                +--------+--------+--------+   +--------+--------+--------+
    ),
};

void keyboard_post_init_user (void) {
    rgblight_enable_noeeprom();         // Enable LEDs.
    rgb_next_colour();                  // Set colour
    rgb_next_mode();                    // Set effect.

    rgblight_set_speed_noeeprom(0x40);  // Set speed (~1.5s).
}
