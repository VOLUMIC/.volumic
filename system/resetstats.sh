#!/bin/bash
#
# resetstats.sh - Remise a zero des statistiques avant expedition (production)
#
# Remet a zero l'historique et les totaux d'impression par l'API Moonraker,
# sans toucher au fichier de base de donnees (la copie d'une base modele
# pouvait la corrompre ou la "detacher" de Moonraker).
#
# Les logs sont remis a zero en fin de script : les logs ouverts sont vides
# (et non supprimes, sinon Klipper/Moonraker continueraient d'ecrire dans un
# fichier efface jusqu'a leur redemarrage), les anciens logs tournes sont supprimes.
#
# Code retour : 0 = OK, 1 = Moonraker injoignable, 2 = remise a zero incomplete

API="http://127.0.0.1:7125"

# --- attendre que Moonraker reponde (60 s max) ---
for i in $(seq 1 30); do
    if curl -s -f -m 3 "${API}/server/info" >/dev/null 2>&1; then
        break
    fi
    sleep 2
done
if ! curl -s -f -m 3 "${API}/server/info" >/dev/null 2>&1; then
    echo "ERREUR : Moonraker ne repond pas sur ${API}"
    exit 1
fi

# --- historique des impressions : suppression de tous les travaux ---
curl -s -f -m 30 -X DELETE "${API}/server/history/job?all=true" >/dev/null \
    || echo "ATTENTION : echec de la suppression de l'historique"

# --- totaux (temps, filament, nombre d'impressions, plus longue impression) ---
curl -s -f -m 30 -X POST "${API}/server/history/reset_totals" >/dev/null \
    || echo "ATTENTION : echec de la remise a zero des totaux"

# --- file d'attente des impressions ---
curl -s -f -m 30 -X DELETE "${API}/server/job_queue/job?all=true" >/dev/null 2>&1

# --- fichiers de sauvegarde et historique de commandes ---
rm -f /home/Volumic/printer_data/config/.moonraker.conf.bkp
rm -f /home/Volumic/printer_data/config/printer-*.cfg
rm -f /home/Volumic/.bash_history

# --- verification ---
TOTALS=$(curl -s -m 10 "${API}/server/history/totals")
COUNT=$(curl -s -m 10 "${API}/server/history/list?limit=1" | grep -o '"count": *[0-9]*' | grep -o '[0-9]*$')
JOBS=$(echo "${TOTALS}" | grep -o '"total_jobs": *[0-9]*' | grep -o '[0-9]*$')

if [ "${COUNT}" = "0" ] && [ "${JOBS}" = "0" ]; then
    RESULT=0
    echo "Statistiques remises a zero."
else
    RESULT=2
    echo "ERREUR : remise a zero incomplete (historique=${COUNT:-?}, total_jobs=${JOBS:-?})"
fi

# --- logs (en dernier, pour ne pas garder les traces de la remise a zero) ---
LOGS=/home/Volumic/printer_data/logs
for f in "${LOGS}"/*.log "${LOGS}"/*.txt; do
    [ -f "$f" ] && truncate -s 0 "$f"
done
# anciens logs tournes (klippy.log.2026-10-27, crowsnest.log.1, *.gz...)
find "${LOGS}" -maxdepth 1 -type f \( -name "*.log.*" -o -name "*.gz" \) -delete

exit ${RESULT}
