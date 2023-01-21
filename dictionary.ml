(* Dictionary *)
type dictionary = Node of bool * (char * dictionary) list

let rec add ?(i = 0) word (Node (b, l) as dic) =
  if i = String.length word then Node (true, l)
  else Node (b, insert i word l dic)

and insert i word list dic =
  let wi = word.[i] in
  match list with
  | [] -> [ (wi, add ~i:(i + 1) word (Node (false, []))) ]
  | (c, d) :: l ->
      if c > wi then (c, d) :: insert i word l dic
      else if c = wi then (c, add ~i:(i + 1) word d) :: l
      else (wi, add ~i:(i + 1) word (Node (false, []))) :: list

let rec print ?(word = "") dic =
  match dic with
  | Node (true, []) -> Printf.printf "%s\n" word
  | Node (false, []) -> failwith "Inconsistent dictionary"
  | Node (b, l) ->
      if b then Printf.printf "%s\n" word;
      List.iter (fun (c, d) -> print ~word:(Printf.sprintf "%s%c" word c) d) l

let load () =
  let dic = ref (Node (false, [])) in
  let file = open_in "dictionaries/ODS8.txt" in
  let () =
    try
      while true do
        let line = input_line file in
        dic := add line !dic
      done
    with _ -> close_in file
  in
  !dic
