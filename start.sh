#!/bin/bash

mkdir -p static
cd src
cat var.js input.js boggle.js path.js solutions.js game.js print.js >script.js
minify script.js >../static/script.js
rm script.js
minify style.css >../static/style.css
minify main.html >../static/main.html
minify regles.html >../static/regles.html
cd ..
npx esy start
