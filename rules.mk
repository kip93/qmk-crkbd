########################################################################################################################
# Compilation configuration.                                                                                           #
#                                                                                                                      #
# Copyright 2021  Leandro Emmanuel Reina Kiperman <@kip93>                                                             #
#                                                                                                                      #
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public    #
# License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later #
# version.                                                                                                             #
#                                                                                                                      #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied   #
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more         #
# details.                                                                                                             #
#                                                                                                                      #
# You should have received a copy of the GNU General Public License along with this program. If not, see               #
# <http://www.gnu.org/licenses/>.                                                                                      #
########################################################################################################################

# Enable tap dance (https://docs.qmk.fm/#/feature_tap_dance).
TAP_DANCE_ENABLE  = yes

# Enable LEDs.
RGB_MATRIX_ENABLE       = yes
RGB_MATRIX_CUSTOM_USER  = yes

# Reduce compiled size.
LTO_ENABLE  = yes
