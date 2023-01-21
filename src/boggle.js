/* Functions for keyboard input */
function buildLetterToPositions() {
  letterToPositions = [];
  for (let i = 0; i < 26; i++) {
    letterToPositions.push([]);
  }
  for (let i = 0; i <= 15; i++) {
    letterToPositions[grid.charCodeAt(i) - "A".charCodeAt(0)].push(i);
  }
}

// Return array of cell's id that contain letter l
function letterInGrid(l) {
  return letterToPositions[l.charCodeAt(0) - "A".charCodeAt(0)];
}

// Try to concatenate a letter to UserPath
// if impossible then call exhautive search function
function addLetter(l) {
  const lInGrid = letterInGrid(l);
  if (lInGrid.length == 0) {
    _status.textContent = "La lettre doit être présente dans la grille ";
    printSeeRules();
  } else if (userPath.length == 0) {
    addToPath(lInGrid[0]);
  } else {
    const neighbourLast = neighbour[userPath[userPath.length - 1]];
    for (const i of lInGrid) {
      if (!userPath.includes(i) && neighbourLast.includes(i)) {
        addToPath(i);
        return;
      }
    }
    if (searchWord(word + l)) {
      erasePath();
      botPath.forEach((i) => addToPath(i));
      botPath = [];
    } else {
      _status.textContent =
        "Les lettres saisies doivent être consécutives dans la grille ";
      printSeeRules();
    }
  }
}

// Recursive and exhautive search for word w in grid.
// Result in botPath if it exists
function searchWord(w) {
  if (w.length == 0) {
    return true;
  } else {
    let candidates = letterInGrid(w[0]);
    if (botPath.length > 0) {
      const neighbourLast = neighbour[botPath[botPath.length - 1]];
      candidates = candidates.filter(
        (i) => !botPath.includes(i) && neighbourLast.includes(i)
      );
    }
    if (candidates.length == 0) {
      return false;
    } else {
      for (const i of candidates) {
        botPath.push(i);
        if (searchWord(w.substring(1))) {
          return true;
        }
        botPath.pop();
      }
      return false;
    }
  }
}
