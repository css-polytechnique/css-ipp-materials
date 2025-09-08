## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 6 : Téléchargement avancé

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
