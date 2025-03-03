#!/bin/bash
set -e # Hentikan eksekusi jika ada error

CACHE_DIR="$1"
TEX_FILE="$2"

# Validasi argumen
if [ -z "$CACHE_DIR" ] || [ -z "$TEX_FILE" ]; then
  echo "Usage: $0 <texlive-cache-directory> <tex-file-name-without-extension>"
  exit 1
fi


echo "🔧 Menambahkan TeX Live ke PATH..."
export PATH="$CACHE_DIR/bin/x86_64-linux:$PATH"

# Periksa apakah TeX Live Tersedia
if [ ! -d "$CACHE_DIR/bin/x86_64-linux" ]; then
  echo "❌ TeX Live tidak ditemukan! Pastikan sudah diinstal."
  exit 1
fi

# Pastikan pdflatex dan bibtex tersedia
if ! command -v pdflatex &>/dev/null || ! command -v bibtex &>/dev/null; then
  echo "❌ Error: pdflatex atau bibtex tidak ditemukan! Pastikan TeX Live telah diinstal dan tersedia di PATH."
  exit 1
fi

# Pastikan direktori output ada
DOCS_DIR="docs"
if [ ! -d "$DOCS_DIR" ]; then
  mkdir -p "$DOCS_DIR"
  chmod 755 "$DOCS_DIR" # Memberikan izin baca & eksekusi untuk semua orang, tulis untuk pemilik
  echo "✅ Direktori $DOCS_DIR telah dibuat dengan izin akses."
else
  echo "ℹ️ Direktori $DOCS_DIR sudah ada, tidak perlu dibuat ulang."
fi

# Pastikan file .tex ada sebelum kompilasi"
if [ ! -f "$TEX_FILE.tex" ]; then
  echo "❌ Error: File $TEX_FILE.tex tidak ditemukan!"
  echo "📂 Direktori saat ini: $(pwd)"
  exit 1
fi

# Kompilasi dokumen LaTeX
echo "📄 Memulai kompilasi $TEX_FILE.tex..."
pdflatex -interaction=nonstopmode -output-directory=docs "$TEX_FILE.tex"
#if [ -f "docs/$TEX_FILE.aux" ]; then
#  bibtex "docs/$TEX_FILE"
#  for _ in {1..2}; do
#    pdflatex -interaction=nonstopmode -output-directory=docs "$TEX_FILE.tex"
#  done
#fi

echo "✅ Kompilasi selesai. Hasil tersedia di docs/$TEX_FILE.pdf"
