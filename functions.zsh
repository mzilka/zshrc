# @author       Martin Zilka
# @license    http://opensource.org/licenses/gpl-license.php
#
# original author  Sebastian Tramp <mail@sebastian.tramp.name>
# https://github.com/seebi/zshrc.git
#
# functions and key bindings to that functions
#

# strg+x,s adds sudo to the line
# Zsh Buch p.159 - http://zshbuch.org/
run-with-sudo() { LBUFFER="sudo $LBUFFER" }
zle -N run-with-sudo
bindkey '^Xs' run-with-sudo

# Top ten memory hogs
# http://www.commandlinefu.com/commands/view/7139/top-ten-memory-hogs
memtop() {ps -eorss,args | gsort -nr | gpr -TW$COLUMNS | ghead}
zle -N memtop

tmux-hglog() {
    tmux kill-pane -t 1
    tmux split-window -h -l 40 "while true; do clear; date; echo; hg xlog-small -l 5 || exit; sleep 600; done;"
    tmux select-pane -t 0
}

# tmux-neww-in-cwd - open a new shell with same cwd as calling pane
# http://chneukirchen.org/dotfiles/bin/tmux-neww-in-cwd
tmux-neww-in-cwd() {
    SIP=$(tmux display-message -p "#S:#I:#P")

    PTY=$(tmux server-info |
    egrep flags=\|bytes |
    awk '/windows/ { s = $2 }
    /references/ { i = $1 }
    /bytes/ { print s i $1 $2 } ' |
    grep "$SIP" |
    cut -d: -f4)

    PTS=${PTY#/dev/}

    PID=$(ps -eao pid,tty,command --forest | awk '$2 == "'$PTS'" {print $1; exit}')

    DIR=$(readlink /proc/$PID/cwd)

    tmux neww "cd '$DIR'; $SHELL"
}

# Escape potential tarbombs
# http://www.commandlinefu.com/commands/view/6824/escape-potential-tarbombs
etb() {
	l=$(tar tf $1);
	if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ];
	then tar xf $1;
	else mkdir ${1%.t(ar.gz||ar.bz2||gz||bz||ar)} && tar xvf $1 -C ${1%.t(ar.gz||ar.bz2||gz||bz||ar)};
	fi ;
}

# show newest files
# http://www.commandlinefu.com/commands/view/9015/find-the-most-recently-changed-files-recursively
newest () {find . -type f -printf '%TY-%Tm-%Td %TT %p\n' | grep -v cache | grep -v ".hg" | grep -v ".git" | sort -r | less }

# http://www.commandlinefu.com/commands/view/7294/backup-a-file-with-a-date-time-stamp
buf () {
    oldname=$1;
    if [ "$oldname" != "" ]; then
        datepart=$(date +%Y-%m-%d);
        firstpart=`echo $oldname | cut -d "." -f 1`;
        newname=`echo $oldname | sed s/$firstpart/$firstpart.$datepart/`;
        cp -R ${oldname} ${newname};
    fi
}
dobz2 () {
    name=$1;
    if [ "$name" != "" ]; then
        tar cvjf $1.tar.bz2 $1
    fi
}

atomtitles () { curl --silent $1 | xmlstarlet sel -N atom="http://www.w3.org/2005/Atom" -t -m /atom:feed/atom:entry -v atom:title -n}


function printHookFunctions () {
    print -C 1 ":::pwd_functions:" $chpwd_functions
    print -C 1 ":::periodic_functions:" $periodic_functions
    print -C 1 ":::precmd_functions:" $precmd_functions
    print -C 1 ":::preexec_functions:" $preexec_functions
    print -C 1 ":::zshaddhistory_functions:" $zshaddhistory_functions
    print -C 1 ":::zshexit_functions:" $zshexit_functions
}

# reloads all functions
# http://www.zsh.org/mla/users/2002/msg00232.html
r() {
    local f
    f=(~/.config/zsh/functions.d/*(.))
    unfunction $f:t 2> /dev/null
    autoload -U $f:t
}

# activates zmv
autoload zmv
# noglob so you don't need to quote the arguments of zmv
# mmv *.JPG *.jpg
alias mmv='noglob zmv -W'

# start a webcam for screencast
function webcam () {
    mplayer -cache 128 -tv driver=v4l2:width=350:height=350 -vo xv tv:// -noborder -geometry "+1340+445" -ontop -quiet 2>/dev/null >/dev/null
}

# Rename files in a directory in an edited list fashion
# http://www.commandlinefu.com/commands/view/7818/
function massmove () {
    ls > ls; paste ls ls > ren; vi ren; sed 's/^/mv /' ren|bash; rm ren ls
}


# Put a console clock in top right corner
# http://www.commandlinefu.com/commands/view/7916/
function clock () {
    while sleep 1;
    do
        tput sc
        tput cup 0 $(($(tput cols)-29))
        date
        tput rc
    done &
}

function apt-import-key () {
    gpg --keyserver subkeys.pgp.net --recv-keys $1 | gpg --armor --export $1 | sudo apt-key add -
}

# create a new script, automatically populating the shebang line, editing the
# script, and making it executable.
# http://www.commandlinefu.com/commands/view/8050/
shebang() {
    if i=$(which $1);
    then
        printf '#!/usr/bin/env %s\n\n' $1 > $2 && chmod 755 $2 && vim + $2 && chmod 755 $2;
    else
        echo "'which' could not find $1, is it in your \$PATH?";
    fi;
    # in case the new script is in path, this throw out the command hash table and
    # start over  (man zshbuiltins)
    rehash
}

# a rough equivalent to "hg out"
# http://www.doof.me.uk/2011/01/08/list-outgoing-changesets-in-git/
git-out() {
    for i in $(git push -n $* 2>&1 | awk '$1 ~ /[a-f0-9]+\.\.[a-f0-9]+/ { print $1; }')
    do
        git xlog $i
    done
}

# Query Wikipedia via console over DNS
# http://www.commandlinefu.com/commands/view/2829
wp() {
    dig +short txt ${1}.wp.dg.cx
}

# translate via google language tools (more lightweight than leo)
# http://www.commandlinefu.com/commands/view/5034/
translate() {
    wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$1&langpair=$2|${3:-en}" | sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
}

# cd to the root of the current vcs repository
gr() {
    # vcsroot=`echo $vcs_info_msg_0_ | cut -d "|" -f 5`
    vcsroot=`/home/seebi/.vim/scripts/vcsroot.sh`
    echo $vcsroot && cd $vcsroot
}

# delete-to-previous-slash
# http://www.zsh.org/mla/users/2005/msg01314.html
backward-delete-to-slash () {
  local WORDCHARS=${WORDCHARS//\//}
  zle .backward-delete-word
}
zle -N backward-delete-to-slash
# bind to control Y
bindkey "^Y" backward-delete-to-slash
# mz import
#Function Usage: doc packagename
        doc() { cd /usr/share/doc/$1 && ls }
        _doc() { _files -W /usr/share/doc -/ }
        compdef _doc doc
#Vyhladavanie v history
selhist() {
        emulate -L zsh
        local TAB=$'\t';
        (( $# < 1 )) && {
                echo "Usage: $0 command"
                return 1
        };
        cmd=(${(f)"$(grep -w $1 $HISTFILE | sort | uniq | pr -tn)"})
        print -l $cmd | less -F
        echo -n "enter number of desired command [1 - $(( ${#cmd[@]} - 1 ))]: "
        local answer
        read answer
        print -z "${cmd[$answer]#*$TAB}"
}
# mkdir && cd
        mcd() { mkdir -p "$@"; cd "$@" }  # mkdir && cd
# cd && ls
        cl() { cd $1 && la }
# make screenshot of current desktop (use 'import' from ImageMagic)
# sshot() {
#[[ ! -d ~/shots  ]] && mkdir ~/shots
#cd ~/shots ; sleep 5 ; import -window root -depth 8 -quality 80 `date "
#cd ~/shots ; sleep 5; import -window root shot_`date --iso-8601=m`.jpg
#}

# grep the history
greph () { history 0 | grep $1 }
(grep --help 2>/dev/null |grep -- --color) >/dev/null && \

# jump between directories
# # Copyright 2005 Nikolai Weibull <nikolai@bitwi.se>
# # notice: option AUTO_PUSHD has to be set
        d(){
        emulate -L zsh
        autoload -U colors
        local color=$fg_bold[blue]
        integer i=0
        dirs -p | while read dir; do
        local num="${$(printf "%-4d " $i)/ /.}"
        printf " %s  $color%s$reset_color\n" $num $dir
        (( i++ ))
        done
        integer dir=-1
        read -r 'dir?Jump to directory: ' || return
        (( dir == -1 )) && return
        if (( dir < 0 || dir >= i )); then
        echo d: no such directory stack entry: $dir
        return 1
        fi
        cd ~$dir && la
}
# Usage: simple-extract <file>
        simple-extract () {
        if [[ -f $1 ]]
        then
                case $1 in
                        *.tar.bz2)  bzip2 -v -d $1      ;;
                        *.tar.gz)   tar -xvzf   $1      ;;
                        *.rar)      unrar       $1      ;;
                        *.deb)      ar -x       $1      ;;
                        *.bz2)      bzip2 -d    $1      ;;
                        *.lzh)      lha x       $1      ;;
                        *.gz)       gunzip -d   $1      ;;
                        *.tar)      tar -xvf    $1      ;;
                        *.tgz)      gunzip -d   $1      ;;
                        *.tbz2)     tar -jxvf   $1      ;;
                        *.zip)      unzip       $1      ;;
                        *.Z)        uncompress  $1      ;;
                        *)          echo "'$1' Error. Please go away" ;;
                esac
                        else
                                    echo "'$1' is not a valid file"
 fi
}
# Usage: smartcompress <file> (<type>)
# Description: compresses files or a directory.  Defaults to tar.gz
smartcompress() {
        if [ $2 ]; then
                case $2 in
                        tgz | tar.gz)   tar -zcvf$1.$2 $1 ;;
                        tbz2 | tar.bz2) tar -jcvf$1.$2 $1 ;;
                        tar.Z)          tar -Zcvf$1.$2 $1 ;;
                        tar)            tar -cvf$1.$2  $1 ;;
                        gz | gzip)      gzip           $1 ;;
                        bz2 | bzip2)    bzip2          $1 ;;
                        *)
                        echo "Error: $2 is not a valid compression type"
                        ;;
                esac
        else
                smartcompress $1 tar.gz
        fi
}
# Usage: show-archive <archive>
# Description: view archive without unpack
show-archive() {
        if [[ -f $1 ]]
        then
                case $1 in
                        *.tar.gz)      gunzip -c $1 | tar -tf - -- ;;
                        *.tar)         tar -tf   $1 ;;
                        *.tgz)         tar -ztf  $1 ;;
                        *.zip)         unzip -l  $1 ;;
                        *.bz2)         bzless    $1 ;;
                        *)
                        echo "'$1' Error. Please go away" ;;
                esac
        else
                echo "'$1' is not a valid archive"
        fi
}
# Use 'view' to read manpages, if u want colors, regex - search, ...
# # like vi(m).
# # It's shameless stolen from <http://www.vim.org/tips/tip.php?tip_id=167>
vman() { man $* | col -b | view -c 'set ft=man nomod nolist' - }

status() {
        print ""
        print "Date..: "$(date "+%Y-%m-%d %H:%M:%S")""
        print "Shell.: Zsh $ZSH_VERSION (PID = $$, $SHLVL nests)"
        print "Term..: $TTY ($TERM), $BAUD bauds, $COLUMNS x $LINES cars"
        print "Login.: $LOGNAME (UID = $EUID) on $HOST"
        print "System: $(cat /etc/[A-Za-z]*[_-][rv]e[lr]*)"
        print "Uptime:$(uptime)"
        print ""
}
#--- FUNCTION ----------------------------------------------------------------
# NAME: sla_get_logs
# DESCRIPTION: Automatically downloads docker.log & SystemOut.log for
# given environment
# PARAMETERS: Account GCSC
# RETURNS: docker.log & SystemOut.log with timestamp in local folder
#-------------------------------------------------------------------------------
sla_get_logs () {
ACC=$*
TST=`TZ=UTC date +"%Y%m%d-%H%M_UTC"`
HST=`ssh $ACC-ee 'hostname|cut -d"-" -f3'`

ssh $ACC-ee "sudo docker cp xeng:/home/cobalt/xeng/cobalt/log/docker.log /tmp/docker-$HST-ee-xeng-$TST.log"
ssh $ACC-ee "sudo zip /tmp/docker-$HST-ee-xeng-$TST.log.zip /tmp/docker-$HST-ee-xeng-$TST.log"
ssh $ACC-ee "sudo chmod 755 /tmp/docker-$HST-ee-xeng-$TST.log.zip"
rsync --partial --progress --rsh=ssh $ACC-ee:/tmp/docker-$HST-ee-xeng-$TST.log.zip .
ssh $ACC-ee "sudo rm /tmp/docker-$HST-ee-xeng-$TST.log.zip /tmp/docker-$HST-ee-xeng-$TST.log"

ssh $ACC-bpm "sudo zip /tmp/SystemOut-$HST-bpm-$TST.log.zip /opt/IBM/WebSphere/AppServer/profiles/Node1Profile/logs/SingleClusterMember1/SystemOut.log"
ssh $ACC-bpm "sudo chmod 755 /tmp/SystemOut-$HST-bpm-$TST.log.zip"
rsync --partial --progress --rsh=ssh $ACC-bpm:/tmp/SystemOut-$HST-bpm-$TST.log.zip .
ssh $ACC-bpm "sudo rm /tmp/SystemOut-$HST-bpm-$TST.log.zip"
}
