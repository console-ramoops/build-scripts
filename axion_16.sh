# Crave

. b*/*sh

export BUILD_USERNAME=alpha269 

export BUILD_HOSTNAME=android

export KBUILD_BUILD_USER=alpha269

export KBUILD_BUILD_HOST=android

export TZ=Asia/Kolkata

export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true

axion santoni user vanilla

ax -b user 2>&1 | tee bacon_build.log || \
  (m systemimage 2>&1 | tee system_build.log && \
   m vendorimage 2>&1 | tee vendor_build.log && \
   m bootimage 2>&1 | tee boot_build.log)
