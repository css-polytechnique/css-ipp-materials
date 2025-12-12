## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 2 : Téléchargement / parsing

## Ce script est encodé en UTF-8 ; si les accents ne s'affichent pas bien, 
## utilisez dans Rstudio le menu Fichier -> Réouvrir avec encodage... 
## et choisissez UTF-8.

#############
## Préliminaires : environnement, bibliothèques
#############

rm(list = ls())
## Conseil : redémarrez la session R, Ctr+Shift+F10

setwd("~/cours/20-21 SICSS Scraping/playground/") # à adapter

## Installation des bibliothèques
# install.packages(c("httr", "XML"))

library(httr) # Pour la fonction GET
library(XML) # Pour les fonctions htmlParse, htmlTreeParse, 


#############
## Exercice : Perdue
## URL : https://css.cnrs.fr/scrape/perdue
## Consigne :
## 1 - Télécharger le site (avec GET)
## 2 - Enregistrer le résultat sur le disque dur (avec writeLines)
## 3 - Parser le site depuis le disque dur (avec htmlParse)
#############



#############
## Exercice : Nobel news
## URL : https://css.cnrs.fr/scrape/nobel_news.html
## Consigne : Idem
#############



#############
## Site difficile à télécharger : encodage, cookies, javascript
## URL : https://css.cnrs.fr/scrape/reperdue
## Consigne : Idem
#############


