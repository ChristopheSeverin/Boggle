/* Same on server side */
// word length -> point(s)
const points = [0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
const game_duration = 50; // in seconds
const solutions_duration = 40; // in seconds
let timer = 180; // in seconds

/* Client id, given by the server */
let id = 0;

/* Page elements */
const _solutions = document.getElementById("solutions");
const _grid = document.getElementById("grid");
const _rank = document.getElementById("rank");

const _word = document.getElementById("word");
const _buttonErase = document.getElementById("erase");
const _buttonValidate = document.getElementById("enter");
const _status = document.getElementById("status");

const _timer = document.getElementById("timer");
const _score = document.getElementById("score");

/* Boggle */
let gameOn = false; // is game on ?
let grid = "";
let letterToPositions = [];
/* Grid described as a graph (adjacency lists) */
const neighbour = [
  // line 1
  [1, 4, 5],
  [0, 2, 4, 5, 6],
  [1, 3, 5, 6, 7],
  [2, 6, 7],
  // line 2
  [0, 1, 5, 8, 9],
  [0, 1, 2, 4, 6, 8, 9, 10],
  [1, 2, 3, 5, 7, 9, 10, 11],
  [2, 3, 6, 10, 11],
  // line 3
  [4, 5, 9, 12, 13],
  [4, 5, 6, 8, 10, 12, 13, 14],
  [5, 6, 7, 9, 11, 13, 14, 15],
  [6, 7, 10, 14, 15],
  // line 4
  [8, 9, 13],
  [8, 9, 10, 12, 14],
  [9, 10, 11, 13, 15],
  [10, 11, 14],
];

let word = "";
let userPath = []; // UserPath produce word
let botPath = []; // (for automatic search)
let score = 0; // user score
let solutions = []; // found by user
