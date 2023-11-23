#! /bin/sh

# BE CREATION
[ ${?} -eq 0 -a -e ./verbsd-base-be.sh       ] && ./verbsd-base-be.sh

# DIST FILES FETCH AND VERIFY
[ ${?} -eq 0 -a -e ./verbsd-base-fetch.sh    ] && ./verbsd-base-fetch.sh

# EXTRACT DIST FILES
[ ${?} -eq 0 -a -e ./verbsd-base-extract.sh  ] && ./verbsd-base-extract.sh

# INSTALL PACKAGES
[ ${?} -eq 0 -a -e ./verbsd-packages.sh      ] && ./verbsd-packages.sh

# CREATE USER
[ ${?} -eq 0 -a -e ./verbsd-user-create.sh   ] && ./verbsd-user-create.sh

# CONFIGS FETCH
[ ${?} -eq 0 -a -e ./verbsd-configs-fetch.sh ] && ./verbsd-configs-fetch.sh

# CONFIGS SYSTEM
[ ${?} -eq 0 -a -e ./verbsd-configs-sys.sh   ] && ./verbsd-configs-sys.sh

# CONFIGS USER
[ ${?} -eq 0 -a -e ./verbsd-configs-user.sh  ] && ./verbsd-configs-user.sh

# COMPAT UBUNTU
[ ${?} -eq 0 -a -e ./verbsd-compat-ubuntu.sh ] && ./verbsd-compat-ubuntu.sh
