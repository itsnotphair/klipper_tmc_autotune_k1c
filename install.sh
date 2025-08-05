#!/bin/sh

KLIPPER_PATH_K1_DEFAULT="/usr/share/klipper"
KLIPPER_PATH=`curl localhost:7125/printer/info | jq -r .result.klipper_path`
AUTOTUNETMC_PATH="/usr/data/klipper_tmc_autotune"

set -eu
export LC_ALL=C

function check_download {
    local autotunedirname autotunebasename
    autotunedirname="$(dirname ${AUTOTUNETMC_PATH})"
    autotunebasename="$(basename ${AUTOTUNETMC_PATH})"

    if [ ! -d "${AUTOTUNETMC_PATH}" ]; then
        echo "[DOWNLOAD] Downloading Autotune TMC repository..."
        if git -C $autotunedirname clone https://github.com/evgarthub/klipper_tmc_autotune_k1.git $autotunebasename; then
            chmod +x ${AUTOTUNETMC_PATH}/install.sh
            chmod +x ${AUTOTUNETMC_PATH}/uninstall.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of Autotune TMC git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] Autotune TMC repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."

    if [ x"$KLIPPER_PATH" == x"null" ]; then
        KLIPPER_PATH=KLIPPER_PATH_K1_DEFAULT
        printf "Falling back to default klipper path: $KLIPPER_PATH\n"
    fi

    printf "Found klipper path: $KLIPPER_PATH\n"

    ln -sf "${AUTOTUNETMC_PATH}/autotune_tmc.py" "${KLIPPER_PATH}/klippy/extras/autotune_tmc.py"
    ln -sf "${AUTOTUNETMC_PATH}/motor_constants.py" "${KLIPPER_PATH}/klippy/extras/motor_constants.py"
    ln -sf "${AUTOTUNETMC_PATH}/motor_database.cfg" "${KLIPPER_PATH}/klippy/extras/motor_database.cfg"
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    /etc/init.d/S55klipper_service restart
}


printf "\n======================================\n"
echo "- Autotune TMC install script -"
printf "======================================\n\n"


# Run steps
check_download
link_extension
restart_klipper
