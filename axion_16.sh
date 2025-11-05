# Crave

. b*/*sh

export BUILD_USERNAME=alpha269 

export BUILD_HOSTNAME=android

export KBUILD_BUILD_USER=alpha269

export KBUILD_BUILD_HOST=android

export TZ=Asia/Kolkata

export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true

axion santoni user vanilla

m systemimage > system_build.txt

m vendorimage > vendor_build.txt

m bootimage > boot_build.txt

ax -b user
