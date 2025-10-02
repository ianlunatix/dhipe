#!/bin/bash
clear

echo -e "[INFO] Mengatur semua jadwal cron..."

# --- Backup Otomatis Jam 00:02
cat >/etc/cron.d/autobackup <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/autobackup
END

# --- Tambahan Cron untuk Backup Cek Expired Trial setiap 5 menit
cat >/etc/cron.d/check_trial_expired <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/local/sbin/check_trial_expired.py
END

echo -e "[INFO] Semua cron telah berhasil dibuat dan diatur."
