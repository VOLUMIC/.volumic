Migrations VyperOS : modifications ponctuelles de fichiers propres a chaque machine
(ex. /boot/system.cfg, /etc/fstab), qu'on ne peut pas remplacer par un fichier commun.

- Un script par modification : NNN_description.sh (NNN = numero croissant, jamais reutilise).
- Execute une seule fois par machine par system_update.sh, au demarrage, en root.
- Doit etre sans risque s'il est relance (verifier avant de modifier) et sauvegarder le fichier modifie.
- Code de sortie 0 = fait (note dans ~/VyperOS/.migrations_done) ; autre = relance au prochain demarrage.
- Un script deja diffuse ne se modifie plus : on en ajoute un nouveau.
