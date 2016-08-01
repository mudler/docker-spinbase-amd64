#!/bin/bash

FILES_TO_REMOVE=(
   "/.viminfo"
   "/.history"
   "/.zcompdump"
   "/var/log/emerge.log"
   "/var/log/emerge-fetch.log"
   "/etc/env.d/02locale"
   "/etc/locale.conf"
)

PACKAGES_TO_ADD=(
    "app-eselect/eselect-bzimage"
    "app-editors/nano"
    "app-admin/sudo"
    "sys-process/procps"
    "app-text/pastebunz"
    "app-admin/perl-cleaner"
    "sys-apps/grep"
    "sys-apps/busybox"
    "app-misc/sabayon-live"
    "sys-boot/grub:2"
    "dev-lang/perl"
    "dev-lang/python"
    "sys-devel/binutils"
    "app-misc/sabayon-version"
    "x11-themes/sabayon-artwork-grub"
    "app-crypt/gnupg"
    "x11-themes/sabayon-artwork-isolinux"
    "app-crypt/shim-signed"
    "dev-perl/Module-Build"
    "net-misc/networkmanager"
    "sys-auth/nss-mdns"
)

# Make sure we have /boot/grub before installing
# sabayon-artwork-grub (so that it's able to copy
# the splash over to the correct location)
mkdir -p /boot/grub

# Handling install/removal of packages specified in env

equo repo mirrorsort sabayonlinux.org
equo up

#equo i $(cat /etc/sabayon-pkglist | xargs echo)
equo i "${PACKAGES_TO_ADD[@]}"

#small cleanup
#equo rm --nodeps gnome-base/gsettings-desktop-schemas sys-libs/db:4.8

# Cleaning accepted licenses
rm -rf /etc/entropy/packages/license.accept

# Configure glibc locale, ship image with all locales enabled
# or anaconda will crash if the user selects an unsupported one
echo '
# /etc/locale.gen: list all of the locales you want to have on your system
#
# The format of each line:
# <locale> <charmap>
#
# Where <locale> is a locale located in /usr/share/i18n/locales/ and
# where <charmap> is a charmap located in /usr/share/i18n/charmaps/.
#
# All blank lines and lines starting with # are ignored.
#
# For the default list of supported combinations, see the file:
# /usr/share/i18n/SUPPORTED
#
# Whenever glibc is emerged, the locales listed here will be automatically
# rebuilt for you.  After updating this file, you can simply run `locale-gen`
# yourself instead of re-emerging glibc.
' > /etc/locale.gen
cat /usr/share/i18n/SUPPORTED >> /etc/locale.gen
/usr/sbin/locale-gen

# Upgrading kernel to latest version
kernel_target_pkg="sys-kernel/linux-sabayon"

available_kernel=$(equo match "${kernel_target_pkg}" -q --showslot)
echo
echo "@@ Upgrading kernel to ${available_kernel}"
echo
kernel-switcher switch "${available_kernel}" || exit 1

# now delete stale files in /lib/modules
for slink in $(find /lib/modules/ -type l); do
    if [ ! -e "${slink}" ]; then
        echo "Removing broken symlink: ${slink}"
        rm "${slink}" # ignore failure, best effort
        # check if parent dir is empty, in case, remove
        paren_slink=$(dirname "${slink}")
        paren_children=$(find "${paren_slink}")
        if [ -z "${paren_children}" ]; then
            echo "${paren_slink} is empty, removing"
            rmdir "${paren_slink}" # ignore failure, best effort
        fi
    fi
done

# Setting bzimage
eselect bzimage set 1

# Merging defaults configurations
echo -5 | equo conf update

# Cleanup Perl cruft
perl-cleaner --ph-clean

# Cleaning equo package cache
equo cleanup

# Writing package list file
equo q list installed -qv > /etc/sabayon-pkglist

# remove SSH keys
rm -rf /etc/ssh/*_key*

# Needed by systemd, because it doesn't properly set a good
# encoding in ttys. Test it with (on tty1, VT1):
# echo -e "\xE2\x98\xA0"
# TODO: check if the issue persists with systemd 202.
echo FONT=LatArCyrHeb-16 > /etc/vconsole.conf

# Triggering systemd-update-done
touch /etc/.updated
touch /var/.updated

# remove LDAP keys
rm -f /etc/openldap/ssl/ldap.pem /etc/openldap/ssl/ldap.key \
/etc/openldap/ssl/ldap.csr /etc/openldap/ssl/ldap.crt

# Cleanup
rm -rf "${FILES_TO_REMOVE[@]}"

# Remove scripts
rm -f /post-upgrade.sh
