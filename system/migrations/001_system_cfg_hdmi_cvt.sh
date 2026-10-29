#!/bin/bash
# Migration 001 (29/10/2026) : /boot/system.cfg - met en commentaire les lignes "hdmi_cvt ..."
# (option Raspberry Pi sans effet sur le CB2, qui provoquait "hdmi_cvt: command not found"
# au demarrage). Sauvegarde : /boot/system.cfg.avant_001
CFG=/boot/system.cfg
[ -f "$CFG" ] || exit 0
grep -q '^[[:space:]]*hdmi_cvt' "$CFG" || exit 0
cp -f "$CFG" "$CFG.avant_001" || exit 1
sed -i 's/^\([[:space:]]*hdmi_cvt\)/# \1/' "$CFG"
