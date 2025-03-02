#!/bin/bash

# delete logs files
rm -f /home/Volumic/printer_data/logs/*.*

# delete cmd line history
rm -f /home/Volumic/.bash_history

# reset moonraker database
cp -f /home/Volumic/printer_data/config/.volumic/system/moonraker-sql.db /home/Volumic/printer_data/database/
