
let test_group fnames (fs:(Defs.typ -> Defs.typ -> bool) list) n =
  List.iter (fun (fname, testfun) ->
    print_string "-------------------------- ";
    print_string fname;
    print_endline " ------------------------";
    print_endline fnames;
    List.iter (testfun fs) n
  )


let fnames_wo_nominal = 
  ("No.\tLinOpt\tLinOptTime\tEqui\tEquiTime\tAmber\tAmberTime\tComplete\tCompleteTime",
    [ LinearSubOpt.sub; EquiSub.sub; AmberSub.sub; CompleteSub.sub] ) 
    
let fnames_wo_equi = 
  ("No.\tLinOpt\tLinOptTime\tNominal\tNominalTime\tAmber\tAmberTime\tComplete\tCompleteTime",
    [ LinearSubOpt.sub; NominalSub2.sub; AmberSub.sub; CompleteSub.sub])
let fnames_wo_nominal_equi = 
  ("No.\tLinOpt\tLinOptTime\tAmber\tAmberTime\tComplete\tCompleteTime",
    [ LinearSubOpt.sub; AmberSub.sub; CompleteSub.sub])

let fnames_all = 
  ("No.\tLinOpt\tLinOptTime\tNominal\tNominalTime\tEqui\tEquiTime\tAmber\tAmberTime\tComplete\tCompleteTime",
    [ LinearSubOpt.sub; NominalSub2.sub; EquiSub.sub; AmberSub.sub; CompleteSub.sub] )

let fname_only_equi = 
  ("No.\tEqui\tEquiTime",
    [ EquiSub.sub] )


let test_table1 () =
  let fnames = "No.\tLinOpt\tLinOptTime\tNominal\tNominalTime\tEqui\tEquiTime\tAmber\tAmberTime\tComplete\tCompleteTime" in
  let fs = [
    LinearSubExt.sub; 
    NominalSub2.sub; 
    EquiSub.sub; 
    AmberSub.sub; 
    CompleteSub.sub
  ] in 
  let depth = 5000 in
  let tests = [
    ("1", Tests.test1_gen, depth);
    ("2", Tests.test2_gen, depth);
    ("3", Tests.test3_gen, depth);
    ("4", Tests.test4_gen, depth);
    ("5", Tests.test5_gen, depth);
    ("6", Tests.test6_gen, depth);
    ("7", Tests.test7_gen, depth); 
    ("8", Tests.test8_gen, 500);
  ] in
  Printf.printf "depth = %d\n" depth;
  print_endline fnames;
  List.iter (fun (n, testcase, test_depth) ->
    let t1, t2 = (testcase test_depth) in
    Tests.test_wrap ~print:false fs n t1 t2)
    tests


let collect_smax () =
  let f = LinearSubExt.sub0 ~profile:true in
  let depth = 100 in
  let tests = [
    ("1", Tests.test1_gen);
    ("2", Tests.test2_gen);
    ("3", Tests.test3_gen);
    ("4", Tests.test4_gen);
    ("5", Tests.test5_gen);
    ("6", Tests.test6_gen);
    ("7", Tests.test7_gen);
    ("8", Tests.test8_gen);
  ] in
  Printf.printf "depth = %d\n" depth;
  List.iter (fun (n, testcase) ->
    Printf.printf "Test %s\n" n;
    let t1, t2 = (testcase depth) in
    let _ = f t1 t2 in
    () ) tests




let test_plot1 () = 
  (* let depths_1 = [200; 400; 600; 800; 1000] in
  let depths_2 = [500; 1000; 1500; 2000; 2500] in
  let depths_3 = [400; 800; 1200; 1600; 2000] in *)
  (* let depths_4 = [100; 200; 300; 400; 500] in *)
  let depths = [1000; 2000; 3000; 4000; 5000] in
  let tests = [
    ("1", Tests.test1_gen, depths, fnames_all);
    ("3", Tests.test3_gen, depths, fnames_all);
    ("4", Tests.test4_gen, depths, fnames_all);
    ("7", Tests.test7_gen, depths, fnames_all);
  ] in
  List.iter (fun (testname, testcase, depths, (fnames, fs)) ->
    Printf.printf "------- Test %s ------\n" testname;
    print_endline fnames;
    List.iter ( fun depth ->
      let t1, t2 = (testcase depth) in
      Tests.test_wrap ~print:false fs (string_of_int depth) t1 t2
    ) depths) tests

let test_table2 () =  
  let fnames = " Depth\tWidth\tLinear\tLinearTime\tEqui\tEquiTime\tAmber\tAmberTime\tComplete\tCompleteTime" in
  let fs = [
    LinearSubOpt.sub; 
    EquiSub.sub; 
    AmberSub.sub; 
    CompleteSub.sub
    ] in
  let configs = [
  (100, 1000);
  ]
  in
  test_group fnames fs configs
  [
    ("rcd test2', disprove positive subtyping with a slight modification", RcdTest.paper_test1);
    ("rcd test3, disprove negative subtyping", RcdTest.paper_test2); 
    ("rcd test2, prove positive subtyping", RcdTest.paper_test3); 
    ("rcd test1, prove negative + top", RcdTest.paper_test4)
  ]



let test_plot2 () =  
  let fnames = " Depth\tWidth\tLinear\tLinearTime\tEqui\tEquiTime\tAmber\tAmberTime\tComplete\tCompleteTime" in
  let fs = [
    LinearSubOpt.sub; 
    EquiSub.sub; 
    AmberSub.sub; 
    CompleteSub.sub
    ] in
  let configs = [
  (* depth * width *)
    (1, 100);
    (1, 1000);
    (1, 2000);
    (10, 100);
    (10, 1000);
    (10, 2000);
    (100, 100);
    (100, 1000); 
    (100, 2000);
    (200, 100);
    (200, 1000);
    (200, 2000);
  ]
  in
  test_group fnames fs configs
  [
    ("rcd test2, prove positive subtyping", RcdTest.paper_test3);
  ]




let main = 
    (* test_table1 () *)
    (* collect_smax () *)
    (* test_plot1 () *)
    (* test_table2 (); *)
    (* test_plot2 () *)