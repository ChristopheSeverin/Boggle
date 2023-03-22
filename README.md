# Boggle multijoueurs

Jeu du [Boggle](https://fr.wikipedia.org/wiki/Boggle) où les participants s'affrontent sur une même grille. Une version tourne sur [boggle.duplicate.games](http://boggle.duplicate.games).

## Installation

La partie serveur est programmée en [OCaml](https://ocaml.org/) grâce à l'infrastructure [Dream](https://aantron.github.io/dream/).
Nous recommandons d'installer ce dernier en passant par le gestionnaire de paquet [opam](https://opam.ocaml.org/) :

```
opam install dream
```

## Dictionnaire

Le jeu nécessite un dictionnaire (une liste de mots) nommé par defaut _fr.txt_ et placé dans le répertoire _dictionaries_. Nous recommandons l'usage de l'[officiel du Scrabble](https://www.fisf.net/officiel-du-scrabble/presentation.html).

## Paramètres

Vous pouvez changer des paramètres du jeu tels que la durée d'une partie, l'attribution des points ou le nombre maximal de joueurs autorisés dans _bin/parameters.ml_

## Construction

Vous pouvez construire le serveur grâce au script _build.sh_ (dont il vous faudra probablement autoriser l'exécution) :

```
./build.sh
```

Celui-ci compresse (en utilisant [minify](https://github.com/matthiasmullie/minify)) les fichiers clients (JavaScript, CSS et HTML) appartenant au dossier _src_ afin de les placer dans le dossier _static_ (qu'il crée si besoin) puis construit le serveur grâce à la commande :

```
dune build
```

## Lancement

Vous pouvez démarrer le serveur grâce à la commande :

```
dune exec Boggle
```
