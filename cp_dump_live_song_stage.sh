ssh -i "Doopaadoo-production-BE.pem" ubuntu@52.77.56.37 "rm -R /home/ubuntu/export_db/src"
ssh -i "Doopaadoo-production-BE.pem" ubuntu@52.77.56.37 "cd /home/ubuntu/export_db && ./export_live.sh"

rm -R /home/manikandanr/Desktop/src
mkdir /home/manikandanr/Desktop/src
scp -r -i "Doopaadoo-production-BE.pem" ubuntu@52.77.56.37:/home/ubuntu/export_db/src /home/manikandanr/Desktop
ssh -i "iPaadal-BE-Key.pem" ubuntu@52.77.241.160 "rm -R /home/ubuntu/db_migration/src"
scp -r -i "iPaadal-BE-Key.pem" /home/manikandanr/Desktop/src ubuntu@52.77.241.160:/home/ubuntu/db_migration/


ssh -i "iPaadal-BE-Key.pem" ubuntu@52.77.241.160 "cd /home/ubuntu/db_migration/ && ./import_staging.sh"
