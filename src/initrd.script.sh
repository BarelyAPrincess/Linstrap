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
# Do Not Directly Run

PROMPT_DEFAULT="q"
while :; do
  prompt_options_basic "Initrd Menu: What would you like to do?" q Quit b Back d Delete u Update s Setup p Pack c Chroot q Qemu
  case "$PROMPT_RESULT" in
    q)
      exit 0
      ;;
    b)
      PROMPT_NEXT=m
      break
      ;;
    d)
      if prompt_yes_no "This will delete the Initrd files, do you want to continue?"; then
        rm -r "$LINSTRAP_SOURCE_INITRD"
      fi
      ;;
    u)
      if [ -d "$LINSTRAP_SOURCE_INITRD/.git" ]; then
        git -C "$LINSTRAP_SOURCE_INITRD" pull
      else
        warningbox "Initrd is not using a git repository. Could it be a custom build?"
      fi
      ;;
    s)
      if [ -z "$(ls -A "$LINSTRAP_SOURCE_INITRD")" ]; then
        read -p "What initrd branch would you like to setup? [e.g., \"bleeding\", \"stable\", \"custom\"] " PACK
        case $PACK in
          "custom")
            run_module initrd custom
            ;;
          "bleeding" | "stable")
            git clone git@github.com:PenoaksDev/Linstrap-Stencils.git -b "initrd-$PACK" "$LINSTRAP_SOURCE_INITRD"
            msgbox "The git repository has been successfully cloned."
            ;;
          *)
            warningbox "Please enter a valid initrd branch."
            ;;
        esac
      else
        warningbox "The Initrd directory is not empty. If you want to continue, please delete the contents first."
      fi
        ;;
    p)
      run_module initrd pack
      ;;
    c)
      run_module initrd chroot
      ;;
    *)
      warningbox "That is not a valid option."
      ;;
  esac
  unset PROMPT_RESULT
done
