S.O.B.R.
Secure Offsite Backup with Rsync

SOBR is a set of configurable scripts that performs a remote encrypted backup. All encryption is done client side, using TrueCrypt.  The data is transmitted through ssh, and rsync is used to transfer only files that have changed.

How it works:
1. A remote, unencrypted share is mounted locally, using sshfs.
2. A TrueCrypt volume on this share is decrypted using a pre-configured keyfile.
3. Rsync syncs the files to be backed up onto the locally mounted TrueCrypt Volume.
4. The TrueCrypt volume and sshfs share are unmounted.
 
