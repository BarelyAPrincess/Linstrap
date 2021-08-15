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

{
    is_verbose && set -x

    ### Initialize Project Metadata ###

    # TODO Put project prompt
    PROJECT_NAME="HoneyPotLinux"

    PROJECT_DIR="${APP_PROJECTS}/${PROJECT_NAME}"

    # TODO Check project directory and determine the status of the project; prompt to override and etc.

    mkdir -vp "${PROJECT_DIR}" 2>/dev/null

    READY_TO_BUILD=$(yes)

    ### Initializing Project Kernel ###

    ob_start "Initializing Project Kernel"

    # shellcheck source=./Projects/HoneyPotLinux/kernel.conf
    . "${PROJECT_DIR}/kernel.conf" 2>/dev/null || echo "kernel.conf does not exist."

    # Kernel Type: [NONE], Use [PREBUILD] (Specified Kernel Binary), Use [HOST], Clone from [GIT]Hub Repository (Vanilla or Linstrap versions), from [TAR] download.
    KERNEL_TYPE="${KERNEL_TYPE:-GIT}"

    KERNEL_DIR=${PROJECT_DIR}/Kernel

    # TODO Create is needed only, git and tar should be the only ones that will need a location to store the kernel source code.
    mkdir -vp "${KERNEL_DIR}" 2>/dev/null

    if [ "${KERNEL_TYPE,,}" == "none" ]; then
        echo "Kernel is set to 'NONE', this script will stop at the building stage."; # Warning
        READY_TO_BUILD=$(no)
    fi

    # PREBUILD - Specify location of each kernel file, i.e., bzImage, VMLinuz, Initrd, Config, System
    KERNEL_PREBUILD_KERNEL="${KERNEL_PREBUILD_KERNEL:-}"
    KERNEL_PREBUILD_INITRD="${KERNEL_PREBUILD_INITRD:-}"
    KERNEL_PREBUILD_SYSTEM="${KERNEL_PREBUILD_SYSTEM:-}" # Optional
    KERNEL_PREBUILD_CONFIG="${KERNEL_PREBUILD_CONFIG:-}" # Optional

    if [ "${KERNEL_TYPE,,}" == "prebuild" ]; then
        echo "Kernel is set to 'PREBUILD'";
    fi

    # HOST
    ## Try to automatically detect the running kernel file, otherwise prompt with a list.
    ## If "/boot" is missing, throw an error and suggest user uses the "PREBUILD" option instead.
    KERNEL_HOST_VERSION="$(uname -r)"

    KERNEL_HOST_KERNEL="${KERNEL_HOST_KERNEL:-}"
    KERNEL_HOST_SYSTEM="${KERNEL_HOST_SYSTEM:-}" # Optional
    KERNEL_HOST_CONFIG="${KERNEL_HOST_CONFIG:-}" # Optional

    if [ "${KERNEL_TYPE,,}" == "host" ]; then
        echo "Kernel is set to 'HOST'";

        # If var is not set, version does not match, or does not exist.
        if [ -z "${KERNEL_HOST_KERNEL}" ] || [[ "${KERNEL_HOST_KERNEL}" != "*${KERNEL_HOST_VERSION}*" ]] || [ ! -f "${KERNEL_HOST_KERNEL}" ]; then
            # SYSTEM and CONFIG are not required, so drop them just in case the kernel changes.
            KERNEL_HOST_SYSTEM=""
            KERNEL_HOST_CONFIG=""

            find "/boot" -name "*$(uname -r)*" | while read -r FILE; do
                case "${FILE}" in
                    *vmlinuz*|*bzimage*)
                        KERNEL_HOST_KERNEL="${FILE}"
                        ;;
                    *system*)
                        KERNEL_HOST_SYSTEM="${FILE}"
                        ;;
                    *config*)
                        KERNEL_HOST_CONFIG="${FILE}"
                        ;;
                esac
            done
        fi
    fi

    # GIT
    KERNEL_GIT_URL="${KERNEL_GIT_URL:-git@github.com:PenoaksDev/Linstrap-Kernel.git}"
    KERNEL_GIT_BRANCH="${KERNEL_GIT_BRANCH:-}"

    if [ "${KERNEL_TYPE,,}" == "git" ]; then
        echo "Kernel is set to 'GIT'";

        if [ -d "${KERNEL_DIR}/.git" ] && git -C "${KERNEL_DIR}" remote -v | grep -E "origin.+${KERNEL_GIT_URL}" &>/dev/null; then
            git -C "${KERNEL_DIR}" pull 2>&1 | prepend "GIT -->"
        else
            git -C "${KERNEL_DIR}" clone --branch "${KERNEL_GIT_BRANCH}" "${KERNEL_GIT_URL}" 2>&1 | prepend "GIT -->"
        fi
    fi

    # TAR
    KERNEL_TAR_URL="${KERNEL_TAR_URL:-https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.12.6.tar.xz}"

    if [ "${KERNEL_TYPE,,}" == "tar" ]; then
        echo "Kernel is set to 'TAR'";
    fi

    echo "Saving Kernel Confiration: "
    
    echo -en "#!/dev/null\n# shellcheck shell=bash\n### Kernel Configuration File. Created at $(date) ###\n\n" > "${PROJECT_DIR}/kernel.conf"
    declare -p | grep -E "KERNEL_[A-Z0-9]" | sort | tee -a "${PROJECT_DIR}/kernel.conf" | prepend "CONF -->"

    # Build kernel source code if there is any to build
    case "${KERNEL_TYPE,,}" in
        "git")
            {
                make -C "${KERNEL_DIR}" honeypot_defconfig 2>&1
                
            } | prepend "MAKE KERNEL -->"
            ;;
    esac

    ob_end "SUCCESS"

    exit 0

# Make Initrd - Simple
    
    echo "Creating a Black Initrd"

    INITRD_DIR="${PROJECT_DIR}/Initrd/"
    mkdir -pv "${INITRD_DIR}bin" "${INITRD_DIR}lib"

    # Create fake debian package manager
    mkdir -pv "${INITRD_DIR}var/lib/dpkg/"{updates,info}
    touch "${INITRD_DIR}var/lib/dpkg/"{status,info}

    echo "LINSTRAP_VERSION=${LINSTRAP_VERSION}" > "${INITRD_DIR}.version"

    apt reinstall --download-only -o "Dir::Cache::archives=${APP_CACHE}" busybox-static
    apt reinstall --download-only -o "Dir::Cache::archives=${APP_CACHE}" libklibc
    apt reinstall --download-only -o "Dir::Cache::archives=${APP_CACHE}" klibc-utils

    dpkg --root="${INITRD_DIR}" --unpack -- "${APP_CACHE}"/*.deb

    chroot "${INITRD_DIR}" /bin/busybox sh -c "for binary in \$(/bin/busybox --list); do [ \"\${binary}\" != \"busybox\" ] && ln -sv \"/bin/busybox\" \"/bin/\${binary}\"; done"

    # Remove any bloat files that were also installed
    cat "${INITRD_DIR}var/lib/dpkg/info/"*.list | while read -r ENTRY; do
        FILE="$(realpath --no-symlinks "${ENTRY:1}")"
        if [[ "${ENTRY}" =~ doc|man ]]; then
            while rm -dv "${FILE}"; do
                FILE=$(dirname "${FILE}")
            done
        fi
        unset FILE
    done

    INITRD_SCRIPTS="${INITRD_DIR}scripts/"

    ln "${APP_SRC}/impl.*.sh" "${INITRD_SCRIPTS}/"

    cp -rv "${${APP_DATA}scripts_initrd/*}" "${INITRD_SCRIPTS}"

    ln -s scripts/init init

    chmod a+x "${INITRD_SCRIPTS}"*

    ### Build Entire Project ###

    if is "${READY_TO_BUILD}"; then
        echo "Preparing to build the entire project."
    else
        echo "For one or more reasons the project is not in a ready state to be built. Check the previous logs for more information."
    fi
} # | dialog --programbox 40 100 # "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}"