#!/bin/sh
cd ${1?} && {
    directory=.
    for kind in ca tlsca; do
      for dir in $(find $directory -type d -name $kind); do (
          cd $dir && for file in $kind.*.pem ; do
            ln -vfs *_sk ${file%.pem}.key
          done 
      ); done
    done
    for dir in $(find $directory -type d -name admincerts); do (
        if [[ -d ${dir%/*}/keystore ]] ; then
            cd $dir && for file in *.pem ; do
                ( cd ../keystore && ln -vfs *_sk ${file%.pem}.key )
            done 
         fi
    ); done
}



