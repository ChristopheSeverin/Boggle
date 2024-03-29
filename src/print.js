// Timer
setInterval(() => {
  _timer.textContent =
    Math.floor(timer / 60).toString() +
    ":" +
    (timer % 60).toString().padStart(2, "0");

  if (timer > 0) {
    --timer;
  }
}, 1000);

function refreshButtonsOpacity() {
  if (gameOn) {
    if (word.length >= 3) {
      _buttonValidate.classList.add("valid");
    } else {
      _buttonValidate.classList.remove("valid");
    }
    if (word.length >= 1) {
      _buttonErase.classList.add("valid");
    } else {
      _buttonErase.classList.remove("valid");
    }
  } else {
    _buttonValidate.classList.remove("valid");
    _buttonErase.classList.remove("valid");
  }
}

// 0 : w not accepted
// 1 : w accepted
// 2 : w already found
function printWordStatus(w, status) {
  if (status == "2") {
    _status.textContent = "Vous avez déjà trouvé ";
    const _it = document.createElement("i");
    _it.textContent = w.toLowerCase();
    _status.appendChild(_it);
  } else {
    const _it = document.createElement("i");
    _it.textContent = w[0].toUpperCase() + w.substring(1).toLowerCase();
    _status.textContent = "";
    _status.appendChild(_it);
    if (status == "0") _status.innerHTML += " n'est pas accepté";
    if (status == "1") {
      _status.innerHTML +=
        " vous apporte " + points[w.length].toString() + " pt";
      if (points[w.length] > 1) _status.innerHTML += "s";
    }
  }
  _status.innerHTML += ".";
}

function printSeeRules() {
  _status.innerHTML += "(";
  const a = document.createElement("a");
  a.target = "_blank";
  a.href = "/regles";
  a.textContent = "voir les règles";
  _status.appendChild(a);
  _status.innerHTML += ").";
}

// Pretty print word
function printWord() {
  if (word.length == 0) {
    _word.textContent = "";
  } else {
    _word.textContent = word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}

// Print grid
function printGrid() {
  for (let i = 0; i <= 15; i++) {
    document.getElementById(i.toString()).textContent = grid.charAt(i);
  }
}

function printScore(max) {
  _score.textContent = " (" + score.toString();
  if (max > 0) {
    _score.textContent += "/" + max;
  }
  _score.textContent += " pt";
  if (score > 1) {
    _score.textContent += "s";
  }
  if (max > 0) {
    _score.textContent +=
      ", " + Number.parseFloat((score / max) * 100).toFixed(1) + "%";
  }
  _score.textContent += ")";
}

function printRank(rankWord) {
  _rankingHeader.classList.remove("invisible");
  let counter = 1;
  _rank.textContent = "";
  const rank = rankWord.split(" ");

  rank.forEach((r) => {
    const temp = r.split(":");
    const point = temp[0];
    const ids = temp[1].split(",");

    const _li = document.createElement("li");
    _li.value = counter;

    for (let i = 0; i < ids.length; i++) {
      if (ids[i] == id.toString()) {
        const _span = document.createElement("span");
        _span.id = "you";
        _span.innerText = "vous";
        _li.appendChild(_span);

        _shortRank.textContent = "Rang : " + counter.toString();
      } else {
        _li.innerHTML += "j" + ids[i];
      }
      _li.innerHTML += " ";
    }

    _li.innerHTML += "(" + point + " pt";
    if (point != "0" && point != "1") {
      _li.innerHTML += "s";
    }
    _li.innerHTML += ")";

    _rank.appendChild(_li);
    counter += ids.length;
  });
  _shortRank.textContent += "/" + (counter - 1).toString();
}
