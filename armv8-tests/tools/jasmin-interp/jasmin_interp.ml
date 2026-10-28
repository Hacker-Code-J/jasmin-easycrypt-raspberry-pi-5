(* jasmin_interp FILE.jazz
   Reference interpreter for Jasmin programs, using the ARMv8-A
   architecture definition of the Jasmin library (the semantics that the
   verified compiler preserves).

   Reads queries from stdin, one per line:   FNAME ARG1 ARG2 ...
   Arguments are integers (decimal or 0x-hex) for words, 0/1 for booleans.
   Prints one line per query:                 FNAME RES1 RES2 ...
   with words as unsigned 0x-hex, or "ERROR <message>" if evaluation fails
   (e.g. division by zero, which is undefined in Jasmin). Only functions
   with scalar arguments and results are supported. *)

open Jasmin

module Arch =
  (val CoreArchFactory.get_arch_module Utils.ARMv8A Glob_options.Linux)

let load_file name =
  let open Pretyping in
  try
    name
    |> tt_file Arch.arch_info Env.empty None None
    |> fst |> Env.decls
    |> Compile.preprocess Arch.pointer_data Arch.msf_size Arch.asmOp
  with TyError (loc, e) ->
    Format.eprintf "%a: %a@." Location.pp_loc loc pp_tyerror e;
    exit 2

let value_of_arg ty s =
  let z = Z.of_string s in
  match ty with
  | Prog.Bty Prog.Bool -> Values.Vbool (not (Z.equal z Z.zero))
  | Prog.Bty (Prog.U ws) -> Values.Vword (ws, Conv.word_of_z ws z)
  | Prog.Bty Prog.Int -> Values.Vint (Conv.cz_of_z z)
  | _ -> failwith "unsupported argument type (only scalars)"

let string_of_value = function
  | Values.Vbool b -> if b then "1" else "0"
  | Values.Vword (ws, w) ->
      "0x" ^ Z.format "%x" (Conv.z_unsigned_of_word ws w)
  | Values.Vint z -> Z.to_string (Conv.z_of_cz z)
  | v -> Format.asprintf "%a" Evaluator.pp_val v

let () =
  if Array.length Sys.argv <> 2 then (
    prerr_endline "usage: jasmin_interp FILE.jazz < queries";
    exit 2);
  let prog = load_file Sys.argv.(1) in
  let funs = Hashtbl.create 17 in
  List.iter (fun f -> Hashtbl.add funs f.Prog.f_name.fn_name f) (snd prog);
  let uprog = Expr.to_uprog Arch.asmOp (Conv.cuprog_of_prog prog) in
  let mem =
    match Evaluator.initial_memory Arch.reg_size (Z.of_int 0x100000) [] with
    | Utils0.Ok m -> m
    | Utils0.Error _ -> failwith "cannot create initial memory"
  in
  try
    while true do
      let line = input_line stdin in
      match String.split_on_char ' ' (String.trim line) |> List.filter (( <> ) "") with
      | [] -> ()
      | fname :: args ->
          let f = Hashtbl.find funs fname in
          let vargs = List.map2 value_of_arg f.Prog.f_tyin args in
          let out =
            match Evaluator.run (module Arch) uprog IInfo.dummy f.Prog.f_name vargs mem with
            | _, res -> String.concat " " (List.map string_of_value res)
            | exception Evaluator.Eval_error (_, err) ->
                Format.asprintf "ERROR %a" Evaluator.pp_error err
          in
          print_endline (fname ^ " " ^ out)
    done
  with End_of_file -> ()
