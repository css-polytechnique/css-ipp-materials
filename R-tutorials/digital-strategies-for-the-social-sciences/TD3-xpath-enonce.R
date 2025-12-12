## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 3 : Extraction de données avec XPath

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
library(XML) # Pour les fonctions htmlParse, et xpathSApply


#############
## Exercice : Nobel news
## URL : https://css.cnrs.fr/scrape/nobel_news.html
## Consigne : 
## 1 - Télécharger et parser la page
## 2 - Extraire le titre et le sous-titre de la page
## 3 - Extraire le texte du premier bloc de texte ("Le comité Nobel...")
## 4 - Extraire les noms des jurés et leurs biographies, et les présenter en 
## une data.frame (une ligne par juré, deux colonnes : nom, biographie)
## 5 - Extraire les différentes informations du panneau de gauche, et les
## présenter en un vecteur.
#############


#############
## Page d'accueil d'un site sur les prix Nobel
## URL : https://www.css.cnrs.fr/scrape/nobel_accueil.html
## Consigne : Télécharger et parser la page d'accueil, puis en extraire la liste
## des liens vers les récipiendaires par décennie, ainsi que les titres et 
## sous-titres associés à ces liens.
## Remarque : attention à l'encodage de la page !
#############


#############
## Exercice : Tableau de tous les prix Nobel
## URL : https://www.css.cnrs.fr/scrape/nobel_all.html
## Consigne : 
## 1 - Télécharger et parser la page
## 2 - Extraire le tableau en une commande : readHTMLTable
## 3 - Extraire de cette page les lauréats de physique et chimie par année, en 
## une data.frame (une ligne par an, trois colonnes : année, physique, chimie)
## 4 - Extraire l'ensemble des lauréats de physique et chimie en une data.frame,
## mais cette fois en une ligne par lauréat, et quatre colonnes : année, nom,
## discipline, lien vers la page wikipedia
#############

