## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 5 : Automatisation de la récolte

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
## Exercice : Tables de multiplication de 1 à 10
## URL : https://css.cnrs.fr/scrape/multiplication-1.html 
## https://css.cnrs.fr/scrape/multiplication-2.html, ..., 
## https://css.cnrs.fr/scrape/multiplication-10.html
## Consigne : extraire toutes les multiplications des 10 tables, et stocker
## le résultat dans un seul vecteur.
#############

## Téléchargement 
urls <- paste0("https://css.cnrs.fr/scrape/multiplication-", 1:10,".html")
fichiers <- gsub("^.*/", "", urls)
for (ipage in seq_along(urls)) {
  cat("GET ", ipage, "\n")
  multip.tel <- GET(urls[ipage])
  writeLines(as.character(multip.tel), fichiers[ipage])
  Sys.sleep(1)
}

## Parsing
multip.parse <- list()
for (ipage in 1:10) {
  multip.parse[[ipage]] <- htmlParse(fichiers[ipage])
}

## Parsing (alternative) : lapply
multip.parse <- lapply(fichiers, htmlParse)

## Extraction 
multip.extr <- NULL
for (ipage in seq_along(multip.parse)) {
  tmp <- xpathSApply(multip.parse[[ipage]], "//li", xmlValue)
  multip.extr <- c(multip.extr, tmp)
}
multip.extr


#############
## Exercice : Page d'accueil Nobel, contenant les liens vers les pages où se
## trouvent les informations
## URL : https://www.css.cnrs.fr/scrape/nobel_accueil.html
## Consigne : 
## 1 - A partir des liens présentés sur la page d'accueil, télécharger
## toutes les pages de gagnants de prix Nobel par décennie
## 2 - Extraire de ces pages l'ensemble des lauréats de physique et chimie, en 
## une data.frame (une ligne par année, trois colonnes)
## 3 - Extraire des mêmes pages l'ensemble des lauréats de physique et chimie, 
## en une data.frame, mais cette fois en une ligne par lauréat, en
## quatre colonnes : année, nom, discipline, lien vers la page wikipedia
#############




#############
## Exercice (avancé) : extraction d'infos à partir de pages individuelles des
## lauréats de prix nobel
## URL : https://www.css.cnrs.fr/nobel_1900_1920.html
## Consigne : Construire une data.frame à un lauréat par ligne, avec en colonnes
## les informations biographique : date de naissance, nationalité.
## On se limitera aux prix nobel de physique.
#############


