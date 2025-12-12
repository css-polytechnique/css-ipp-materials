## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Démonstrations supplémentaires : rvest, CSS, XML, JSON

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
# install.packages(c("httr", "XML", "scraEP"))

library(httr) # Pour la fonction GET
library(XML) # Pour les fonctions htmlParse, et xpathSApply
library(scraEP) # Pour la fonction xscrape



#############
## Démonstration de rvest et des sélecteurs CSS
## URL : https://css.cnrs.fr/scrape/nobel_news.html
## Consigne : à l'aide des fonctions du package rvest, extraire (par xpath et
## par CSS) les noms et biographies des membres du comité Nobel.
#############
library(rvest)

## Téléchargement, enregistrement
nobel.brut <- GET("https://css.cnrs.fr/scrape/nobel_news.html")
writeLines(as.character(nobel.brut), "nobel_news.html")

## Parsing avec la fonction read_html de rvest
nobel.parse <- read_html("nobel_news.html")

## Extraction des noms du jury à l'aide de sélecteurs XPath ou css
nobel.jury.xpath <- nobel.parse %>% 
  html_elements(xpath = "//div[@class='nomination_person']") %>% 
  html_text2()

nobel.jury.css <- nobel.parse %>% 
  html_elements(css = "div.nomination_person") %>% 
  html_text2()

## Extraction des biographies du jury à l'aide de sélecteurs XPath ou css
nobel.bio.xpath <- nobel.parse %>% 
  html_elements(xpath = "//div[@class='nomination_description']") %>% 
  html_text2()

nobel.bio.css <- nobel.parse %>% 
  html_elements(css = "div.nomination_description") %>% 
  html_text2()


## Extraction par sélecteurs CSS avec xscrape
nobel.jury <- xscrape(nobel.parse, 
                      row.css = "div.col-sm-7 div.row", 
                      col.css = c(nom = "div.nomination_person", 
                                  bio = "div.nomination_description"), 
                      col.xpath = NULL)



#############
## Démonstration de l'extraction de données XML : Tour de France
## URL : https://css.cnrs.fr/scrape/tour_de_france.xml
## Consigne : extraire de cette page, en une data.frame à une ligne par année, 
## les informations suivantes : année, distance totale, nombre de finishers, 
## nom et nationalité du gagnant.
#############

## Téléchargement et parsing, comme pour un fichier html
tdf.brut <- GET("https://css.cnrs.fr/scrape/tour_de_france.xml")
writeLines(as.character(tdf.brut), "tdf.xml")
tdf.parse <- htmlParse(tdf.brut)

## Méthode 1 : Extraction des informations par vecteurs
tdf.annee <- xpathSApply(tdf.parse, "//year", xmlValue)
tdf.distance <- xpathSApply(tdf.parse, "//total_distance_km", xmlValue)
tdf.finishers <- xpathSApply(tdf.parse, "//finishers", xmlValue)
tdf.gagnant <- xpathSApply(tdf.parse, "//winner", xmlValue)
tdf.natio <- xpathSApply(tdf.parse, "//winner_nationality", xmlValue)

tdf.table <- data.frame(annee = tdf.annee, 
                        distance = tdf.distance, 
                        finishers = tdf.finishers, 
                        gagnant = tdf.gagnant, 
                        nationalite = tdf.natio)

## Méthode 2 : avec xscrape
tdf.tablex <- xscrape(tdf.parse, row.xpath = "//row", 
                      col.xpath = c(annee = ".//year", 
                                    distance = ".//total_distance_km", 
                                    finishers = ".//finishers", 
                                    gagnant = ".//winner", 
                                    nationalite = ".//winner_nationality"))



#############
## Démonstration de l'extraction de données JSON : Tour de France
## URL : https://css.cnrs.fr/scrape/tour_de_france.json
## Exercice : extraire de cette page, en une data.frame à une ligne par année, 
## les informations suivantes : année, distance totale, nombre de finishers, 
## nom et nationalité du gagnant.
#############

## Téléchargement comme pour un fichier html
tdf.brut <- GET("https://css.cnrs.fr/scrape/tour_de_france.json")
writeLines(as.character(tdf.brut), "tdf.json")

## Pas de parsing avec htmlParse : on lit seulement le fichier local
tdf.char <- paste0(readLines("tdf.json"), collapse = "\n")

## Avec le pacakge jsonlite, extraction directe sous forme de liste, ou même de 
## data.frame quand le format de données le permet
library(jsonlite)
tdf.jslite <- fromJSON(tdf.char)

