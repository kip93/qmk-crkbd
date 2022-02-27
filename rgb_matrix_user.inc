/***************************************************************************************************************\
* Custom matrix effects.                                                                                        *
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

// https://docs.qmk.fm/#/feature_rgb_matrix?id=custom-rgb-matrix-effects


RGB_MATRIX_EFFECT(OFF)
# ifdef RGB_MATRIX_CUSTOM_EFFECT_IMPLS
    static bool OFF(effect_params_t *params) {
        RGB_MATRIX_USE_LIMITS(led_min, led_max);
        for (uint8_t i = led_min; i < led_max; ++i) {
            rgb_matrix_set_color(i, 0x00, 0x00, 0x00);
        }

        return led_max < DRIVER_LED_TOTAL;
    }
# endif // RGB_MATRIX_CUSTOM_EFFECT_IMPLS
