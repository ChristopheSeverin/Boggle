#!/bin/bash
mkdir -p static
cd src
cat var.js input.js boggle.js path.js solutions.js game.js print.js >script.js
# Inject script.js in main.html
awk '
    match($0, "<script></script>") {
        print "<script>"
        while (getline line < jsfile) print line
        print "</script>"
        next
    }
    {print}
' jsfile=script.js main.html >main_with_script.html
minify main_with_script.html >../static/main.html
rm script.js main_with_script.html
minify style.css >../static/style.css
minify regles.html >../static/regles.html
cd ..
dune build
