/***************************************************************************************************************\
* Layer name declarations.                                                                                      *
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

#pragma once

////////////////////////////////////////////// Layer declarations ///////////////////////////////////////////////

enum {
    // MODE 1: Typing
    TYPING_0 = 0,
    TYPING_1,
    TYPING_2,

    // MODE 2: Gaming
    GAMING_0,
    GAMING_1,
};

//////////////////////////////////////////////////// Aliases ////////////////////////////////////////////////////
// Easier to put in the keymap

enum {
    T0 = TYPING_0,
    T1 = TYPING_1,
    T2 = TYPING_2,

    G0 = GAMING_0,
    G1 = GAMING_1,
};
