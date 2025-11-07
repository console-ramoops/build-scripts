# Crave

. b*/*sh

sudo ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5

sudo ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6   /usr/lib/x86_64-linux-gnu/libtinfo.so.5

export BUILD_USERNAME=alpha269 

export BUILD_HOSTNAME=android

export KBUILD_BUILD_USER=alpha269

export KBUILD_BUILD_HOST=android

export TZ=Asia/Kolkata

lunch lineage_santoni-user

m bacon && bash upload.sh || bash fail.sh
