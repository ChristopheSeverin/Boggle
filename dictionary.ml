let dictionary_file = "dictionaries/ODS8.txt"

let letter_frequency file_name =
  let letter_occurrence = Array.make 26 0 in
  let file = open_in file_name in
  let () =
    try
      while true do
        let line = input_line file in
        String.iter
          (fun c ->
            letter_occurrence.(Char.code c - Char.code 'A') <-
              letter_occurrence.(Char.code c - Char.code 'A') + 1)
          line
      done
    with _ -> close_in file
  in
  let total = Array.fold_left (fun s o -> s + o) 0 letter_occurrence in
  Array.init 26 (fun i ->
      float_of_int letter_occurrence.(i) /. float_of_int total)

(* Random letter *)
let random_letter =
  let letter_freq = letter_frequency dictionary_file in
  Random.self_init ();
  fun () ->
    let n = Random.float 1.0 in
    let rec letter ?(cumul = 0.0) ?(i = 0) n =
      if i >= 26 then 'Z'
      else if n <= cumul +. letter_freq.(i) then Char.chr (i + Char.code 'A')
      else letter ~cumul:(cumul +. letter_freq.(i)) ~i:(i + 1) n
    in
    letter n

(* Tree dictionary *)
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
