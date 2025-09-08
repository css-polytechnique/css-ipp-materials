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

## Téléchargement et enregistrement en boucle for
urls <- paste0("https://css.cnrs.fr/scrape/multiplication-", 1:10, ".html")
fichiers <- paste0("multip-", 1:10, ".html")
for (ipage in 1:10) {
  cat("Page ", ipage, "\n")
  multip.tel <- GET(urls[ipage])
  writeLines(as.character(multip.tel), fichiers[ipage])
  Sys.sleep(1)
}

## Parsing en boucle for
# fichiers <- grep("^multip-\\d+[.]html$", value = TRUE, dir())
multip.parse <- list()
for (ipage in 1:10) {
  multip.parse[[ipage]] <- htmlParse(fichiers[ipage])
}
multip.parse[[1]]

## (Alternative :) Parsing en lapply
multip.parse <- lapply(fichiers, htmlParse)
multip.parse[[1]]


## Extraction de toutes les multiplications des tables de 1 à 10, 
## résultat stocké en un seul vecteur.
## Boucle for :
multip.extr <- NULL
for (ipage in 1:10) {
  tmp <- xpathSApply(multip.parse[[ipage]], "//li", xmlValue)
  multip.extr <- c(multip.extr, tmp)
}
multip.extr

## (Alternative :) Même chose en lapply
multip.extr <- lapply(multip.parse, xpathSApply, "//li", xmlValue)
multip.extr <- do.call(c, multip.extr)
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

## Téléchargement et enregistrement de la page d'acceuil
accueil.brut <- GET("https://www.css.cnrs.fr/scrape/nobel_accueil.html")
writeLines(as.character(accueil.brut), "nobel-accueil.html")
## Parsing
accueil.parse <- htmlParse("nobel-accueil.html", encoding = "UTF-8")

## Extraction des liens vers les récipiendaires par décennie
decenn.liens <- 
  xpathSApply(accueil.parse, "//div[@class='row']//div[@id='price_winners']//a/@href")
decenn.liens <- paste0("https://www.css.cnrs.fr/scrape/", decenn.liens)

## Téléchargement et enregistrement en boucle for
decenn.fichiers <- gsub(".*/", "", decenn.liens)
for (i in seq_along(decenn.liens)) {
  cat("GET ", i, "\n")
  labrute <- GET(decenn.liens[i])
  writeLines(as.character(labrute), decenn.fichiers[i])
  Sys.sleep(1)
}

## Parsing en boucle for
# decenn.fichiers <- grep("^nobel_\\d.*[.]html$", value = TRUE, dir())
decenn.parse <- list()
for (i in seq_along(decenn.liens)) {
  decenn.parse[[i]] <- htmlParse(decenn.fichiers[i], encoding = "UTF-8")
}
length(decenn.parse)
decenn.parse[[1]]

## Suppl : lapply
# decenn.fichiers <- grep("^winners_.*[.]html$", value = TRUE, dir())
decenn.parse <- lapply(decenn.fichiers, htmlParse, encoding = "UTF-8")


## Extraction des lauréats de physique et chimie en une ligne par année : 
laur.an <- NULL
laur.phy <- NULL
laur.chimie <- NULL
for (ipage in 1:length(decenn.parse)) {
  ## Extraction page par page
  tmp.an <- xpathSApply(decenn.parse[[ipage]], "//tr//td[1]", xmlValue)
  tmp.phy <- xpathSApply(decenn.parse[[ipage]], "//tr//td[2]", xmlValue)
  tmp.chimie <- xpathSApply(decenn.parse[[ipage]], "//tr//td[3]", xmlValue)
  ## Stockage dans des vecteurs séparés
  laur.an <- c(laur.an, tmp.an)
  laur.phy <- c(laur.phy, tmp.phy)
  laur.chimie <- c(laur.chimie, tmp.chimie)
}

laureats.paran <- data.frame(annee = laur.an, 
                             physique = laur.phy, 
                             chimie = laur.chimie)
write.csv(laureats.paran, row.names = FALSE, "nobel-laureats-par-an.csv")


## Extraction des lauréats de physique et chimie en une ligne par lauréat
## Deux boucles imbriquées : pour les pages et pour les lauréats
laur.an <- NULL
laur.nom <- NULL
laur.disc <- NULL
laur.url <- NULL
for (ipage in 1:length(decenn.parse)) {
  ## Extraction des lauréats page par page
  tmp.laureats <- xpathSApply(decenn.parse[[ipage]], "//td[2]/a | //td[3]/a")
  for (ilaur in 1:length(tmp.laureats)) {
    ## Extraction des infos, lauréat par lauréat
    tmp.nom <- xpathSApply(tmp.laureats[[ilaur]], ".", xmlValue)
    tmp.url <- xpathSApply(tmp.laureats[[ilaur]], "./@href")
    tmp.an <- xpathSApply(tmp.laureats[[ilaur]], "./../../td[1]", xmlValue)
    tmp.disc <- xpathSApply(tmp.laureats[[ilaur]], "count(./../preceding-sibling::td)", xmlValue)
    ## Stockage comme vecteurs séparés
    laur.nom <- c(laur.nom, tmp.nom)
    laur.url <- c(laur.url, tmp.url)
    laur.an <- c(laur.an, tmp.an)
    laur.disc <- c(laur.disc, tmp.disc)
  }
}

## Recodage de la discipline
laur.disc2 <- rep("Physique", length(laur.disc))
laur.disc2[laur.disc == 2] <- "Chimie"

laureats.parlaur <- data.frame(annee = laur.an, 
                               nom = laur.nom,
                               discipline = laur.disc2, 
                               url = laur.url)
## Enregistrement sur le disque
write.csv(laureats.parlaur, row.names = F, "laureats-par-laureat.csv")


## Toute l'extraction en une fois avec scraEP : 
library(scraEP)
names(decenn.parse) <- decenn.liens
laureats.aspi <- xscrape(decenn.parse, 
                         row.xpath = "//td[2]/a | //td[3]/a", 
                         col.xpath = c(annee = "./../../td[1]", 
                                       nom = ".", 
                                       disc = "count(./../preceding-sibling::td)"))
## Recodage de la discipline
laureats.aspi$discipline <- "Physique"
laureats.aspi$discipline[laureats.aspi$disc == 2] <- "Chimie"
## Enregistrement sur le disque
write.csv(laureats.aspi, row.names = F, "laureats-aspi.csv")




#############
## Exercice (avancé) : extraction d'infos à partir de pages individuelles des
## lauréats de prix nobel
## URL : https://www.css.cnrs.fr/scrape/nobel_1900_1920.html
## Consigne : Construire une data.frame à un lauréat par ligne, avec en colonnes
## les informations biographique : date de naissance, nationalité.
## On se limitera aux prix nobel de physique.
#############

## Téléchargement de la page liste
nobel20.brut <- GET("https://www.css.cnrs.fr/scrape/nobel_1900_1920.html")
writeLines(as.character(nobel20.brut), "nobel1900-1920.html")

## Parsing
nobel20 <- htmlParse("nobel1900-1920.html", encoding = "UTF-8")

## Extraction des noms et url de prix nobel de physique 
nobel20.noms <- xpathSApply(nobel20, "//td[2]/a", xmlValue)
nobel20.urls <- xpathSApply(nobel20, "//td[2]/a/@href")
nobel20.urls <- gsub("^[.]", "https://css.cnrs.fr/scrape", nobel20.urls)

## Recodage des accents (plutôt que des %C3 etc) dans les URL (optionnel)
nobel20.urls <- sapply(nobel20.urls, URLdecode)

## Téléchargement de l'ensemble des pages individuelles
nobel20.fichiers <- gsub("^.*/", "wiki_", nobel20.urls)
nobel20.fichiers <- paste0(nobel20.fichiers, ".html")
for (iurl in 1:length(nobel20.urls)) {
  cat(iurl, " ", nobel20.noms[iurl], "\n")
  Sys.sleep(1)
  tmp.brut <- GET(nobel20.urls[iurl])
  writeLines(as.character(tmp.brut), nobel20.fichiers[iurl])
}


## Parsing 
fiches20.fichiers <- grep("^wiki_.*html$", value = T, dir())
fiches20.parse <- lapply(fiches20.fichiers, htmlParse)

## Extraction des infos : nom, date de naissance, nationalité
names(fiches20.parse) <- fiches20.fichiers
fiches20.infos <- xscrape(
  fiches20.parse, 
  col.xpath = c(nom = "//h1", 
                naissance = "//th[text()='Naissance']/following-sibling::td//time/*[3]", 
                nationalité = "//th[text()='Nationalité']/following-sibling::td"))
