#!/bin/bash
# =============================================================================
# copyusb.sh — VyperOS / VOLUMIC
# Parcourt tous les périphériques USB montés, copie tous les fichiers .gcode
# (.gcode, .gco, .g) vers /home/Volumic/printer_data/gcodes/Fichiers copiés/
# Crée le dossier de destination s'il n'existe pas.
# =============================================================================

DEST="/home/Volumic/printer_data/gcodes/Fichiers copiés"
LOGFILE="/home/Volumic/printer_data/logs/copyusb.log"
EXTENSIONS=("gcode" "gco" "g")
USB_MOUNTPOINT="/home/Volumic/usb_mount"   # point de montage dédié, owned by Volumic
MOUNTED_AUTO=""                             # renseigné si on monte nous-mêmes → à démonter en fin

# -----------------------------------------------------------------------------
# Créer les dossiers nécessaires (tous dans le home Volumic → pas besoin de sudo)
mkdir -p "$(dirname "$LOGFILE")"
mkdir -p "$DEST"
mkdir -p "$USB_MOUNTPOINT"

exec > "$LOGFILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Démarrage copyusb.sh"
echo "[INFO] Destination  : $DEST"
echo "[INFO] Mount point  : $USB_MOUNTPOINT"

# Vérifier que la destination est bien créée
if [ ! -d "$DEST" ]; then
    echo "[ERREUR] Impossible de créer le dossier de destination : $DEST"
    exit 1
fi

# -----------------------------------------------------------------------------
# Chercher les périphériques USB effectivement montés
# /dev/sd* = USB sur Armbian/RK3566 ; mmcblk = eMMC/SD interne (exclu)
# -----------------------------------------------------------------------------
usb_mounts=()

while IFS= read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    mountpoint=$(echo "$line" | awk '{print $2}')
    if [[ "$device" == /dev/sd* ]]; then
        usb_mounts+=("$mountpoint")
        echo "[INFO] Périphérique USB déjà monté : $device → $mountpoint"
    fi
done < /proc/mounts

# -----------------------------------------------------------------------------
# Fallback : si aucun /dev/sd* monté, monter le premier périphérique trouvé
# La règle sudoers limite cette commande au seul chemin $USB_MOUNTPOINT
# -----------------------------------------------------------------------------
if [ ${#usb_mounts[@]} -eq 0 ]; then
    echo "[INFO] Aucun périphérique USB monté — tentative de montage automatique..."

    for dev in /dev/sd*1 /dev/sd*; do
        [ -b "$dev" ] || continue
        if ! grep -q "^$dev " /proc/mounts; then
            if sudo mount "$dev" "$USB_MOUNTPOINT" 2>/dev/null; then
                echo "[INFO] Monté : $dev → $USB_MOUNTPOINT"
                usb_mounts+=("$USB_MOUNTPOINT")
                MOUNTED_AUTO="$USB_MOUNTPOINT"
                break
            else
                echo "[WARN] Échec montage : $dev"
            fi
        fi
    done
fi

if [ ${#usb_mounts[@]} -eq 0 ]; then
    echo "[ERREUR] Aucune clé USB trouvée ou montable."
    echo "[AIDE] Vérifier : lsblk -o NAME,TYPE,TRAN,MOUNTPOINT"
    exit 1
fi

# -----------------------------------------------------------------------------
# Copier les fichiers .gcode depuis chaque point de montage USB
# -----------------------------------------------------------------------------
total_copied=0
total_skipped=0
total_errors=0

# Construire les arguments find une seule fois (valable pour toutes les extensions)
find_args=()
first=true
for ext in "${EXTENSIONS[@]}"; do
    if $first; then
        find_args+=(-iname "*.${ext}")
        first=false
    else
        find_args+=(-o -iname "*.${ext}")
    fi
done

for mnt in "${usb_mounts[@]}"; do
    echo ""
    echo "[INFO] Scan de : $mnt"

    while IFS= read -r -d '' src_file; do
        # Chemin relatif depuis la racine du point de montage
        rel_path="${src_file#$mnt/}"
        dest_file="$DEST/$rel_path"
        dest_dir=$(dirname "$dest_file")

        # Créer le sous-dossier de destination si nécessaire
        mkdir -p "$dest_dir"

        # Gestion des doublons par comparaison de taille
        if [ -f "$dest_file" ]; then
            src_size=$(stat -c%s "$src_file" 2>/dev/null || echo 0)
            dst_size=$(stat -c%s "$dest_file" 2>/dev/null || echo 0)
            if [ "$src_size" -eq "$dst_size" ]; then
                echo "[SKIP] Déjà présent (même taille) : $rel_path"
                ((total_skipped++))
                continue
            else
                # Taille différente → renommer avec timestamp plutôt qu'écraser
                base="${dest_file%.*}"
                ext_only="${dest_file##*.}"
                timestamp=$(date '+%Y%m%d_%H%M%S')
                dest_file="${base}_${timestamp}.${ext_only}"
                echo "[INFO] Doublon différent — renommé en : ${dest_file#$DEST/}"
            fi
        fi

        cp "$src_file" "$dest_file"
        if [ $? -eq 0 ]; then
            echo "[OK] Copié : $rel_path"
            ((total_copied++))
        else
            echo "[ERREUR] Échec copie : $rel_path"
            ((total_errors++))
        fi

    done < <(find "$mnt" \( "${find_args[@]}" \) -type f -print0 2>/dev/null)
done

# -----------------------------------------------------------------------------
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Terminé."
echo "[RÉSULTAT] Copiés : $total_copied | Ignorés : $total_skipped | Erreurs : $total_errors"

# Démonter proprement si on a monté nous-mêmes
if [ -n "$MOUNTED_AUTO" ]; then
    sudo umount "$MOUNTED_AUTO" 2>/dev/null \
        && echo "[INFO] Démontage propre : $MOUNTED_AUTO" \
        || echo "[WARN] Démontage échoué (peut être ignoré)"
fi

exit 0