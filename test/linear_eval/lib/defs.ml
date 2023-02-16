(** Constructors for types
  
  Type variables are represented as integers, which are assumed to be named 0, 1, etc, ...
  so for all types T passed as arguments to the subtype-testing function [sub],
  the set of type variables in T is {0 .. n} for some n, we also assume that T never 
  uses undeclared type variables, and has been alpha-converted to ensure the uniqueness
  of every declared variable

*)

type typ = Nat | Real | Prod of typ * typ | Sum of typ * typ 
         | Fun of typ * typ | Rec of int * typ | Var of int


let rec numVars (t: typ) = match t with 
  | Prod (t1, t2) | Sum (t1, t2) | Fun (t1, t2) -> numVars t1 + numVars t2 
  | Rec (_, t) -> numVars t + 1
  | _ -> 0


let range a b =
    List.init (b - a) ((+) a)


let rev_concat_map f xs = List.fold_right List.rev_append (List.rev_map f xs) []
(* The tail-recursive version of concat map *)

let rec typgenh (depth: int) (max_var: int) : typ list =
  if depth = 0 then 
      ([Nat; Real] @ (List.map (fun i -> Var i) (range 0 max_var)))
  else
    (let st1 = typgenh (depth - 1) max_var in
      let st2 = typgenh (depth - 1) (max_var + 1) in
        let st1_comb = rev_concat_map 
            (fun t1 -> rev_concat_map (fun t2 -> [
              (* Prod (t1, t2); Sum (t1, t2);  *)
            Fun (t1, t2)]) st1) st1 in
        let st2_comb = rev_concat_map (fun t -> [Rec (max_var, t)]) st2 in
        List.rev_append st1_comb st2_comb
    )
    
let typgen (depth: int) = 
    typgenh depth 0

let ascii n = String.make 1 (Char.chr (Char.code 'a' + n))

let rec string_of_typ t = match t with
  | Nat -> "nat"
  | Real -> "real"
  | Prod (t1, t2) -> "(" ^ string_of_typ t1 ^ " * " ^ string_of_typ t2 ^ ")"
  | Sum (t1, t2) -> "(" ^ string_of_typ t1 ^ " + " ^ string_of_typ t2 ^ ")"
  | Fun (t1, t2) -> "(" ^ string_of_typ t1 ^ " -> " ^ string_of_typ t2 ^ ")"
  | Rec (i, t) -> "(μ " ^ ascii i ^ ". " ^ string_of_typ t ^ ")"
  | Var i -> ascii i

let print_typ t = print_string (string_of_typ t)



let t1 = Rec (0, (Fun (Var 0, Nat))) (* μ a. a -> nat *)
let t2 = Rec (0, (Fun (Var 0, Real))) (* μ a. a -> real *)

let t3 = Rec (0, (Fun (Real, Var 0))) (* μ a. real -> a *)
let t4 = Rec (0, (Fun (Nat, Var 0))) (* μ a. nat -> a *)

let t1_unfold = Rec (0, (Fun (Rec (1, (Fun (Var 1, Nat))), Nat))) (* μ a. (μ b. b -> nat) -> nat *)

let t3_unfold = Rec (0, (Fun (Real, Rec (1, (Fun (Real, Var 1)))))) (* μ a. real -> (μ b. real -> b) *)

let t4_unfold = Rec (0, (Fun (Nat, Rec (1, (Fun (Nat, Var 1)))))) (* μ a. nat -> (μ b. nat -> b) *)

let typ_pair_gen (depth: int) = 
    let ts = typgen depth in
    let ts' = typgen depth in
    rev_concat_map (fun t -> List.rev_map (fun t' -> (t, t')) ts') ts

(* generate [mu a. a -> mu b. b -> ... b1 <: mu a. a -> mu b. b -> ... b2]  *)
let deep_subtyp_gen (depth: int) b1 b2 = 
  let rec typ_genh max_var dep base = 
    if dep = 0 then base else
      Rec (max_var, Fun (Var max_var, typ_genh (max_var + 1) (dep - 1) base)) in
  let t1 = typ_genh 0 depth b1 in
  let t2 = typ_genh 0 depth b2 in
  (t1, t2)

(* generate b1 -> mu a. b1 -> mu b. b1 -> ... -> a <: b2 -> mu a. b2 -> mu b. b2 -> ... -> a *)
let deep_subtyp_pos_gen (depth: int) b1 b2 =
  let rec typ_genh max_var dep base = 
    if dep = 0 then Fun (base, Var 0) else
      Fun (base, Rec (max_var, Fun (base, typ_genh (max_var + 1) (dep - 1) base))) in
  let t1 = typ_genh 0 depth b1 in
  let t2 = typ_genh 0 depth b2 in
  (t1, t2)