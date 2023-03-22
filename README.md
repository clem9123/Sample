## Fichier de mes codes pour le model

- Run.R : Fichier avec la fonction qui permet de mettre en forme le model et 
le lancer 
- model.txt : Fichier avec le model en format texte
- model_ABIBAL.RData : Fichier avec une sortie du model pour l'éspèce ABIBAL
- Analyse_sortie.R : Fichier avec juste 2 graphes pour voir quelques sorties

# data
dans data on a les données pour faire tourner tout ça

- jags_data : les données triées ect que l'on input dans le model
- scaling.RDS : tableau avec les moyennes et les écarts types pour les
variables qui ont été centrées réduites (me sert à appliquer ces modifications
sur les données de temps, ph et epaisseur de matière organique dont je me sers
pour - l'axe x de - mes prediction)