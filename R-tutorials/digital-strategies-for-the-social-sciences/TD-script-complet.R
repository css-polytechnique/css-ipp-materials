## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Script complet des TD de SNSS

## Ce script est encodé en UTF-8 ; si les accents ne s'affichent pas bien, 
## utilisez dans Rstudio le menu Fichier -> Réouvrir avec encodage... 
## et choisissez UTF-8.


###############################################################################
## Séance 2 : Téléchargement / parsing
###############################################################################

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

## Téléchargement et enregistrement sur le disque dur

# perdue.brut <- GET("https://css.cnrs.fr/scrape/perdue") # Version minimale
perdue.brut <- GET("https://css.cnrs.fr/scrape/perdue",
                   user_agent("Je viens en paix, voici mon adresse mail :"))

perdue.char <- as.character(perdue.brut)
perdue.char
writeLines(perdue.char, "perdue.html")

## Parsing
# perdue.parse <- htmlParse("perdue.html")
perdue.parse <- htmlParse("perdue.html", encoding = "UTF-8")
# perdue.parse <- htmlParse(perdue.brut)
# perdue.parse <- htmlParse("https://css.cnrs.fr/scrape/perdue", isURL = TRUE) # marche parfois
perdue.parse

perdue.arbre <- htmlTreeParse("perdue.html")

## Ex en avance sur le cours : 
perdue.titre <- xpathSApply(perdue.parse, "//h1", xmlValue)



#############
## Exercice : Nobel news
## URL : https://css.cnrs.fr/scrape/nobel_news.html
## Consigne : Idem
#############

nobel.brut <- GET("https://css.cnrs.fr/scrape/nobel_news.html")
nobel.char <- as.character(nobel.brut)
nobel.char
writeLines(nobel.char, "nobelnews.html")

nobel.parse <- htmlParse("nobelnews.html")
nobel.parse




#############
## Site difficile à télécharger : encodage, cookies, javascript
## URL : https://css.cnrs.fr/scrape/reperdue
## Consigne : Idem
#############

## GET ne marche pas (il ne supporte pas le javascript)
## Résultat : aucun
rp.brut <- GET("https://css.cnrs.fr/scrape/reperdue")
rp.brut
as.character(rp.brut)


## Alternative : polite, utilise GET mais de manière "polie"
## Résultat : télécharge la page d'erreur disant qu'il faut du javascript
library(polite)
rp.polbow <- bow("https://css.cnrs.fr/scrape/reperdue")
rp.polrip <- rp.polbow %>% nod("https://css.cnrs.fr/scrape/reperdue") %>% rip()
rp.polrip <- readLines(rp.polrip)
writeLines(rp.polrip, "reperdue-polite.html")

htmlParse("reperdue-polite.html")


## Alternative : getURL, du package RCurl
## Résultat : télécharge la page d'erreur disant qu'il faut du javascript
library(RCurl)
## Pour activer les cookies de RCurl
mycurl <- getCurlHandle()
curlSetOpt(cookiejar= "Rcookies", curl = mycurl)
## Téléchargement avec getURL
rp.curl <- getURL("https://css.cnrs.fr/scrape/reperdue", curl = mycurl)
rp.curl
## Téléchargement avec getURL en précisant le bon encodage
rp.curl <- getURL("https://css.cnrs.fr/scrape/reperdue", curl = mycurl, 
                  .encoding= "ISO-8859-1")
rp.curl
writeLines(rp.curl, "reperdue-rcurl.html")



## Alternative : read_html, des packages xml2 et rvest
## Résultat : télécharge la page d'erreur disant qu'il faut du javascript
library(rvest)
library(xml2)
## Premier téléchargement et fonction pour détecter l'encodage
rp.rvest <- read_html("https://css.cnrs.fr/scrape/reperdue")
rvest::html_encoding_guess(rp.rvest)
## Second téléchargement, avec le bon encodage
rp.rvest <- read_html("https://css.cnrs.fr/scrape/reperdue", 
                      encoding = "ISO-8859-1")
## Parsing direct de cet objet avec htmlParse
rp.rvest.parse <- htmlParse(rp.rvest)
rp.rvest.parse
## Enregistrement sur le disque de la page téléchargée avec read_html
write_html(rp.rvest, "reperdue-rvest.html")


## Alternative : téléchargement direct avec htmlParse
## Résultat : erreur
rp.direct <- htmlParse("https://css.cnrs.fr/scrape/reperdue", isURL = TRUE)


## Alternative : enregistrement à la main depuis le navigateur (clic droit)
## Résultat : parfait, mais on préfère quand tout est écrit en code...
clicdroit <- htmlParse("~/Downloads/perducookies.html")
clicdroit

## Alternative (avancée) : piloter un vrai navigateur avec RSelenium
## Résultat : parfait (sauf encodage...)
library(RSelenium)
bro.driver <- rsDriver(browser = "firefox", phantomver = NULL, chromever = NULL)
bro <- bro.driver$client

bro$navigate("https://css.cnrs.fr/scrape/reperdue")
bro.source <- bro$getPageSource()[[1]]
writeLines(bro.source, "reperdue-selenium.html")

bro.driver$server$stop() # Eteindre le navigateur ouvert avec RSelenium

selen.parse <- htmlParse("reperdue-selenium.html", encoding = "ISO-8859-1")
selen.parse


################################################################################
## Séance 3 : Sélection de données avec XPath
################################################################################


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


################################################################################
## Séance 4 : Expressions régulières (regex)
################################################################################


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


################################################################################
## Séance 5 : Automatisation de la récolte
################################################################################

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



################################################################################
## Séance 6 : Téléchargement avancé
################################################################################

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
library(RSelenium)


#############
## Exercice : extraction du code source d'une page dynamique (javascript), avec
## RSelenium
## URL : https://css.cnrs.fr/scrape/multiscroll.html
## Consigne : Télécharger le code source de la page entière, avec toutes les
## tables de multiplication.
#############

## Sans utiliser RSelenium
multi.ht <- GET("https://css.cnrs.fr/scrape/multiscroll.html")
writeLines(as.character(multi.ht), "multiscroll-get.html")
multi.ht.p <- htmlParse("multiscroll-get.html")
multi.ht.p

## RSelenium avec docker
## > sudo docker run -d -p 4445:4444 selenium/standalone-chrome
## A la fin de la session : 
## > sudo docker stop 5735eb391764d3c7d
bro <- remoteDriver(port = 4445L, browserName = "chrome")
bro$open()
bro$navigate("https://css.cnrs.fr/scrape/multiscroll.html")
bro$screenshot(display = TRUE)
bro$close()


## Rselenium sans docker (standard)
bro.driver <- rsDriver(browser = "firefox",
                       phantomver = NULL, chromever = NULL, iedrver = NULL)
# bro.driver <- rsDriver(browser = "chrome", 
#                        phantomver = NULL, geckover = NULL, iedrver = NULL)
bro <- bro.driver$client

bro$navigate("https://css.cnrs.fr/scrape/multiscroll.html")
bro.elt <- bro$findElement(using = "xpath", value = "//body")

lafin <- NULL
while (length(lafin) == 0) {
  bro.elt$sendKeysToElement(list(key = "end"))
  bro.source <- bro$getPageSource()[[1]]
  bro.source.p <- htmlParse(bro.source)
  lafin <- xpathSApply(bro.source.p, "//p[contains(text(), 'bravo')]", xmlValue)
}

writeLines(bro.source, "multiscroll-sel.html")

selen.parse <- htmlParse("multiscroll-sel.html", encoding = "UTF-8")
selen.parse

bro.driver$server$stop()


#############
## Exercice : accéder à une page après authentification (nom d'utilisateur et
## mot de passe)
## URL : https://css.cnrs.fr/scrape/login.html
## Consigne : Trouver dans le code source de la page le login et le mot de
## passe, et les utiliser pour se connecter, puis télécharger le code source 
## de la page à laquelle on accède après connexion. 
## Remarque : la page d'accueil contient du javascript, donc on ne peut pas 
## employer les fonctions du package rvest (qui permettent de remplir des
## formulaires simples)
#############

## Rselenium sans docker
bro.driver <- rsDriver(browser = "firefox",
                       phantomver = NULL, chromever = NULL, iedrver = NULL)
# bro.driver <- rsDriver(browser = "chrome", 
#                        phantomver = NULL, geckover = NULL, iedrver = NULL)
bro <- bro.driver$client

bro$navigate("https://css.cnrs.fr/scrape/login.html")
bro.elt <- bro$findElement(using = "xpath", value = "//input[@name='id']")
bro.elt$sendKeysToElement(list("scraping"))
bro.elt <- bro$findElement(using = "xpath", value = "//input[@name='pass']")
bro.elt$sendKeysToElement(list("supermotdepasse"))
bro.elt <- bro$findElement("xpath", "//input[@value='Login']")
bro.elt$clickElement()

## Ici il faut attendre le chargement de la page
bro.source <- bro$getPageSource()[[1]]

writeLines(bro.source, "apres-login.html")

selen.parse <- htmlParse("apres-login.html", encoding = "UTF-8")
selen.parse

bro.driver$server$stop()
