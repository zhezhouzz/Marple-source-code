module T = Nt
open Ocaml5_parser
open Parsetree
open Sugar

let layout_ t =
  let _ = Format.flush_str_formatter () in
  Pprintast.core_type Format.str_formatter t;
  Format.flush_str_formatter ()

let desc_to_ct t =
  {
    ptyp_desc = t;
    ptyp_loc = Location.none;
    ptyp_loc_stack = [];
    ptyp_attributes = [];
  }

let rec core_type_to_t ct = core_type_desc_to_t ct.ptyp_desc
(* let t = core_type_desc_to_t ct.ptyp_desc in *)
(* match t with *)
(* | T.Ty_arrow (_, t1, t2) -> *)
(*     let label = attributes_to_label ct.ptyp_attributes in *)
(*     T.Ty_arrow (label, t1, t2) *)
(* | _ -> _failatwith __FILE__ __LINE__ "?" *)

and core_type_desc_to_t t =
  match t with
  | Ptyp_any -> T.Ty_any
  | Ptyp_object (_, _) -> failwith "type object"
  | Ptyp_class (_, _)
  | Ptyp_alias (_, _)
  | Ptyp_variant (_, _, _)
  | Ptyp_package _ | Ptyp_extension _ ->
      _failatwith __FILE__ __LINE__ "die"
  | Ptyp_poly ([ lc ], ct) ->
      _failatwith __FILE__ __LINE__
        (spf "unimp: poly: lc: %s; ct: %s" lc.txt (layout_ ct))
  | Ptyp_poly (_, _) ->
      _failatwith __FILE__ __LINE__
        (spf "unimp: poly: %s" @@ layout_ @@ desc_to_ct t)
  | Ptyp_var name -> T.Ty_var name
  | Ptyp_arrow (_, t1, t2) -> T.Ty_arrow (core_type_to_t t1, core_type_to_t t2)
  | Ptyp_tuple ts -> T.Ty_tuple (List.map core_type_to_t ts)
  | Ptyp_constr (lc, ts) -> (
      match (Longident.flatten lc.txt, ts) with
      | [ "unit" ], [] -> T.Ty_unit
      | [ "bool" ], [] -> T.Ty_bool
      | [ "int" ], [] -> T.Ty_int
      | [ "nat" ], [] -> T.Ty_nat
      (* | [ "list" ], [ t ] -> T.Ty_constructor ("list", [ core_type_to_t t ]) *)
      | [ c ], args -> T.Ty_constructor (c, List.map core_type_to_t args)
      | _, _ -> failwith @@ Printf.sprintf "un-imp: %s" (layout_ @@ desc_to_ct t)
      )

let rec t_to_core_type t = desc_to_ct (t_to_core_type_desc t)

and t_to_core_type_desc t =
  let open Longident in
  let open Location in
  let mk0 name = Ptyp_constr (mknoloc @@ Lident name, []) in
  (* let mk1 name t = Ptyp_constr (mknoloc @@ Lident name, [ t ]) in *)
  let aux = function
    | T.Ty_any -> Ptyp_any
    | T.Ty_unknown -> mk0 "unknown"
    | T.Ty_var name ->
        let res = Ptyp_var name in
        (* let () = *)
        (*   Printf.printf "output res: %s\n" @@ layout_ @@ desc_to_ct res *)
        (* in *)
        res
    | T.Ty_unit -> mk0 "unit"
    | T.Ty_bool -> mk0 "bool"
    | T.Ty_int -> mk0 "int"
    | T.Ty_nat -> mk0 "nat"
    (* | T.Ty_list t -> mk1 "list" (t_to_core_type t) *)
    | T.Ty_tuple t -> Ptyp_tuple (List.map t_to_core_type t)
    | T.Ty_arrow (t1, t2) ->
        Ptyp_arrow (Asttypes.Nolabel, t_to_core_type t1, t_to_core_type t2)
    | Ty_constructor (id, args) ->
        Ptyp_constr
          ( (Location.mknoloc
            @@
            match Longident.unflatten [ id ] with
            | None -> _failatwith __FILE__ __LINE__ "die"
            | Some x -> x),
            List.map t_to_core_type args )
  in
  aux t

let layout t = layout_ (t_to_core_type t)
let of_string str = core_type_to_t @@ Parse.core_type @@ Lexing.from_string str
let layout_l ts = Zzdatatype.Datatype.List.split_by_comma layout ts

(* let%test "rev" = List.equal Int.equal (List.rev [ 3; 2; 1 ]) [ 1; 2 ] *)
let%test "parse1" = T.eq T.int_ty (of_string "int")
let%test "parse2" = T.eq T.bool_ty (of_string "bool")
let%test "parse3" = T.eq T.(mk_arr bool_ty int_ty) (of_string "bool -> int")
let%test "parse4" = T.eq T.(mk_arr bool_ty int_ty) (of_string "bool -> int")
