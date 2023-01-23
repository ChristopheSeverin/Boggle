let grid = ref ""
let letter_to_positions = Array.init 26 (fun _ -> [])
let solutions = ref []
let points = [| 0; 0; 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14 |]

let min_solutions_for_a_grid = 30
and max_solutions_for_a_grid = 400

let max_grid_points = ref 0
let ods = Dictionary.load ()

(* Grid described as a graph (adjacency lists) *)
let neighbour =
  [|
    [ 1; 4; 5 ];
    [ 0; 2; 4; 5; 6 ];
    [ 1; 3; 5; 6; 7 ];
    [ 2; 6; 7 ];
    (*  *)
    [ 0; 1; 5; 8; 9 ];
    [ 0; 1; 2; 4; 6; 8; 9; 10 ];
    [ 1; 2; 3; 5; 7; 9; 10; 11 ];
    [ 2; 3; 6; 10; 11 ];
    (*  *)
    [ 4; 5; 9; 12; 13 ];
    [ 4; 5; 6; 8; 10; 12; 13; 14 ];
    [ 5; 6; 7; 9; 11; 13; 14; 15 ];
    [ 6; 7; 10; 14; 15 ];
    (*  *)
    [ 8; 9; 13 ];
    [ 8; 9; 10; 12; 14 ];
    [ 9; 10; 11; 13; 15 ];
    [ 10; 11; 14 ];
  |]

let compute_max_grid_points () =
  max_grid_points :=
    List.fold_left (fun sum w -> sum + points.(String.length w)) 0 !solutions

(* Solver *)
let build_letter_to_positions () =
  Array.iteri (fun i _ -> letter_to_positions.(i) <- []) letter_to_positions;
  String.iteri
    (fun i c ->
      letter_to_positions.(Char.code c - Char.code 'A') <-
        i :: letter_to_positions.(Char.code c - Char.code 'A'))
    !grid

let rec solve_grid ?(paths = []) ?(w = "") (Dictionary.Node (b, l)) =
  if b then solutions := w :: !solutions;
  List.iter
    (fun (c, d) ->
      let paths_wc =
        let positions_of_c =
          letter_to_positions.(Char.code c - Char.code 'A')
        in
        if w = "" then List.map (fun i -> [ i ]) positions_of_c
        else
          let paths_from_path_for_wc path =
            List.fold_left
              (fun res i ->
                if
                  (not (List.mem i path)) && List.mem i neighbour.(List.hd path)
                then (i :: path) :: res
                else res)
              [] positions_of_c
          in
          List.fold_left
            (fun accu path -> accu @ paths_from_path_for_wc path)
            [] paths
      in
      if paths_wc <> [] then
        solve_grid ~paths:paths_wc ~w:(Printf.sprintf "%s%c" w c) d)
    l

let print () =
  Dream.log "Grid : %s" !grid;
  Printf.printf "Solution(s) :\n";
  List.iter (Printf.printf "%s\n") !solutions;
  flush stdout

(* New grid *)
let rec new_grid () =
  grid := String.init 16 (fun _ -> Dictionary.random_letter ());
  build_letter_to_positions ();
  solutions := [];
  solve_grid ods;
  if
    List.length !solutions < min_solutions_for_a_grid
    || max_solutions_for_a_grid < List.length !solutions
  then (
    Dream.log "REJECTED Grid : %s" !grid;
    new_grid ())
  else (
    compute_max_grid_points ();
    print ())
