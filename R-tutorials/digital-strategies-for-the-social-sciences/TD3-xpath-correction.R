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

## Téléchargement et écriture sur le disque dur
nobel.brut <- GET("https://css.cnrs.fr/scrape/nobel_news.html")
nobel.char <- as.character(nobel.brut)
nobel.char
writeLines(nobel.char, "nobelnews.html")

## Parsing depuis le fichier local
nobel.parse <- htmlParse("nobelnews.html", trim = TRUE)
nobel.parse

## Extraction du titre
nobel.titre <- xpathSApply(nobel.parse, "//h1", xmlValue)
# nobel.titre <- xpathSApply(nobel.parse, "/html/body/div/h1", xmlValue)
nobel.titre

## Extraction du sous-titre
nobel.stitre <- 
  xpathSApply(nobel.parse, "//div[@class='jumbotron']/h3", xmlValue)
nobel.stitre

## Extraction du texte
nobel.texte <- 
  xpathSApply(nobel.parse, "//div[@class='panel-body']", xmlValue)
nobel.texte
## Extraction du texte en plusieurs morceaux, suivant les sauts de ligne : 
nobel.texte <- 
  xpathSApply(nobel.parse, "//div[@class='panel-body']//text()", xmlValue)
nobel.texte <- paste(nobel.texte, collapse = "\n")
nobel.texte

## Extraction de la liste des membres du comité
## Ici introduire selectorGadget ?
nobel.nomin <- 
  xpathSApply(nobel.parse, "//div[@class='nomination_person']/p", xmlValue)
nobel.nomin

## Extraction des biographies des membres du comité
nobel.biogr <- 
  xpathSApply(nobel.parse, "//div[@class='nomination_description']/p", xmlValue)
nobel.biogr

## Combinaison
nobel.table <- data.frame(nom = nobel.nomin, biographie = nobel.biogr)
nobel.table

## Extraction des infos du paneau de gauche
nobel.infos <- 
  xpathSApply(nobel.parse, "//div[@class='col-sm-3 well']//text()", xmlValue)
nobel.infos




#############
## Page d'accueil d'un site sur les prix Nobel
## URL : https://www.css.cnrs.fr/scrape/nobel_accueil.html
## Consigne : Télécharger et parser la page d'accueil, puis en extraire la liste
## des liens vers les récipiendaires par décennie, ainsi que les titres et 
## sous-titres associés à ces liens.
## Remarque : attention à l'encodage de la page !
#############

## Téléchargement et enregistrement
accueil.brut <- GET("https://www.css.cnrs.fr/scrape/nobel_accueil.html")
writeLines(as.character(accueil.brut), "nobel_accueil.html")

## Parsing
accueil.parse <- htmlParse("nobel_accueil.html", encoding = "UTF-8")

## Extraction des liens vers les récipiendaires par décennie
decenn.liens <- 
  xpathSApply(accueil.parse, "//div[@class='row']//div[@id='price_winners']//a/@href")
# decenn.liens <- 
#   xpathSApply(accueil.parse, "//div[@class='row']//div[@id='price_winners']//a", xmlAttrs)
# decenn.liens <- decenn.liens["href", ]
decenn.liens <- paste0("https://www.css.cnrs.fr/", decenn.liens)

## Extraction des titres et sous-titres de récipiendaires par décennie
decenn.titre <- 
  xpathSApply(accueil.parse, "//div[@class='row']//div[@id='price_winners']//h5", xmlValue)
decenn.stitre <- 
  xpathSApply(accueil.parse, "//div[@class='row']//div[@id='price_winners']//p", xmlValue)

## Combinaison
decenn.table <- data.frame(decennie = decenn.titre, 
                           soustitre = decenn.stitre, 
                           url = decenn.liens)

## En avance sur le cours : 
library(scraEP)
decenn.aspi <- xscrape(accueil.parse, 
                       row.xpath = "//div[@class='row']//div[@id='price_winners']", 
                       col.xpath = c(decennie = ".//h5", 
                                     soustitre = ".//p", 
                                     url = ".//a/@href"))


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

## Téléchargement et enregistrement
nobeliste.brut <- GET("https://www.css.cnrs.fr/scrape/nobel_all.html")
writeLines(as.character(nobeliste.brut), "nobeliste.html")

## Parsing
nobeliste <- htmlParse("nobeliste.html", encoding = "UTF-8")

## Extraction du tableau en une fois
nobeliste.tableau <- readHTMLTable(nobeliste)
nobeliste.tableau <- nobeliste.tableau[[1]]

## Récipiendaires par année
## Extraction séparée : exploitation de la structure en tableau
nobels.annee <- xpathSApply(nobeliste, "//tr/td[1]", xmlValue)
nobels.physique <- xpathSApply(nobeliste, "//tr/td[2]", xmlValue)
nobels.chimie <- xpathSApply(nobeliste, "//tr/td[3]", xmlValue)
nobels.paran <- data.frame(annee = nobels.annee, 
                           physique = nobels.physique, 
                           chimie = nobels.chimie)

## Liste des récipiendaires individuels, avec lien vers la page wiki
nobels.recip <- xpathSApply(nobeliste, "//td[2]//a | //td[3]//a", xmlValue)
nobels.reciplien <- xpathSApply(nobeliste, "//td[3]//a/@href | //td[2]//a/@href")

## Année de chaque récipiendaire ?
nobels.recipannee <- xpathSApply(nobeliste, "//td//a/../../td[1]", xmlValue)

## Il faut commencer par extraire les balises entières
nobels.recipbalise <- xpathSApply(nobeliste, "//td[2]//a | //td[3]//a")
## Pour ensuite extraire des informations balise par balise
nobels.recipannee <- sapply(nobels.recipbalise, xpathSApply, "./../../td[1]", xmlValue)
nobels.recipannee <- as.character(nobels.recipannee)

## Discipline : faisable en comptant le nombre de cases précédentes sur la ligne
nobels.recipdisc <- sapply(nobels.recipbalise, xpathSApply, "count(./../preceding-sibling::td)", xmlValue)
nobels.recipdisc2 <- NA
nobels.recipdisc2[nobels.recipdisc == 1] <- "Physique"
nobels.recipdisc2[nobels.recipdisc == 2] <- "Chimie"



nobels.reciptab <- data.frame(nom = nobels.recip, 
                              annee = nobels.recipannee,
                              url = nobels.reciplien, 
                              discipline = nobels.recipdisc2)

