#!/bin/bash
# Met a jour KlipperScreen.conf avec les menus VOLUMIC du depot, en conservant les
# reglages du client (bloc auto-genere "#~#" : langue, theme, macros affichees...).
# Sans bloc client (nouvelle machine), le fichier du depot est copie tel quel.
SRC=/home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf
DST=/home/Volumic/printer_data/config/KlipperScreen.conf
[ -f "$SRC" ] || exit 1
python3 - "$SRC" "$DST" <<'PYEOF'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
MARK = "#~# --- Do not edit below this line. This section is auto generated --- #~#"
new = open(src, encoding="utf-8").read()
try:
    old = open(dst, encoding="utf-8").read()
except OSError:
    old = ""
if MARK in old:
    out = new.split(MARK)[0].rstrip("\n") + "\n\n" + MARK + old.split(MARK, 1)[1]
else:
    out = new
tmp = dst + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    f.write(out)
os.replace(tmp, dst)
PYEOF
chown Volumic:Volumic "$DST" 2>/dev/null || true
