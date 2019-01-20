#!/bin/bash

USR_DIR=${1:-$HOME}/c9sdk
BIN_DIR=/home/sdao/apps/c9ide-devel/.c9

echo -n "Enter installation path, default ($USR_DIR): "
read install_dir
if [ -d "$install_dir/c9sdk" ]
then
	USR_DIR=$install_dir
fi

export INSTALL_DIR=$USR_DIR
echo "=== install dir $INSTALL_DIR"

#
# get the core path
#
if [ -d "$INSTALL_DIR" ]; then
	git reset --hard
	git fetch
else
	git clone https://github.com/c9/core.git $INSTALL_DIR
fi

#
# install scripts, by default set th install path to ~/.c9 - let's change it
#
cd $INSTALL_DIR

git reset --hard	
	
vim -c '%s/ bash\>/ bash -s - -d $BIN_DIR/g | wq' $INSTALL_DIR/scripts/install-sdk.sh
vim -c '%s/\~/$INSTALL_DIR/g | wq' $INSTALL_DIR/scripts/install-sdk.sh
vim -c '%s/C9_DIR="$HOME"/C9_DIR="$INSTALL_DIR"/g | wq' $INSTALL_DIR/scripts/install-sdk.sh

cat $INSTALL_DIR/scripts/install-sdk.sh


#
# start installation
#
$INSTALL_DIR/scripts/install-sdk.sh

#
# some scripts, default path was set to ~/.c9. This is annoying, let's change it here
#
for i in `egrep -l "env\.HOME\>" $INSTALL_DIR -R | grep "\.js\$"`
do
    rm -f "$i.swp"
	vim -c '%s/env.HOME\>/env.C9_DIR/g | wq' $i
done

cat << EOF > bin/run.sh
#!/bin/bash

export PATH=$BIN_DIR/bin:$BIN_DIR/node/bin:$BIN_DIR/node_modules/.bin:$PATH
export C9_DIR="$INSTALL_DIR"

node $INSTALL_DIR/server.js -p 8181 ${@:2}

EOF
chmod 755 bin/run.sh

echo "===================================================================="
echo "done."
echo "===================================================================="

cd -

