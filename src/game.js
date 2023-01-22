function newGrid(w) {
  grid = w;
  buildLetterToPositions();
  printGrid();
}

function startGame() {
  gameOn = true;
  refreshCellsClickableStatus();

  _status.textContent = "À vous de jouer ";
  printSeeRules();
}

function newGame(w) {
  timer = game_duration;

  cleanOutputSolutions();
  solutions = [];
  score = 0;
  _score.textContent = "";
  _rank.textContent = "";
  _insertRank.textContent = "";

  newGrid(w);
  startGame();
}

function gameOver(data) {
  gameOn = false;

  timer = solutions_duration;
  erasePath();
  _status.textContent = "Fin de partie. Une nouvelle va commencer.";

  const sol = data.split(" ");
  outputSolutions(sol.slice(1));
  printScore(sol[0]);

  refreshCellsClickableStatus();
}

function begin(data) {
  const data_list = data.split(" ");
  timer = parseInt(data_list[3]);
  id = parseInt(data_list[0]);
  newGrid(data_list[2]);

  createSolutionsColumn();
  if (data_list[1] == "1") {
    startGame();
  } else {
    _status.textContent = "La partie va commencer ";
    printSeeRules();
  }
}
