<div align="center">
  <img src="assets/banner.jpg" alt="BHATARA OS Banner" width="100%" />
  <h1>BHATARA OS v2.0.1.2 (Termux Edition)</h1>
  <p>
    <strong>Lingkungan Desktop Linux Ubuntu 22.04 (Jammy Jellyfish) + XFCE4 di Android tanpa Root</strong><br/>
    <em>Ubuntu 22.04 (Jammy Jellyfish) + XFCE4 Linux Desktop Environment on Android without Root</em>
  </p>
</div>

---

## Tampilan Desktop / Desktop Showcase

| **`jammy:gnome` (GNOME)** | **`jammy:xfce4` (XFCE4 - Utama)** | **`jammy:mate` (MATE)** |
| :---: | :---: | :---: |
| ![GNOME](assets/jammy_gnome.png) | ![XFCE4](assets/jammy_xfce4.png) | ![MATE](assets/desktop.jpg) |
| Tampilan desktop GNOME | Tampilan utama ringan BHATARA OS | Tampilan desktop MATE |

---

## Prasyarat Sistem / System Requirements

* **Perangkat / Device:** Android ARM64 (`aarch64`), disarankan Android 10–16.
* **Aplikasi / Apps:**
  * [Termux](https://f-droid.org/packages/com.termux/) (wajib versi F-Droid atau GitHub Releases, bukan Play Store).
  * [AVNC](https://f-droid.org/packages/com.gaurav.avnc/) (aplikasi VNC Viewer untuk menampilkan layar desktop).
* **Penyimpanan / Storage:** Minimal ruang kosong **4 GB**.

---

## Pengaturan Wajib Android (Khusus Android 12–16 / HyperOS / OneUI)

> **Penting:** Lewati bagian ini hanya jika Anda menggunakan Android 11 ke bawah. Pada Android 12 hingga 16, sistem akan menghentikan proses Termux secara paksa (`[Process completed (signal 9)]`) jika pengaturan di bawah ini belum diaktifkan.

1. **Matikan Pembatasan Baterai Termux:**
   Buka *Setelan HP → Aplikasi → Termux → Baterai*, lalu pilih **Tidak ada pembatasan (*No restrictions*)**.
2. **Nonaktifkan Pembatasan Proses Turunan (*Child Process Restrictions*):**
   * Buka *Setelan → Tentang Ponsel*, ketuk **Versi OS / Build Number** sebanyak 7 kali hingga **Opsi Pengembang (*Developer Options*)** aktif.
   * Masuk ke *Setelan Tambahan → Opsi Pengembang*, cari dan aktifkan **Nonaktifkan pembatasan proses turunan (*Disable child process restrictions*)**.
<div align="center">
  <img src="assets/banner.jpg" alt="BHATARA OS Banner" width="100%" />
  <h1>BHATARA OS v2.0.1.2 (Termux Edition)</h1>
  <p>
    <strong>Lingkungan Desktop Linux Ubuntu 22.04 (Jammy Jellyfish) + XFCE4 di Android tanpa Root</strong><br/>
    <em>Ubuntu 22.04 (Jammy Jellyfish) + XFCE4 Linux Desktop Environment on Android without Root</em>
  </p>
</div>

---

## Tampilan Desktop / Desktop Showcase

| **`jammy:gnome` (GNOME)** | **`jammy:xfce4` (XFCE4 - Utama)** | **`jammy:mate` (MATE)** |
| :---: | :---: | :---: |
| ![GNOME](assets/jammy_gnome.png) | ![XFCE4](assets/jammy_xfce4.png) | ![MATE](assets/desktop.jpg) |
| Tampilan desktop GNOME | Tampilan utama ringan BHATARA OS | Tampilan desktop MATE |

---

## Prasyarat Sistem / System Requirements

* **Perangkat / Device:** Android ARM64 (`aarch64`), disarankan Android 10–16.
* **Aplikasi / Apps:**
  * [Termux](https://f-droid.org/packages/com.termux/) (wajib versi F-Droid atau GitHub Releases, bukan Play Store).
  * [AVNC](https://f-droid.org/packages/com.gaurav.avnc/) (aplikasi VNC Viewer untuk menampilkan layar desktop).
* **Penyimpanan / Storage:** Minimal ruang kosong **4 GB**.

---

## Pengaturan Wajib Android (Khusus Android 12–16 / HyperOS / OneUI)

> **Penting:** Lewati bagian ini hanya jika Anda menggunakan Android 11 ke bawah. Pada Android 12 hingga 16, sistem akan menghentikan proses Termux secara paksa (`[Process completed (signal 9)]`) jika pengaturan di bawah ini belum diaktifkan.

1. **Matikan Pembatasan Baterai Termux:**
   Buka *Setelan HP → Aplikasi → Termux → Baterai*, lalu pilih **Tidak ada pembatasan (*No restrictions*)**.
2. **Nonaktifkan Pembatasan Proses Turunan (*Child Process Restrictions*):**
   * Buka *Setelan → Tentang Ponsel*, ketuk **Versi OS / Build Number** sebanyak 7 kali hingga **Opsi Pengembang (*Developer Options*)** aktif.
   * Masuk ke *Setelan Tambahan → Opsi Pengembang*, cari dan aktifkan **Nonaktifkan pembatasan proses turunan (*Disable child process restrictions*)**.

---

## Panduan Instalasi Lengkap / Full Installation Guide

### 1. Persiapan Awal di Termux
```bash
pkg update && pkg upgrade -y
pkg install git unzip proot-distro wget curl -y
termux-setup-storage
termux-wake-lock
```

### 2. Kloning & Instal BHATARA OS
```bash
cd ~
git clone https://github.com/BHATARAOS/BHATARA-OS.git
cd ~/BHATARA-OS
chmod +x install.sh scripts/*.sh
./install.sh
```
*(Catatan: Jika unduhan rootfs terputus di tengah jalan karena koneksi internet, lanjutkan cukup dengan `udroid install jammy:xfce4`).*

### 3. Terapkan Tema & Branding BHATARA OS
```bash
cd ~/BHATARA-OS
sed -i 's|/var/lib/proot-distro/installed-rootfs|/var/lib/udroid/installed-filesystems|g' scripts/apply-bhatara-theme.sh
bash scripts/apply-bhatara-theme.sh
```

### 4. Konfigurasi Desktop & Server VNC
Masuk ke sistem BHATARA OS:
```bash
udroid login jammy:xfce4
```

Setelah prompt berubah menjadi `root@localhost:~#`, jalankan perintah berikut:
```bash
mkdir -p ~/.vnc
cat << 'INNER_EOF' > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
exec dbus-launch --exit-with-session startxfce4
INNER_EOF
chmod +x ~/.vnc/xstartup

vncserver -kill :1 2>/dev/null ; rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /root/.vnc/*.pid
vncserver :1 -localhost yes -SecurityTypes None -geometry 1280x720 -depth 24
```

### 5. Hubungkan ke Aplikasi AVNC
1. Biarkan **Termux** tetap berjalan di latar belakang.
2. Buka **AVNC**, ketuk **`+`**, isi **Host:** `127.0.0.1`, **Port:** `5901`, kosongkan **Password**, lalu ketuk **Save** dan hubungkan.

---

## Penggunaan Sehari-hari / Daily Usage

**Menyalakan Kembali BHATARA OS:**
```bash
termux-wake-lock
udroid login jammy:xfce4
vncserver :1 -localhost yes -SecurityTypes None -geometry 1280x720 -depth 24
```

**Mematikan BHATARA OS dengan Aman:**
```bash
vncserver -kill :1
exit
termux-wake-unlock
```

---

## Kontribusi & Lisensi / Contributing & License

* Kontribusi selalu diterima dengan senang hati melalui **Pull Request** maupun **Issues**.
* Dibangun di atas fondasi open-source [ubuntu-on-android (Udroid)](https://github.com/RandomCoderOrg/ubuntu-on-android) oleh **RandomCoderOrg** di bawah lisensi **MIT License**.
