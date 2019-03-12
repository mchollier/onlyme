#!/bin/bash
export USER=$(whoami)
#@(#)=======================================================================
#@(#)= rmtfsCheck.sh : Construction du PEC
#@(#)=----------------------------------------------------------------------
#@(#)= Paramètres de traitement
#@(#)=----------------------------------------------------------------------
#@(#)= $1 = Répertoire Source
#@(#)= $2 = Répertoire Cible
#@(#)=======================================================================
rep_srce=${1}/
rep_dist=${2}
rep_sav_xdc=${2}/"_savxdc"
rep_semaphore=${2}/"_semaphore"
fin_logi="fin_logi.txt"
fin_logo="fin_logo.txt"
nom_batch_lot="batch_lot.conf"
nom_log="_log.txt"
sep="_"
txt=".txt"
fin="_fin_"
nb=0
#@(#)=======================================================================
#@(#)= FONCTIONS
#@(#)=======================================================================

#@(#)=======================================================================
#@(#)= Fonction help
#@(#)=======================================================================
function help 
{
  echo "|-------------------------------------------------------------------------------------------------------------------|"
  echo "| BUT DU TRAITEMENT : Creation d'un PEC                                                                             |"
  echo "|-------------------------------------------------------------------------------------------------------------------|"
  echo "| PARAMETRES DU TRAITEMENT                                                                                          |"
  echo "|-------------------------------------------------------------------------------------------------------------------|"
  echo "|   1 - Repertoire Source                                                                                           |"
  echo "|   2 - Repertoire Cible                                                                                            |"
  echo "|-------------------------------------------------------------------------------------------------------------------|"
  echo "| EXEMPLES DE COMMANDES                                                                                             |"
  echo "|-------------------------------------------------------------------------------------------------------------------|"
  echo "| /home/mchollier/sh/rmtfsCheck.sh /home/mchollier/rmtfs/sastoaix/pec /home/mchollier/rmtfs/sastozos/pec            |"
  echo "|-------------------------------------------------------------------------------------------------------------------|"
}
#@(#)=======================================================================
#@(#)= Fonction toLowerCase()
#@(#)=======================================================================
toLowerCase()
{
   echo $1 | tr 'A-Z' 'a-z'
}
#@(#)=======================================================================
#@(#)= Fonction creationDuRepertoire()
#@(#)=======================================================================
creationDuRepertoire()
{
  rep_attendu=$rep_cible/$1
  if [ ! -d $rep_attendu ];then
      mkdir -m 777 $rep_attendu
  else
     rm -R $rep_attendu
     mkdir -m 777 $rep_attendu
  fi
}
#@(#)=======================================================================
#@(#)= Fonction copyFichiers()
#@(#)=======================================================================
copyFichiers()
{
  for fichierEnCours in $liste; do
    cp $rep_srce$fichierEnCours $rep_attendu/
    if [ ! $1 = "" ];then
       data=$(echo $fichierEnCours | sed 's/'$titre'//g')
       data=$(echo $data | sed 's/'$1'//g' | tr 'A-Z' 'a-z')
       data="$(sed s/-/_/g <<<$data)" 
       mv $rep_attendu/$fichierEnCours  $rep_attendu/$data$txt
       alimLog $fichierEnCours
    fi
  done
}
#@(#)=======================================================================
#@(#)= Fonction copyAndNak()
#@(#)=======================================================================
copyAndNak()
{
  for fichierEnCours in $liste; do
    cp $rep_srce$fichierEnCours $rep_attendu/
    if [ ! $1 = "" ];then
       data=$(echo $fichierEnCours | sed 's/'$titre'//g')
       data=$(echo $data | sed 's/'$1'//g' | tr 'A-Z' 'a-z')
       data="$(sed s/-/_/g <<<$data)" 
       cat $rep_attendu/$fichierEnCours | tr -s '\' '\n' > output.txt
       cat output.txt > $rep_attendu/$data
       rm output.txt
       rm $rep_attendu/$fichierEnCours
    fi
  done
}
#@(#)=======================================================================
#@(#)= Fonction saveAndNak()
#@(#)=======================================================================
saveAndNak()
{
  sf2_rep_srce=$1
  sf3_rep_sav=$2
  for sf0_fichierEnCours in $liste; do
     cat $sf2_rep_srce/$sf0_fichierEnCours | tr -s '\' '\n' > output.txt
     cat output.txt > $sf3_rep_sav/$sf0_fichierEnCours
     rm output.txt
     chmod 777 $sf3_rep_sav/$sf0_fichierEnCours
  done
}
#@(#)=======================================================================
#@(#)= Fonction creationZip()
#@(#)=======================================================================
creationZip() 
{
  zipFile=$contexte$sep$sequence$sep$jcl
  rep_cible=$rep_dist/$zipFile
  rep_tgz=$rep_cible".tgz"
  if [ ! -f $rep_tgz ];then
     mkdir -m 777 $rep_cible
     if [ ! -d $rep_sav_xdc ];then
        echo "Creation du repertoire $rep_sav_xdc"
        mkdir -m 777 $rep_sav_xdc
     fi

     echo "Compression du repertoire $rep_cible"
     ((nb+=1))

     creationDuRepertoire "ti"
     liste=$(grep $titre"_ti_" liste_rmtfsCheck.txt)
     copyFichiers "_ti_"

     creationDuRepertoire "to"
     liste=$(grep $titre"_to_" liste_rmtfsCheck.txt)
     copyFichiers "_to_"

     creationDuRepertoire "fi"
     liste=$(grep $titre"_fi_" liste_rmtfsCheck.txt)
     copyFichiers "_fi_"

     creationDuRepertoire "fo"
     liste=$(grep $titre"_fo_" liste_rmtfsCheck.txt)
     copyFichiers "_fo_"

     creationDuRepertoire "i"
     liste=$(grep $titre"_i_" liste_rmtfsCheck.txt)
     copyAndNak "_i_"

     creationDuRepertoire "o"
     liste=$(grep $titre"_o_" liste_rmtfsCheck.txt)
     copyAndNak "_o_"

     creationDuRepertoire "xdc"
     liste=$(grep $titre"_xdc_" liste_rmtfsCheck.txt)
     copyAndNak "_xdc_"
     saveAndNak $rep_srce $rep_sav_xdc

     alimBatchLot $contexte $sequence $jcl
     tar cf - $zipFile | gzip > $zipFile".tgz"
     chmod 777 $zipFile".tgz"
  fi
  if [ -d $rep_cible ];then
     echo "Suppression du repertoire $rep_cible"
     rm -R $rep_cible
  fi
}
#@(#)=======================================================================
#@(#)= Fonction alimLog()
#@(#)=======================================================================
alimLog()
{
  ab1_fich=$1
  if [ -f $nom_log ];then
     echo $ab1_fich  >> $nom_log
  else
     echo $ab1_fich  > $nom_log
  fi
  chmod 777 $nom_log
}
#@(#)=======================================================================
#@(#)= Fonction alimBatchLot()
#@(#)=======================================================================
alimBatchLot()
{
  ab1_contexte=$1
  ab2_sequence=$2
  ab3_jcl=$3
  nom_jcl_aix=$(toLowerCase $ab3_jcl)
  if [ -f $nom_batch_lot ];then
     echo $ab1_contexte"|"$ab2_sequence"|"$ab3_jcl"|"$nom_jcl_aix".sh"  >> $nom_batch_lot
  else
     echo $ab1_contexte"|"$ab2_sequence"|"$ab3_jcl"|"$nom_jcl_aix".sh"  > $nom_batch_lot
  fi
  chmod 777 $nom_batch_lot
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
echo $ymdhm " Debut du traitement rmtfsCheck.sh"
echo "----------------------------------------------------------------------"
#@(#) = Contrôle des paramètres
if [ $# -ne 2 ]; then
  echo "le script attend 2 parametres, faites un -h pour l'aide"
  exit 99
fi
#@(#) = Contrôle existence Sémaphore
echo "SEMAPHORE - Activation OK"
if [ ! -d $rep_dist ];then
   echo "Creation du repertoire"$rep_dist
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
ls $rep_srce > liste_rmtfsCheck.txt
liste_fin_logi=$(grep $fin_logi liste_rmtfsCheck.txt)
for myfile in $liste_fin_logi; do
   stringFile=$(echo $myfile | sed 's/'$fin_logi'/'$fin_logo'/g' )
   existeLogo=$(grep $stringFile liste_rmtfsCheck.txt)
   if [ ! $existeLogo == "" ];then
      contexte=`echo $existeLogo | cut -d $sep -f1`
      sequence=`echo $existeLogo | cut -d $sep -f2`
      jcl=`echo $existeLogo | cut -d $sep -f3`
      titre=$contexte$sep$sequence$sep$jcl
#      echo 'contexte' $contexte
#      echo 'sequence' $sequence
#      echo 'jcl' $jcl
      creationZip
   fi
done
#@(#) = Traitement final
rm liste_rmtfsCheck.txt
rm -R $rep_semaphore
echo "SEMAPHORE - Liberation OK"
ymdhm=$(date '+%Y%m%d_%Hh%M')
echo "----------------------------------------------------------------------"
echo " $ymdhm Fin du traitement rmtfsCheck.sh"
echo "----------------------------------------------------------------------"
echo " $nb PEC construit(s) et archives(s)"
echo "----------------------------------------------------------------------"
exit 00
#@(#)=======================================================================
#@(#)= rmtfsCheck.sh : FIN DU SCRIPT
#@(#)=======================================================================
