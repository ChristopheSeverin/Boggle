(* Dictionary : Multiway Tree *)
type dictionary = Node of bool * (char * dictionary) list

let rec add_aux i word (Node (b, l) as dic) =
  if i = String.length word then Node (true, l)
  else Node (b, insert i word l dic)

and insert i word list dic =
  let wi = word.[i] in
  match list with
  | [] -> [ (wi, add_aux (i + 1) word (Node (false, []))) ]
  | (c, d) :: l ->
      if c > wi then (c, d) :: insert i word l dic
      else if c = wi then (c, add_aux (i + 1) word d) :: l
      else (wi, add_aux (i + 1) word (Node (false, []))) :: list

let add = add_aux 0

let rec print_aux word dic =
  match dic with
  | Node (true, []) -> Printf.printf "%s\n" word
  | Node (false, []) -> failwith "Inconsistent dictionary"
  | Node (b, l) ->
      if b then Printf.printf "%s\n" word;
      List.iter (fun (c, d) -> print_aux (Printf.sprintf "%s%c" word c) d) l

let print = print_aux ""

let load dictionary_file =
  let dic = ref (Node (false, [])) in
  let file = open_in dictionary_file in
  let () =
    try
      while true do
        let line = input_line file in
        dic := add line !dic
      done
    with _ -> close_in file
  in
  !dic
