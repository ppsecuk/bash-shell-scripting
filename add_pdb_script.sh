cat services.txt | while read line;
do kubectl create poddisruptionbudget $line --selector=app=$line --min-available=1 ;
done
