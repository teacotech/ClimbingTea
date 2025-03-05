#!/bin/bash
set -e # Hentikan eksekusi jika ada error

CACHE_DIR="$1"

# Validasi argumen
if [ -z "$CACHE_DIR" ]; then
  echo "Usage: $0 <texlive-cache-directory>"
  exit 1
fi

# Periksa apakah direktori cache ada, jika tidak buat
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
  chmod +x "$CACHE_DIR" # Pastikan memiliki izin akses
  echo "✅ Direktori cache $CACHE_DIR telah dibuat."
fi

# Cek apakah TeX Live sudah terinstall
if [ -d "$CACHE_DIR/bin/x86_64-linux" ]; then
  echo "✅ TeX Live sudah ada di cache, tidak perlu menginstal ulang."
  exit 0
fi

echo "📦 Menginstal TeX Live ke dalam cache..."
# Instal TeX Live pada CTAN
wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xz
cd install-tl-*

# Buat file profil untuk instalasi minimal
cat <<EOF > texlive.profile
selected_scheme scheme-basic
TEXDIR $CACHE_DIR
TEXMFCONFIG \$TEXDIR/texmf-config
TEXMFVAR \$TEXDIR/texmf-var
option_doc 0
option_src 0
EOF

# Instalasi TeX Live menggunakan profil
export TEXLIVE_INSTALL_PREFIX="$CACHE_DIR"
./install-tl --profile=texlive.profile --no-interaction --texdir="$CACHE_DIR"

# Penambahan PATH TeX Live ke dalam environment sebelum menjalankan tlmgr
export PATH="$CACHE_DIR/bin/$(uname -m)-linux:$PATH"

# Cleanup file instalasi
cd ..
rm -rf install-tl-*

# Periksa apakah instalasi berhasil
if [ ! -d "$CACHE_DIR/bin/x86_64-linux" ]; then
  echo "❌ Error: Instalasi TeX Live gagal! Direktori bin tidak ditemukan."
  exit 1
fi

# Pastikan PATH diperbarui agar bisa langsung digunakan
export PATH="$CACHE_DIR/bin/x86_64-linux:$PATH"

echo "✅ Instalasi TeX Live selesai dan tersimpan di cache: $CACHE_DIR"
