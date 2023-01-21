function createSolutionsColumn() {
  for (let i = 16; i >= 3; i--) {
    const _ajout = document.createElement("li");
    _ajout.id = "s" + i.toString();
    _solutions.appendChild(_ajout);
  }
}
function cleanOutputSolutions() {
  for (let i = 3; i <= 16; i++) {
    document.getElementById("s" + i.toString()).textContent = "";
  }
}

function addSolution(w) {
  solutions.push(w);
  score += points[w.length];
  printScore(0);

  const _li = document.getElementById("s" + w.length.toString());
  if (_li.textContent != "") {
    _li.innerHTML += " " + w.toLowerCase();
  } else {
    _li.innerHTML = w[0] + w.substring(1).toLowerCase();
  }

  printWordStatus(w, "1");
}

function outputSolutions(sol) {
  cleanOutputSolutions();
  sol.forEach((w) => {
    const _span = document.createElement("span");
    if (solutions.includes(w)) {
      _span.classList.add("found");
    }
    const _li = document.getElementById("s" + w.length.toString());
    if (_li.textContent != "") {
      _li.innerHTML += " ";
      _span.textContent = w.toLowerCase();
    } else {
      _span.textContent = w[0] + w.substring(1).toLowerCase();
    }
    _li.appendChild(_span);
  });
}
