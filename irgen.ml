(* IR generation: translate takes a semantically checked AST and
   produces LLVM IR

   LLVM tutorial: Make sure to read the OCaml version of the tutorial

   http://llvm.org/docs/tutorial/index.html

   Detailed documentation on the OCaml LLVM library:

   http://llvm.moe/
   http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Sast

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module *)
let translate (globals, functions) =
  let context    = L.global_context () in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "tabLe" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and str_t      = L.pointer_type (L.i8_type context)
  and none_t     = L.void_type   context
  and list_t     = L.pointer_type (L.i8_type context) in

  (* Return the LLVM type for a tabLe type *)
  let ltype_of_typ = function
      A.Int    -> i32_t
    | A.Bool   -> i1_t
    | A.Float  -> float_t
    | A.String ->  str_t
    | A.Null  -> none_t
    | A.List li -> ignore(li);(list_t)
  in

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n) =
      let init = L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype =
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue =
    L.declare_function "printf" printf_t the_module in

  let string_concat_t = L.function_type str_t [| str_t; str_t |] in
  let string_concat_f = L.declare_function "string_concat" string_concat_t the_module in

  let append_double_t : L.lltype =
        L.var_arg_function_type list_t [| list_t; i32_t |]
    in
    let append_double_func : L.llvalue =
        L.declare_function "append_double" append_double_t the_module
    in
    let append_int_t : L.lltype =
        L.var_arg_function_type list_t [| list_t; i32_t |]
    in
    let append_int_func : L.llvalue =
        L.declare_function "append_int" append_int_t the_module in

  let mean_t = L.function_type float_t [| list_t  |] in
  let mean_func = L.declare_function "mean" mean_t the_module in

  let stdev_t : L.lltype =
    L.function_type float_t [| list_t |] in
  let stdev_func : L.llvalue =
    L.declare_function "stdev" stdev_t the_module in

      let variance_t : L.lltype =
    L.function_type float_t [| list_t |] in
  let variance_func : L.llvalue =
    L.declare_function "variance" variance_t the_module in

      let max_t : L.lltype =
    L.function_type float_t [| list_t |] in
  let max_func : L.llvalue =
    L.declare_function "max" max_t the_module in

          let min_t : L.lltype =
    L.function_type float_t [| list_t |] in
  let min_func : L.llvalue =
    L.declare_function "min" min_t the_module in


  (* Define each function (arguments and return type) so we can
     call it even before we've created its body *)


  let function_decls : (L.llvalue * sfunc_def) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types =
        Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.srtyp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder in

    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p =
        L.set_value_name n p;
        let local = L.build_alloca (ltype_of_typ t) n builder in

        ignore (L.build_store p local builder);
        StringMap.add n local m

      (* Allocate space for any locally declared variables and add the
       * resulting registers to our map *)
      and add_local m (t, n) =
        let local_var = L.build_alloca (ltype_of_typ t) n builder in
        (*let _ = (match t with
        | A.Mean -> L.build_call mean_func [| |] "" builder
        | _ -> local_var) in*)
        StringMap.add n local_var m
      in

      let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.slocals
    in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
      with Not_found -> StringMap.find n global_vars
    in

    (* Construct code for an expression; return its value *)
    let rec build_expr builder ((s, e) : sexpr) = match e with
        SLiteral i  -> L.const_int i32_t i
      | SFliteral l -> L.const_float_of_string float_t l
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SStringLit s -> L.build_global_stringptr s "str" builder
      | SListLit l -> let list_builder l = Array.of_list (List.map (build_expr builder) l)
                    in
                    (match s with
                    | A.List (A.Int) -> L.build_call append_int_func (Array.append [|L.const_pointer_null list_t; L.const_int i32_t (List.length l);|] (list_builder l)) "append_int" builder
                    | A.List (A.Float) -> L.build_call append_double_func (Array.append [|L.const_pointer_null list_t; L.const_int i32_t (List.length l);|] (list_builder l)) "append_double" builder
                    | _ -> raise (Failure "List type error"))
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup s) s builder
      | SAssign (s, e) -> let e' = build_expr builder e in
        ignore(L.build_store e' (lookup s) builder); e'
      | SBinop ((A.Float,_ ) as e1, op, e2) ->
        let e1' = build_expr builder e1
        and e2' = build_expr builder e2 in
        (match op with
           A.Add     -> L.build_fadd
         | A.Sub     -> L.build_fsub
         | A.Mult    -> L.build_fmul
         | A.Div     -> L.build_fdiv
         | A.Mod     -> L.build_frem
         | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
         | A.Neq     -> L.build_fcmp L.Fcmp.One
         | A.Less    -> L.build_fcmp L.Fcmp.Olt
         | A.Leq     -> L.build_fcmp L.Fcmp.Ole
         | A.Greater -> L.build_fcmp L.Fcmp.Ogt
         | A.Geq     -> L.build_fcmp L.Fcmp.Oge
         | A.And | A.Or ->
           raise (Failure "internal error: semant should have rejected and/or on float")
        ) e1' e2' "tmp" builder
      | SBinop ((A.String,_ ) as e1, op, e2) ->
        let e1' = build_expr builder e1
        and e2' = build_expr builder e2 in
        (match op with
           A.Add     -> L.build_call string_concat_f [| e1'; e2' |] "string_concat" builder
         | _ -> raise (Failure ("operation " ^ (A.string_of_op op) ^ " not implemented")))
      | SBinop (e1, op, e2) ->
        let e1' = build_expr builder e1
        and e2' = build_expr builder e2 in
        (match op with
           A.Add     -> L.build_add
         | A.Sub     -> L.build_sub
         | A.Mult    -> L.build_mul
         | A.Div     -> L.build_sdiv
         | A.Mod     -> L.build_srem
         | A.And     -> L.build_and
         | A.Or      -> L.build_or
         | A.Equal   -> L.build_icmp L.Icmp.Eq
         | A.Neq     -> L.build_icmp L.Icmp.Ne
         | A.Less    -> L.build_icmp L.Icmp.Slt
         | A.Leq     -> L.build_icmp L.Icmp.Sle
         | A.Greater -> L.build_icmp L.Icmp.Sgt
         | A.Geq     -> L.build_icmp L.Icmp.Sge
        ) e1' e2' "tmp" builder
      | SCall ("print", [e]) ->
        L.build_call printf_func [| int_format_str ; (build_expr builder e) |] "printf" builder
      | SCall ("prints", [e]) ->
        L.build_call printf_func [| string_format_str ; (build_expr builder e) |] "printf" builder
      | SCall ("printf", [e]) ->
          L.build_call printf_func [| float_format_str ; (build_expr builder e) |] "printf" builder
      | SCall ("mean", [e]) ->
          L.build_call mean_func [| (build_expr builder e) |] "mean" builder
      | SCall ("stdev", [e]) ->
         L.build_call stdev_func [| (build_expr builder e) |] "stdev" builder
      | SCall ("variance", [e]) ->
        L.build_call variance_func [| (build_expr builder e) |] "variance" builder
      | SCall ("min", [e]) ->
         L.build_call min_func [| (build_expr builder e) |] "min" builder
      | SCall ("max", [e]) ->
        L.build_call max_func [| (build_expr builder e) |] "max" builder
      | SCall (f, args) ->
        let (fdef, fdecl) = StringMap.find f function_decls in
        let llargs = List.rev (List.map (build_expr builder) (List.rev args)) in
        let result = (match fdecl.srtyp with
              A.Null -> ""
            | _ -> f ^ "_result") in
        L.build_call fdef (Array.of_list llargs) result builder
    in

    (* LLVM insists each basic block end with exactly one "terminator"
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)
    let rec build_stmt builder = function
        SBlock sl -> List.fold_left build_stmt builder sl
      | SExpr e -> ignore(build_expr builder e); builder
      | SReturn e -> ignore(match fdecl.srtyp with
            A.Null -> L.build_ret_void builder
          | _ -> L.build_ret (build_expr builder e) builder );
        builder
      | SIf (predicate, then_stmt, else_stmt) ->
        let bool_val = build_expr builder predicate in

        let then_bb = L.append_block context "then" the_function in
        ignore (build_stmt (L.builder_at_end context then_bb) then_stmt);
        let else_bb = L.append_block context "else" the_function in
        ignore (build_stmt (L.builder_at_end context else_bb) else_stmt);

        let end_bb = L.append_block context "if_end" the_function in
        let build_br_end = L.build_br end_bb in (* partial function *)
        add_terminal (L.builder_at_end context then_bb) build_br_end;
        add_terminal (L.builder_at_end context else_bb) build_br_end;

        ignore(L.build_cond_br bool_val then_bb else_bb builder);
        L.builder_at_end context end_bb

      | SWhile (predicate, body) ->
        let while_bb = L.append_block context "while" the_function in
        let build_br_while = L.build_br while_bb in (* partial function *)
        ignore (build_br_while builder);
        let while_builder = L.builder_at_end context while_bb in
        let bool_val = build_expr while_builder predicate in

        let body_bb = L.append_block context "while_body" the_function in
        add_terminal (build_stmt (L.builder_at_end context body_bb) body) build_br_while;

        let end_bb = L.append_block context "while_end" the_function in

        ignore(L.build_cond_br bool_val body_bb end_bb while_builder);
        L.builder_at_end context end_bb

    in
    (* Build the code for each statement in the function *)
    let func_builder = build_stmt builder (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal func_builder (match fdecl.srtyp with
      | A.Null -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))

  in

  List.iter build_function_body functions;
  the_module
