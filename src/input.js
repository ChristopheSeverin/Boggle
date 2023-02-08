// Handle socket
let socket = new WebSocket("ws://" + window.location.host + "/websocket");

socket.onmessage = function (event) {
  const type = event.data[0];
  const data = event.data.substring(1);
  if (type == "0" || type == "2") {
    printWordStatus(data, type);
  } else if (type == "1") {
    addSolution(data);
  } else if (type == "g") {
    newGame(data);
  } else if (type == "s") {
    gameOver(data);
  } else if (type == "r") {
    printRank(data);
  } else if (type == "n") {
    begin(data);
  }
};

socket.onclose = function () {
  gameOn = false;
  erasePath();
  refreshCellsClickableStatus();
  _status.textContent = "Vous êtes déconnecté(e). Veuillez rafraîchir la page.";
};

// Handle keyboard input
window.addEventListener("keydown", (e) => {
  if (gameOn) {
    if (/^[A-Z]$/.test(e.key)) {
      addLetter(e.key);
    } else if (/^[a-z]$/.test(e.key)) {
      addLetter(e.key.toUpperCase());
    } else if (word.length >= 1 && e.key == "Backspace") {
      popPath();
    } else if (word.length >= 1 && e.key == "Delete") {
      erasePath();
    } else if (e.key == "Enter") {
      validatePath();
    }
  }
});

// Handle mouse input
_grid.addEventListener("click", (e) => {
  const obj = e.target;
  if (gameOn && obj.nodeName == "TD") {
    // If the clicked object is a cell
    const id = parseInt(obj.id);
    if (
      userPath.length == 0 ||
      (!userPath.includes(id) &&
        neighbour[userPath[userPath.length - 1]].includes(id))
    ) {
      addToPath(id);
    } else if (userPath[userPath.length - 1] == id) {
      popPath();
    } else {
      _status.textContent =
        "Les lettres saisies doivent être consécutives dans la grille ";
      printSeeRules();
    }
  }
});

// Handle buttons
_buttonErase.addEventListener("click", () => {
  erasePath();
});

_buttonValidate.addEventListener("click", () => {
  validatePath();
});
