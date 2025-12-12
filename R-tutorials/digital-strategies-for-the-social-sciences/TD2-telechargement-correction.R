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


