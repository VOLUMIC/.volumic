#!/bin/bash
# Migration 003 (29/10/2026) : input shaper des IDRE (dual_carriage)
# Klipper refuse des reglages dans [input_shaper] avec un dual_carriage : les valeurs
# passent dans variables.cfg (save_variables, macros_idre.cfg). Sur une IDRE :
# - reprend les valeurs existantes de printer.cfg (bloc sauvegarde [input_shaper],
#   sinon ancien bloc [input_shaper extruder0]) dans variables.cfg si elles n'y sont pas ;
# - retire ces blocs de la partie sauvegardee de printer.cfg (sauvegarde printer.cfg.avant_003) ;
# - redemarre Klipper pour qu'un SAVE_CONFIG ulterieur ne les reecrive pas.
CFG=/home/Volumic/printer_data/config/printer.cfg
VARS=/home/Volumic/printer_data/config/variables.cfg
[ -f "$CFG" ] || exit 0
grep -qE '^\[include \.volumic/model_[a-z0-9]+_idre\.cfg\]' "$CFG" || exit 0
grep -qE '^#\*# \[input_shaper' "$CFG" || exit 0
python3 - "$CFG" "$VARS" <<'PYEOF' || exit 1
import configparser, re, shutil, sys
cfg, varsf = sys.argv[1], sys.argv[2]
text = open(cfg, encoding="utf-8").read()
if not text.endswith("\n"):
    text += "\n"
blocks = {}
for m in re.finditer(r"^#\*# \[(input_shaper[^\]]*)\]\n((?:#\*# [^\[\n][^\n]*\n)*)", text, re.M):
    vals = {}
    for line in m.group(2).splitlines():
        kv = line[4:].split("=", 1)
        if len(kv) == 2:
            vals[kv[0].strip()] = kv[1].strip()
    blocks[m.group(1).strip()] = vals
src = blocks.get("input_shaper") or blocks.get("input_shaper extruder0") or {}
var = configparser.ConfigParser()
var.read(varsf)
if not var.has_section("Variables"):
    var.add_section("Variables")
v = var["Variables"]
if "shaper_t0_x_type" not in v and all(k in src for k in ("shaper_type_x", "shaper_freq_x", "shaper_type_y", "shaper_freq_y")):
    t1 = blocks.get("input_shaper extruder1", {})
    v["shaper_t0_x_type"] = repr(src["shaper_type_x"])
    v["shaper_t0_x_freq"] = repr(float(src["shaper_freq_x"]))
    v["shaper_t1_x_type"] = repr(t1.get("shaper_type_x", src["shaper_type_x"]))
    v["shaper_t1_x_freq"] = repr(float(t1.get("shaper_freq_x", src["shaper_freq_x"])))
    v["shaper_y_type"] = repr(src["shaper_type_y"])
    v["shaper_y_freq"] = repr(float(src["shaper_freq_y"]))
    with open(varsf, "w", encoding="utf-8") as f:
        var.write(f)
shutil.copyfile(cfg, cfg + ".avant_003")
new = re.sub(r"^#\*# \[input_shaper[^\]]*\]\n(?:#\*# [^\[\n][^\n]*\n)*(?:#\*#\n)?", "", text, flags=re.M)
while new.endswith("\n#*#\n"):
    new = new[:-4]
open(cfg, "w", encoding="utf-8").write(new)
PYEOF
chown Volumic:Volumic "$CFG" "$CFG.avant_003" "$VARS" 2>/dev/null
systemctl restart klipper 2>/dev/null || true
exit 0
