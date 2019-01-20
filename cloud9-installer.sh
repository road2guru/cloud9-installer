#!/bin/bash

INSTALL_PATH=${1:-$HOME}/c9sdk
BIN_PATH=$INSTALL_PATH/.c9
LOG_FILE=installation.log

echo -n "Enter installation path, default ($INSTALL_PATH): "
read custom_path
if [ -d "$custom_path" ]
then
	INSTALL_PATH=$custom_path
fi
	
echo "=== install path $INSTALL_PATH"

#
# get the core path
#
if [ ! -d "$INSTALL_PATH" ]; then
	git clone https://github.com/c9/core.git $INSTALL_PATH >> $LOG_FILE
fi

(
    cd $INSTALL_PATH
    git reset --hard  >> $LOG_FILE
    git fetch >> $LOG_FILE
)

#
# install scripts, by default set th install path to ~/.c9 - let's change it
#
vim -c '%s/ bash\>/ bash -s - -d $BIN_PATH/g | wq'          $INSTALL_PATH/scripts/install-sdk.sh
vim -c '%s/\~/$INSTALL_PATH/g | wq'                         $INSTALL_PATH/scripts/install-sdk.sh
vim -c '%s/C9_DIR="$HOME"/C9_DIR="$INSTALL_PATH"/g | wq'    $INSTALL_PATH/scripts/install-sdk.sh
vim -c '%s/updateCore /\# updateCore /g | wq'               $INSTALL_PATH/scripts/install-sdk.sh

#
# start installation
#
if [ $? -eq 0 ]; then
    BIN_PATH=$BIN_PATH INSTALL_PATH=$INSTALL_PATH $INSTALL_PATH/scripts/install-sdk.sh >> $LOG_FILE
else
    echo "Error! unable to continue! check $LOG_FILE for more detail."
fi

#
# some scripts, default path was set to ~/.c9. This is annoying, let's change it here
#
for i in `egrep -l "env\.HOME\>" $INSTALL_PATH -R | grep -E '\.js$|\.sh$|\.rc$'`
do
    echo $i
    rm -f "$(dirname ${i}.swp)*.swp"
    vim -c '%s/env.HOME\>/env.C9_DIR/g | wq' $i
done

cat << EOF > $INSTALL_PATH/bin/run.sh
#!/bin/bash

export PATH=$BIN_PATH/bin:$BIN_PATH/node/bin:$BIN_PATH/node_modules/.bin:$PATH
export C9_DIR="$INSTALL_PATH"

node $INSTALL_PATH/server.js \${@:1}

EOF
chmod 755 $INSTALL_PATH/bin/run.sh

echo "===================================================================="
echo "Installation completed."
echo "Start cloud9 by: $INSTALL_PATH/bin/run.sh [option]"
echo "===================================================================="
