## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Exercices supplémentaires

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
                                  bio = "div.nomination_description"))


#############
## Exercice : lemonde
## URL : https://css.cnrs.fr/scrape/lemonde
## Consigne : 
## 1 - Télécharger et parser la page
## 2 - Extraire, en une data.frame, les titres et les liens des 21 articles à la
## "une"
## 3 - Compter, parmi l'ensemble des liens de cette page, combien redirigent en
## dehors du domaine lemonde.fr
#############

## Téléchargement et parsing
lemonde.brut <- GET("https://css.cnrs.fr/scrape/lemonde")
writeLines(as.character(lemonde.brut), "lemonde.html")
lemonde.parse <- htmlParse("lemonde.html")

## Extraction des titres et liens des 21 articles à la une
## Méthode 1 : en deux vecteurs indépendants
lem.titres <- xpathSApply(
  lemonde.parse, 
  "//section[contains(@class, 'zone--homepage')]//div[contains(@class, 'article')]//a", 
  xmlValue)
lem.liens <- xpathSApply(
  lemonde.parse, 
  "//section[contains(@class, 'zone--homepage')]//div[contains(@class, 'article')]//a/@href")
lem.table1 <- data.frame(titre = lem.titres, lien = lem.liens)


## Extraction des titres et liens des 21 articles à la une
## Méthode 2 : avec une boucle sur les noeuds intermédiaires
lem.articles <- xpathSApply(
  lemonde.parse, 
  "//section[contains(@class, 'zone--homepage')]//div[contains(@class, 'article')]//a")
lem.titres <- NULL
lem.liens <- NULL
for (i in 1:length(lem.articles)) {
  tmp.titre <- xpathSApply(lem.articles[[i]], ".", xmlValue)
  tmp.lien <- xpathSApply(lem.articles[[i]], "./@href")
  lem.titres <- c(lem.titres, tmp.titre)
  lem.liens <- c(lem.liens, tmp.lien)
}
lem.table2 <- data.frame(titre = lem.titres, lien = lem.liens)


## Extraction des titres et liens des 21 articles à la une
## Méthode 3 : avec xscrape 
## Remarque : xscrape garantit de ne pas avoir de surprises (mauvais alignement
## des lignes) dans le résultat, contrairement aux deux méthodes précédentes.
lem.table3 <- xscrape(
  lemonde.parse, 
  row.xpath = "//section[contains(@class, 'zone--homepage')]//div[contains(@class, 'article')]//a", 
  col.xpath = c(titre = ".", lien = "./@href"))


## Décompte des liens internes et externes
lemonde.liens <- xpathSApply(lemonde.parse, "//a/@href")
lemonde.lien.interne <- 
  grepl("^https?://[^/]+?lemonde[.]fr\\b", lemonde.liens) |
  grepl("^#$", lemonde.liens)
table(lemonde.lien.interne)



#############
## Exercice : europresse
## URL : https://css.cnrs.fr/scrape/europresse
## Consigne : 
## 1 - Télécharger et parser la page
## 2 - Extraire, en une data.frame comprenant un article par ligne, les champs 
## suivants en colonnes : journal, auteur, date, titre, sous-titre, et texte
#############

## Téléchargement et parsing
epress.brut <- GET("https://css.cnrs.fr/scrape/europresse")
epress.char <- as.character(epress.brut)
writeLines(epress.char, "europresse.html")
epress.parse <- htmlParse("europresse.html")

## Méthode 1 : 
## Extraction avec xscrape
## Note : la version xml2 permet de nettoyer le texte
epress.table <- xscrape(
  epress.parse, engine = "xml2",
  row.xpath = "//article", 
  col.xpath = c(journal = './/span[@class="DocPublicationName"]', 
                auteur = './/div[@class="docAuthors"]', 
                date = './/span[@class="DocHeader"]', 
                titre = './/p[contains(@class, "titreArticleVisu")]', 
                soustitre = './/p[@class="rdp__subtitle"]', 
                texte = './/section'))


## Méthode 2 : 
## Extraction en passant par les noeuds intermédiaires (ici les articles) et des
## boucles
epress.articles <- xpathSApply(epress.parse, "//article")
## Créons une fonction pour nous assurer qu'un résultat soit toujours de
## longueur 1 : s'il est vide on lui donne NA, s'il est multiple on concatène
## les chaînes de caractères
postprod <- function(x) {
  if (length(x) == 0) return(NA)
  if (length(x) > 1) return(paste(x, collapse = " | "))
  x
}
## Et procédons à la boucle (ici uniquement pour journal, date, titre et texte)
epress.journal <- epress.date <- epress.titre <- epress.texte <- NULL
for (iart in seq_along(epress.articles)) {
  ## Journal
  tmp.journal <- xpathSApply(epress.articles[[iart]], 
                             './/span[@class="DocPublicationName"]', xmlValue)
  epress.journal <- c(epress.journal, postprod(tmp.journal))
  
  ## Date
  tmp.date <- xpathSApply(epress.articles[[iart]], 
                             './/span[@class="DocHeader"]', xmlValue)
  epress.date <- c(epress.date, postprod(tmp.date))
  
  ## Titre
  tmp.titre <- xpathSApply(epress.articles[[iart]], 
                          './/p[contains(@class, "titreArticleVisu")]', xmlValue)
  epress.titre <- c(epress.titre, postprod(tmp.titre))
  
  ## Texte
  tmp.texte <- xpathSApply(epress.articles[[iart]], 
                          './/section', xmlValue)
  epress.texte <- c(epress.texte, postprod(tmp.texte))
}

epress.table2 <- data.frame(journal = epress.journal, 
                            date = epress.date, 
                            titre = epress.titre, 
                            texte = epress.texte)


#############
## Exercice : leboncoin
## URL : https://css.cnrs.fr/scrape/boncoin-page1 , 
## https://css.cnrs.fr/scrape/boncoin-page2, 
## https://css.cnrs.fr/scrape/boncoin-page3
## Consigne : 
## 1 - Télécharger et parser les trois pages en une liste
## 2 - Extrayez de la première page les informations suivantes en une data.frame
## avec une ligne par article et les colonnes : description et prix
## 3 - Transformer ces trois pages en une seule data.frame, avec une ligne par 
## objet en vente, et en colonne : la description de l'objet, le prix, 
## le code postal et l'heure de dépôt de l'annonce
#############

## Téléchargement 
urls <- paste0("https://css.cnrs.fr/scrape/boncoin-page", 1:3)
fichiers <- gsub("^.*/(.*)$", "\\1.html", urls)
for (i in 1:3) {
  cat(urls[i], "\n")
  bc.brut <- GET(urls[i])
  writeLines(as.character(bc.brut), fichiers[i])
  Sys.sleep(1)
}

## Parsing en une liste de trois pages parsées
bc.parse <- lapply(fichiers, htmlParse)

## Extraction depuis la première page : description et prix
bc.page1 <- xscrape(
  bc.parse[[1]], 
  row.xpath = '//div[contains(@class, "styles_adCard__2YFTi")]', 
  col.xpath = c(description = './/p[contains(@class, "AdCardTitle")]', 
                prix = './/span[@data-qa-id="aditem_price"]'))

## Extraction depuis les trois pages : description, prix, code postal, heure
bc.articles <- xscrape(
  bc.parse, 
  row.xpath = '//div[contains(@class, "styles_adCard__2YFTi")]', 
  col.xpath = c(description = './/p[contains(@class, "AdCardTitle")]', 
                prix = './/span[@data-qa-id="aditem_price"]', 
                datelieu = './/span[@class="_2k43C Dqdzf cJtdT _3j0OU"]//span'))
## Nettoyage code postal :
bc.articles$postal <- gsub("^.*(\\d{5}).*$", "\\1", bc.articles$datelieu)
bc.articles$postal <- as.numeric(bc.articles$postal)
## Nettoyage heure : 
bc.articles$heure <- gsub("^.*(\\d{2}:\\d{2}).*$", "\\1", bc.articles$datelieu)
bc.articles$heure[!grepl(":", bc.articles$heure)] <- NA
