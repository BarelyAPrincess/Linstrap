#
##############################################################################
##  This software may be modified and distributed under the terms
##  of the MIT license.  See the LICENSE file for details.
##
##  Unless required by applicable law or agreed to in writing,
##  software distributed under the License is distributed on an
##  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
##  KIND, either express or implied.  See the License for the
##  specific language governing permissions and limitations
##  under the License.
##
##  Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
##  Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
##
##  Linstrap: Linux OS Bootstrapping and Launcher for UN*X
##############################################################################
#

echo
echo "@1T@2h@3e@4 @5C@6o@7l@8o@9r Rainbow of Linstrap &-"
echo

declare -a MSGBOX_TEXT;
MSGBOX_TEXT+=( "$_WHITE  &0        $_BLACK Dark Black" )
MSGBOX_TEXT+=( "$_WHITE  &4        $_DARK_RED Dark Red" )
MSGBOX_TEXT+=( "$_WHITE  &2        $_DARK_GREEN Dark Green" )
MSGBOX_TEXT+=( "$_WHITE  &6        $_DARK_YELLOW Dark Yellow" )
MSGBOX_TEXT+=( "$_WHITE  &1        $_DARK_BLUE Dark Blue" )
MSGBOX_TEXT+=( "$_WHITE  &5        $_DARK_MAGENTA Dark Magenta" )
MSGBOX_TEXT+=( "$_WHITE  &3        $_DARK_CYAN Dark Cyan" )
MSGBOX_TEXT+=( "$_WHITE  &7        $_GRAY Gray" )
MSGBOX_TEXT+=( "$_WHITE  &8        $_DARK_GRAY Dark Gray" )
MSGBOX_TEXT+=( "$_WHITE  &Cc       $_RED Red" )
MSGBOX_TEXT+=( "$_WHITE  &Aa       $_GREEN Green" )
MSGBOX_TEXT+=( "$_WHITE  &Ee       $_YELLOW Yellow" )
MSGBOX_TEXT+=( "$_WHITE  &9        $_BLUE Blue" )
MSGBOX_TEXT+=( "$_WHITE  &Dd       $_MAGENTA Magenta" )
MSGBOX_TEXT+=( "$_WHITE  &Bb       $_CYAN Cyan" )
MSGBOX_TEXT+=( "$_WHITE  &Ff       White" )

declare -g MSGBOX_ALIGNMENT=0
declare -g MSGBOX_COLOR=$CODE_GOOD
declare -g MSGBOX_WIDTH=40
declare -g MSGBOX_TITLE="Foreground Colors"
generate_msgbox

declare -a MSGBOX_TEXT;
MSGBOX_TEXT+=( "$_WHITE  @0        $_BG_BLACK Black " )
MSGBOX_TEXT+=( "$_WHITE  @4        $_BG_DARK_RED Dark Red " )
MSGBOX_TEXT+=( "$_WHITE  @2        $_BG_DARK_GREEN Dark Green " )
MSGBOX_TEXT+=( "$_WHITE  @6        $_BG_DARK_YELLOW Dark Yellow " )
MSGBOX_TEXT+=( "$_WHITE  @1        $_BG_DARK_BLUE Dark Blue " )
MSGBOX_TEXT+=( "$_WHITE  @5        $_BG_DARK_MAGENTA Dark Magenta " )
MSGBOX_TEXT+=( "$_WHITE  @3        $_BG_DARK_CYAN Dark Cyan " )
MSGBOX_TEXT+=( "$_WHITE  @7        $_BG_GRAY Gray " )
MSGBOX_TEXT+=( "$_WHITE  @8        $_BG_DARK_GRAY Dark Gray " )
MSGBOX_TEXT+=( "$_WHITE  @Cc       $_BG_RED Red " )
MSGBOX_TEXT+=( "$_WHITE  @Aa       $_BG_GREEN Green " )
MSGBOX_TEXT+=( "$_WHITE  @Ee       $_BLACK$_BG_YELLOW Yellow " )
MSGBOX_TEXT+=( "$_WHITE  @9        $_BG_BLUE Blue " )
MSGBOX_TEXT+=( "$_WHITE  @Dd       $_BG_MAGENTA Magenta " )
MSGBOX_TEXT+=( "$_WHITE  @Bb       $_BG_AQUA Cyan " )
MSGBOX_TEXT+=( "$_WHITE  @Ff       $_BLACK$_BG_WHITE White " )

declare -g MSGBOX_ALIGNMENT=0
declare -g MSGBOX_COLOR=$CODE_GOOD
declare -g MSGBOX_WIDTH=40
declare -g MSGBOX_TITLE="Background Colors"
generate_msgbox

declare -a MSGBOX_TEXT;
MSGBOX_TEXT+=( "$_WHITE  &Ll       $_BOLD Bold " )
MSGBOX_TEXT+=( "$_WHITE  &Zz       $_FAINT Obscure " )
MSGBOX_TEXT+=( "$_WHITE  &Nn       $_UNDERLINE Underline " )
MSGBOX_TEXT+=( "$_WHITE  &Kk       $_MAGIC Magic " )
MSGBOX_TEXT+=( "$_WHITE  &Xx       $_NEGATIVE Negative " )
MSGBOX_TEXT+=( "$_WHITE  &Mm       $_HIDDEN Hidden " )
MSGBOX_TEXT+=( "$_WHITE  &Rr       Reset Color " )
MSGBOX_TEXT+=( "$_WHITE  @Rr       Reset Attribute " )
MSGBOX_TEXT+=( "$_WHITE  &-        Reset All " )

declare -g MSGBOX_ALIGNMENT=0
declare -g MSGBOX_COLOR=$CODE_GOOD
declare -g MSGBOX_WIDTH=40
declare -g MSGBOX_TITLE="Special Attributes"
generate_msgbox
