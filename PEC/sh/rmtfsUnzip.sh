#!/bin/bash
export USER=$(whoami)
#@(#)=======================================================================
#@(#)= rmtfsUnzip.sh : Restauration du PEC
#@(#)=----------------------------------------------------------------------
#@(#)= Paramètres de traitement
#@(#)=----------------------------------------------------------------------
#@(#)= $1 = Répertoire Source
#@(#)= $2 = Répertoire Cible
#@(#)= $3 = Nom du PEC a restaurer (ALL pour tous)
#@(#)= $4 = Nature des objets à restaurer
#@(#)=======================================================================
rep_srce=$1/
rep_dist=$2
rep_semaphore=${2}/"_semaphore"
nom_log="_log.txt"
sep="_"
tgz=".tgz"
nb=0
nbti=0
nbfi=0
nbto=0
nbfo=0
#@(#)=======================================================================
#@(#)= FONCTIONS
#@(#)=======================================================================

#@(#)=======================================================================
#@(#)= Fonction help
#@(#)=======================================================================
function help
{
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
  echo "| BUT DU TRAITEMENT : Restauration d'un ou de tous les PEC                                                                      |"
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
  echo "| PARAMETRES DU TRAITEMENT                                                                                                      |"
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
  echo "|   1 - Repertoire Source                                                                                                       |"
  echo "|   2 - Repertoire Cible                                                                                                        |"
  echo "|   3 - Nom du PEC                                                                                                              |"
  echo "|       AAAA_nnnn_nom : Nom du zip sans l'extention                                                                             |"
  echo "|       ALL           : Tous les PEC du repertoire source                                                                       |"
  echo "|   4 - Nature des objets                                                                                                       |"
  echo "|       INPUT : tous les objets INPUT                                                                                           |"
  echo "|       OUTPUT: tous les objets OUTPUT                                                                                          |"
  echo "|       ALL   : tous les objets INPUT et OUTPUT                                                                                 |"
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
  echo "| EXEMPLES DE COMMANDES                                                                                                         |"
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest ALL INPUT             |"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest ALL OUTPUT            |"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest ALL ALL               |"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest TEST_0001_JCL1 INPUT  |"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest TEST_0001_JCL1 OUTPUT |"
  echo "| /home/mchollier/sh/rmtfsUnzip.sh /home/mchollier/rmtfs/sastozos/pec /home/mchollier/rmtfs/sastoaix/rest TEST_0001_JCL1 ALL    |"
  echo "|-------------------------------------------------------------------------------------------------------------------------------|"
}
#@(#)=======================================================================
#@(#)= Fonction toLowerCase()
#@(#)=======================================================================
toLowerCase()
{
   echo $1 | tr 'A-Z' 'a-z'
}
#@(#)=======================================================================
#@(#)= Fonction extraction_INPUT()
#@(#)=======================================================================
extraction_INPUT()
{
sens="fi"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbfi+=1))
  fi
done
sens="ti"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbti+=1))
  fi
done
}
#@(#)=======================================================================
#@(#)= Fonction extraction_OUTPUT()
#@(#)=======================================================================
extraction_OUTPUT()
{
sens="fo"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbfo+=1))
  fi
done
sens="to"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbto+=1))
  fi
done
}
#@(#)=======================================================================
#@(#)= Fonction extraction_ALL()
#@(#)=======================================================================
extraction_ALL()
{
sens="fi"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbfi+=1))
  fi
done
sens="ti"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbti+=1))
  fi
done
sens="fo"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbfo+=1))
  fi
done
sens="to"
for filewithpath in $rep_dist/$nom_pec/$sens/*.txt; do
  file=$(basename $filewithpath)
  if [ "$file" != "*.txt" ];then
     cp $filewithpath $rep_dist/$nom_pec$sep$sens$sep$file
     ((nbto+=1))
  fi
done
}
#@(#)=======================================================================
#@(#) = PROCEDURE PRINCIPALE
#@(#)=======================================================================

#@(#) = Contrôle des options
OPTIONS="dHh"
while getopts $OPTIONS value
do
  case $value in
    d)   set -xv ;;
    H|h) help; exit;;
    \?)  help; exit;;
  esac
done
shift $((OPTIND-1))
#@(#) = Traitement Initial
ymdhm=$(date '+%Y%m%d_%Hh%M')
echo "----------------------------------------------------------------------"
echo " $ymdhm Debut du traitement rmtfsUnzip.sh"
echo "----------------------------------------------------------------------"

#@(#) = Contrôle des paramètres
if [ $# -ne 4 ]; then
   echo "le script attend 4 parametres, faites un -h pour l'aide"
   exit 99
fi
#@(#) = Contrôle existence répertoire source
if [ ! -d $rep_srce ];then
   echo "Repertoire source inexistant modifier les parametres $rep_srce"
   exit 99
fi
#@(#) = Contrôle existence Sémaphore
echo "SEMAPHORE - Activation OK"
if [ ! -d $rep_dist ];then
   echo "Creation du repertoire $rep_dist"
   mkdir -m 777 $rep_dist
   mkdir -m 777 $rep_semaphore
else
   if [ ! -d $rep_semaphore ];then
      mkdir -m 777 $rep_semaphore
   else
      echo "SEMAPHORE - Il y a deja un Run en cours"
      exit 00
   fi
fi
#@(#) = Check du répertoire source à analyser
cd $rep_dist
ls $rep_srce > liste_rmtfsUnzip.txt
liste=$(grep $tgz liste_rmtfsUnzip.txt)
echo 'liste ' $liste
for myfile in $liste; do
   nom_zip=$myfile
   nom_pec=`echo $myfile | cut -d \. -f1`
   echo 'nom_zip ' $nom_zip 
   echo 'nom_pec ' $nom_pec 
   if [ $3 == "ALL" ];then
      ((nb+=1))
      echo "Creation du repertoire $rep_dist/$nom_pec"
      cd $rep_srce && cat $nom_zip | gunzip | tar xf - -C $rep_dist
      case $4 in
        INPUT) extraction_INPUT ;;
        OUTPUT) extraction_OUTPUT ;;
        ALL) extraction_ALL ;;
      esac
      rm -R -f $rep_dist/$nom_pec/
   else
      if [ $3 == $nom_pec ];then
         ((nb+=1))
         echo "Creation du repertoire $rep_dist/$nom_pec"
         cd $rep_srce && cat $nom_zip | gunzip | tar xf - -C $rep_dist
         case $4 in
           INPUT) extraction_INPUT ;;
           OUTPUT) extraction_OUTPUT ;;
           ALL) extraction_ALL ;;
         esac
         rm -R -f $rep_dist/$nom_pec/
      fi
   fi
done
#@(#) = Traitement final
rm $rep_dist/liste_rmtfsUnzip.txt
rm -R $rep_semaphore
echo "SEMAPHORE - Liberation OK"
ymdhm=$(date '+%Y%m%d_%Hh%M')
echo "----------------------------------------------------------------------"
echo " $ymdhm Fin du traitement rmtfsUnzip.sh"
echo "----------------------------------------------------------------------"
echo " $nb PEC restaure(s)"
echo "----------------------------------------------------------------------"
echo "     dont $nbti Table(s) Input restauree(s)"
echo "     dont $nbfi Fichier(s) Input restaure(s)"
echo "     dont $nbto Table(s) Output restauree(s)"
echo "     dont $nbfo Fichier(s) Output restaure(s)"
echo "----------------------------------------------------------------------"
exit 00
#@(#)=======================================================================
#@(#)= rmtfsUnzip.sh : FIN DU SCRIPT
#@(#)=======================================================================
