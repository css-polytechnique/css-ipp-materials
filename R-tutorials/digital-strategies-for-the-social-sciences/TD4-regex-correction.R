## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 4 : Expressions régulières (regex)

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
## Exemples utiles : caractères unicode, regex approximatif
#############

## Caractères unicode (signes diacritiques de toutes langues) : 
## https://www.regular-expressions.info/unicode.html
grep("\\p{L}", c("àéï", "...", "aei"), perl = T)
grep("\\w", c("àéï", "...", "aei"), perl = T)

grep("\\p{Ll}", c("ÂÉÖ", "...", "àëî"), perl = T)
grep("\\p{Lu}", c("ÂÉÖ", "...", "àëî"), perl = T)
grep("\\w", c("ÂÉÖ", "...", "àëî"), perl = T)

## Regex approximatif : agrep
mitterr <- c("Mitterrand", "Miterrand", "Miterand", "Mittérand", "mittérand")
agrep("Mitterrand", mitterr, value = T)
agrep("Mitterrand", mitterr, value = T, max.distance = 1)
agrep("Mitterrand", mitterr, value = T, max.distance = 2, ignore.case = TRUE)


#############
## Exercice : Lemonde 
## URL : https://css.cnrs.fr/scrape/lemonde
## Consigne : 
## 1 - Nettoyer les titres d'articles (avec gsub)
## 2 - En extraire les titres mentionnant Macron, en un vecteur (avec grep)
## 3 - Construire une data.frame contenant tous les titres en lignes, avec des
## colonnes pour indiquer la présence des mots "régionales", "culture", "Macron"
## (avec grepl)
#############

## Téléchargement et parsing
lem <- GET("https://css.cnrs.fr/scrape/lemonde")
writeLines(as.character(lem), "lemonde.html")
lem <- htmlParse("lemonde.html")

## Extraction des titres d'articles (pas forcément le meilleur xpath)
titres <- xpathSApply(lem, "//a[count(*[@class='article__title'])>0]", xmlValue)

## 1 - Nettoyer les titres d'articles (avec gsub)
titres <- gsub("^\\s+|\\s+$", "", titres)
titres <- gsub("Article réservé .*? abonnés", "", titres)
titres <- gsub("\n", " ", titres)
titres <- gsub("\\s+", " ", titres)
titres <- gsub("^\\s+|\\s+$", "", titres)
titres <- gsub("(\\p{Ll})(\\p{Lu})", "\\1 \\2", titres, perl = TRUE)

## 2 - En extraire les titres mentionnant Macron, en un vecteur (avec grep)
titres.macron <- grep("Macron", ignore.case = TRUE, value = TRUE, titres)

## 3 - Construire une data.frame contenant tous les titres en lignes, avec des
## colonnes pour indiquer la présence des mots "régionales", "culture", "Macron"
## (avec grepl)
titres.tab <- data.frame(
  titre = titres, 
  regionales = grepl("\\brégionales\\b", ignore.case = TRUE, titres), 
  culture = grepl("\\bculture\\b", ignore.case = TRUE, titres), 
  macron = grepl("\\bMacron", ignore.case = TRUE, titres))

write.csv(titres.tab, row.names = FALSE, "lemonde-titres.csv")




#############
## Exercice : Tableau des prix Nobel
## URL : https://www.css.cnrs.fr/scrape/nobel_all.html
## Consigne : 
## 1 - Extraire et nettoyer, en un vecteur (un élément par année), les noms
## des récipiendaires du prix Nobel de physique
## 2 - Trouvez les noms de famille et (premiers) prénoms les plus courants parmi
## l'ensemble des récipiendaires de prix Nobel
#############

## Téléchargement, parsing
nob.brut <- GET("https://css.cnrs.fr/scrape/nobel_all.html")
writeLines(as.character(nob.brut), "nobel_all.html")
nob.parse <- htmlParse("nobel_all.html", encoding = "UTF-8")

## 1 - Extraire et nettoyer, en un vecteur (un élément par année), les noms
## des récipiendaires du prix nobel de physique
nob.phy <- xpathSApply(nob.parse, "//td[2]", xmlValue)

## Espaces à la fin
nob.phy <- gsub("\\s+$", "", nob.phy)
## Correction des "Mather, John C. John C. Mather ;Smoot, George George Smoot"
nob.phy <- gsub("(.*), +(.*) +\\2 +\\1", "\\2 \\1", nob.phy, perl = TRUE)
## Espace après ;
nob.phy <- gsub(";(\\p{L})", "; \\1", nob.phy, perl = TRUE)

## Correction des "Arthur AshkinGérard MourouDonna Strickland"
grep("\\p{Ll}\\p{Lu}", nob.phy, value = TRUE, perl = TRUE)
nob.phy <- gsub("(\\p{Ll})(\\p{Lu})", "\\1 ; \\2", nob.phy, perl = TRUE)
grep("Mc ; ", nob.phy, value = TRUE)
nob.phy <- gsub("Mc ; ", "Mc", nob.phy)

## A nouveau les espaces de fin
nob.phy <- gsub("\\s+", " ", nob.phy, perl = TRUE)
grep("\\s{2}", nob.phy, value = TRUE, perl = TRUE)
grep("\\p{Zs}{2}", nob.phy, value = TRUE, perl = TRUE)



## 2 - Trouvez les noms de famille et (premiers) prénoms les plus courants parmi
## l'ensemble des récipiendaires de prix Nobel

## Extraction des noms individuels, séparés par des virgules
nob.noms <- xpathSApply(nob.parse, 
                        "//td/span[contains(@style, 'display')]", 
                        xmlValue)
## Noms manquants
nob.noms.manquants <- xpathSApply(nob.parse, 
                                  "//td/a[count(preceding-sibling::span)=0]", 
                                  xmlValue)


## Noms de famille
nob.fam <- gsub("^(.*?),.*", "\\1", nob.noms)
sort(table(nob.fam))

## Prénoms
nob.pre <- gsub("^.*?, ", "", nob.noms)
nob.pre1 <- gsub("^(\\p{L}+?)\\b.*", "\\1", nob.pre, perl = TRUE)
sort(table(nob.pre1))

## Tous les prénoms
nob.pre.tous <- strsplit(nob.pre, "\\P{L}", perl = TRUE)
nob.pre.tous <- do.call(c, nob.pre.tous)
nob.pre.tous <- nob.pre.tous[nchar(nob.pre.tous) > 1]
sort(table(nob.pre.tous))
