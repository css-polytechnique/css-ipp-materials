## Stratégies Numériques en Sciences Sociales - 2021
## Julien Boelaert, Etienne Ollion
## Séance 1 : Introduction à R

## Ce script est encodé en UTF-8 ; si les accents ne s'affichent pas bien, 
## utilisez dans Rstudio le menu Fichier -> Réouvrir avec encodage... 
## et choisissez UTF-8.


## R comme une calculatrice
1 + 1
23 * 45

## Créer un objet simple
mamult <- 23 * 45
mamult

mamult * 2

untexte <- "Bonjour bonjour"
untexte

bonjour

## Information sur les objets : fonction str
str(mamult)
str(untexte)


## Créer des vecteurs
mesnombres <- c(1, 4, 18, 25, 34)
mesnombres
str(mesnombres)

mesnombres.texte <- as.character(mesnombres)
mesnombres.texte
as.numeric(mesnombres.texte)

mestextes <- c("aa", "bb", "cc", "dd", "ee")
mestextes

sequence <- 1:50
sequence
sequence <- seq(from = 1, to = 99, by = 2)
sequence
sequence <- seq_along(mesnombres)
sequence

## Fonctions sur les vecteurs
summary(mesnombres)
mean(mesnombres)
mesnombres + 1

help(mean)
?mean


## Accéder aux éléments d'un vecteur : l'indexation
mesnombres[3]
mesnombres[1:3]
mesnombres[c(1, 2, 5)]

mesnombres[1] <- 18
mesnombres

## Accéder aux éléments d'un vecteur : conditions logiques
mesnombres >= 20
mesnombres == 18
mesnombres < 20

mesnombres[mesnombres >= 20] <- 21
mesnombres


## Vecteurs créés de façon dynamique
levec <- NULL
levec <- c(levec, 12)
levec
levec <- c(levec, 1:10)
levec
levec <- c(levec, 10:1)
levec


## Matrices 
matcol <- cbind(mesnombres, mestextes)
matcol
str(matcol)

matlig <- rbind(mesnombres, mestextes)
matlig

matnombres <- cbind(mesnombres, mesnombres + 1)
matnombres


matnombres[1, 1]
matnombres[3, 2] <- 1
matnombres

matnombres[, 1]
matnombres[, 1, drop = FALSE]

matnombres[1:3, ]

matnombres[matnombres[, 1] <= 20, ]


## data.frame
madf <- data.frame(mesnombres, mestextes)
madf

madf <- data.frame(nombres = mesnombres, textes = mestextes)
madf

madf$nombres
madf$textes
madf[1:3, 1:2]

madf$taille <- ""
madf

madf$taille[madf$nombres <= 20] <- "petit"
madf
madf$taille[madf$nombres > 20] <- "grand"
madf

## Enregistrer la data.frame comme fichier csv sur le disque dur
setwd("~/cours/20-21 SICSS Scraping/playground/") # répertoire de travail
# setwd("C:/dossier1/dossier2") # sous windows
write.csv(madf, row.names = FALSE, "data-frame-exemple.csv")

madf2 <- read.csv("data-frame-exemple.csv")


## Le format le plus souple : listes
uneliste <- list(unnombre = 12, 
                 nombres = mesnombres, 
                 textes = mestextes, 
                 matrice = matnombres, 
                 df = madf)
str(uneliste)

uneliste$nombres
uneliste[[2]]

autreliste <- list()
autreliste[[1]] <- mesnombres
autreliste[[2]] <- madf
str(autreliste)

autreliste$autre <- 1:100
str(autreliste)

