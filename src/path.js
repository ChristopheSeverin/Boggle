// Cells
function addToPath(i) {
  const obj = document.getElementById(i.toString());
  obj.classList.add("selected");
  userPath.push(i);
  word += grid[i];
  printWord();
  refreshCellsClickableStatus();
}

// Remove last cell from user's path
function popPath() {
  const last = userPath.pop();
  document.getElementById(last).classList.remove("selected");
  word = word.slice(0, word.length - 1);
  printWord();
  refreshCellsClickableStatus();
}

function erasePath() {
  while (userPath.length > 0) {
    popPath();
  }
}

function validatePath() {
  if (gameOn) {
    if (word.length < 3) {
      _status.textContent = "Le mot doit posséder au moins 3 lettres ";
      printSeeRules();
    } else if (solutions.includes(word)) {
      printWordStatus(word, "2");
      erasePath();
    } else if (socket.readyState === 1) {
      socket.send(word);
      erasePath();
    } else {
      _status.textContent =
        "Problème de connexion. Veuillez rafraîchir la page.";
    }
  }
}
// Refresh all cells clickable status
function refreshCellsClickableStatus() {
  if (!gameOn) {
    for (let i = 0; i <= 15; i++) {
      document.getElementById(i.toString()).classList.remove("clickable");
    }
  } else if (userPath.length == 0) {
    for (let i = 0; i <= 15; i++) {
      document.getElementById(i.toString()).classList.add("clickable");
    }
  } else {
    for (let i = 0; i <= 15; i++) {
      if (
        userPath[userPath.length - 1] == i ||
        (neighbour[userPath[userPath.length - 1]].includes(i) &&
          !userPath.includes(i))
      ) {
        document.getElementById(i.toString()).classList.add("clickable");
      } else {
        document.getElementById(i.toString()).classList.remove("clickable");
      }
    }
  }
}
