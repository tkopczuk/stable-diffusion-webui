#!/bin/bash
#
# Starts the gui inside the docker container using the conda env
#

# set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
export PYTHONPATH=$SCRIPT_DIR

# Conda environment installs/updates
# @see https://github.com/ContinuumIO/docker-images/issues/89#issuecomment-467287039
ENV_NAME="ldm"
ENV_FILE="${SCRIPT_DIR}/environment.yaml"

# activate conda env
. /opt/conda/etc/profile.d/conda.sh
conda activate $ENV_NAME
conda info | grep active

# Launch web gui
if [[ ! -z $WEBUI_SCRIPT && $WEBUI_SCRIPT == "webui_streamlit.py" ]]; then
    launch_command="streamlit run scripts/${WEBUI_SCRIPT:-webui.py} $WEBUI_ARGS"
else
    launch_command="python scripts/${WEBUI_SCRIPT:-webui.py} $WEBUI_ARGS"
fi

launch_message="entrypoint.sh: Run ${launch_command}..."
if [[ -z $WEBUI_RELAUNCH || $WEBUI_RELAUNCH == "true" ]]; then
    n=0
    while true; do
        echo $launch_message

        if (( $n > 0 )); then
            echo "Relaunch count: ${n}"
        fi

        $launch_command

        echo "entrypoint.sh: Process is ending. Relaunching in 0.5s..."
        ((n++))
        sleep 0.5
    done
else
    echo $launch_message
    $launch_command
fi
