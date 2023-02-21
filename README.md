# Boggle multijoueurs

Jeu du [Boggle](https://fr.wikipedia.org/wiki/Boggle) où les participants s'affrontent sur une même grille. Une version tourne sur [boggle.duplicate.games](http://boggle.duplicate.games).

## Installation

La partie serveur est programmée en [OCaml](https://ocaml.org/) grâce à l'infrastructure [Dream](https://aantron.github.io/dream/).
Nous recommandons d'installer ce dernier en passant par le gestionnaire de paquet [opam](https://opam.ocaml.org/) :

```
opam install dream
```

Placez-vous ensuite à la racine du projet et exécutez la commande

```
npm install esy && npx esy
```

## Dictionnaire

Le jeu nécessite un dictionnaire (une liste de mots) nommé par defaut _fr.txt_ et placé dans le répertoire _dictionaries_. Nous recommandons l'usage de l'[officiel du Scrabble](https://www.fisf.net/officiel-du-scrabble/presentation.html).

## Lancement

Vous pouvez lancer le serveur grâce au script _start.sh_ (dont il vous faudra probablement autoriser l'exécution) :

```
./start.sh
```

Celui-ci compresse (en utilisant [minify](https://github.com/matthiasmullie/minify)) les fichiers clients (JavaScript, CSS et HTML) appartenant au dossier _src_ afin de les placer dans le dossier _static_ (qu'il crée si besoin) puis démarre le serveur grâce à la commande :

```
npx esy start
```
