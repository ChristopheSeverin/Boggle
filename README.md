# Boggle multijoueurs

## Installation

```
npm install esy && npx esy
```

## Lancement

Vous pouvez lancer le serveur grâce au script _start.sh_ (dont il vous faudra probablement autoriser l'exécution) :

```
./start.sh
```

Celui-ci compresse (en utilisant [minify](https://github.com/matthiasmullie/minify)) les fichiers clients (JavaScript, CSS et HTML) appartenant au dossier _src_ afin de les placer dans le dossier _static_ (qu'il crée si besoin) puis démarre le serveur grâce à la commande :

```
npx esy start
```

## Langages

La partie serveur est programmée en [OCaml](https://ocaml.org/) grâce à l'infrastructure [Dream](https://aantron.github.io/dream/).
