#!/bin/bash

LOG=/tmp/my_git_key.log

XUSER=`ps aux | grep notify-osd | grep -v grep | awk '{print $1}'`

if [ -z "$XUSER" ]; then
    XUSER=localuser
fi

action=$1
DEV=$2
dev=$(echo $DEV | sed 's/[0-9]*//g')

SSH=/home/localuser/.ssh
GIT=/home/localuser/.gitconfig

STICK=/tmp/my_$dev
MNT=/mnt/my_$DEV

My_git=$MNT/My_git

echo "Event '$action' on $DEV, $dev. STICK=$STICK" >> $LOG

if [ "$action" == "add" ]; then
    echo "ADD" >> $LOG

    mkdir -p $MNT
    mount /dev/$DEV $MNT  2>&1 >> $LOG

    if [ -d "$My_git" ]; then
	    if [ -d "$SSH" ]; then
	        echo "Backup $SSH" >> $LOG
	        sudo -u localuser mv $SSH $SSH.sav
	    fi
	    if [ -e "$GIT" ]; then
	        echo "Backup $GIT" >> $LOG
	        sudo -u localuser mv $GIT $GIT.sav
	    fi
	    sudo -u localuser cp $My_git/.gitconfig $GIT
	    sudo -u localuser cp -a $My_git/.ssh $SSH
	    sudo -u localuser chmod 755 $SSH
	    sudo -u localuser chmod 600 $SSH/id_rsa

	    # We do not use authorized keys from the stick, if any
	    # but make public key as authorized
	    sudo cp $SSH/id_rsa.pub $SSH/authorized_keys

	    sudo -u localuser chmod 600 $SSH/authorized_keys
	    if [ -e $SSH/config ]; then 
	        sudo -u localuser chmod 600 $SSH/config
	    fi

	    # Mandatory on some configurations
	    ssh_socket=$(find /tmp -name keyring-* -type d -user localuser | tail -n 1)
	    echo ssh_socket=$ssh_socket >> $LOG
	    sudo -u localuser bash -c "export SSH_AUTH_SOCK=$ssh_socket/ssh; ssh-add"

	    # Disables StrictHostKeyChecking
	    printf "Host *\n" >> $SSH/config
	    printf "\tStrictHostKeyChecking no\n" >> $SSH/config

	    WHO=$(cat $GIT | grep name | cut -d'=' -f2 | sed -e 's/^[ \t]*//')
	    echo $WHO > $STICK
	    echo $WHO >> $LOG

	    CMD="DISPLAY=:0 notify-send -i $My_git/icon.png \"Clef Perso git\" \"Welcome, $WHO\""

	    su $XUSER -c "$CMD"
    fi

    umount $MNT 2>&1  >> $LOG
    rmdir $MNT 2>&1  >> $LOG
fi

if [ "$action" == "remove" ]; then
    echo "REMOVE" >> $LOG
    if [ "$DEV" == "$dev" ]; then
        if [ -e "$STICK" ]; then
	        echo "Was a My git key, cleanup" >> $LOG
	        WHO=$(cat $STICK)
	        rm -f $STICK
	        rm -rf $SSH
	        rm -f $GIT
	        if [ -d "$SSH.sav" ]; then
		        echo "Restore $SSH" >> $LOG
		        sudo -u localuser mv $SSH.sav $SSH
	        fi
	        if [ -e "$GIT.sav" ]; then
		        echo "Restore $GIT" >> $LOG
		        sudo -u localuser mv $GIT.sav $GIT
	        fi
	        CMD="DISPLAY=:0 notify-send \"Clef Perso git\" \"Bye, $WHO\"" 
	        su $XUSER -c "$CMD"
	    fi
    fi
fi

echo "END" >> $LOG
