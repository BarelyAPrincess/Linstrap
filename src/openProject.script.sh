#!/bin/null
# shellcheck shell=bash
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

# TODO Implement a project opening feature

PROJECT_NAME="default"
PROJECT_DIR="${APP_DATA}/${PROJECT_NAME}"

if [ -d "${PROJECT_DIR}" ]; then
    menuClear

    function buildKernelSource() {
        {
            echo "Starting Kernel Build..."


        } | dialog --programbox 0 0
    }

    menuAddOption "Build Kernel Source" "buildKernelSource"

    function showInitrdMenu() {
        run_script initrd "$@"
    }

    menuAddOption "Initrd" "showInitrdMenu"

    function showConfigurationMenu() {
        run_module entrypoint interviewer
    }

    menuAddOption "Configuration" "showConfigurationMenu"

    function deleteEntireProject() {
        PROMPT_DEFAULT="n"
        if prompt_yes_no "This function will delete all configuration and build files from the workspace. Do you wish to continue?"; then
            rm -rv "${PROJECT_DIR}" | dialog --progressbox 0 0
        fi
    }

    menuAddOption "Delete Entire Project" "deleteEntireProject"

    menuAddOption "< Back" ""

    menuShow
else
    msgbox "The project does not exist, run the New Project Wizard first."
fi