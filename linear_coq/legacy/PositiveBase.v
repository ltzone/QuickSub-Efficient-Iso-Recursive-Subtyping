Require Import Metalib.Metatheory.
Require Import Program.Equality.
Require Export AmberSoundness.
Require Export DoubleUnfolding.


Lemma subst_tt_wf_v2: forall E1 E2 A B X,
    WF (E1 ++ X ~ bind_sub ++ E2) B ->
    WF (E1 ++ E2) A ->
    WF (E1 ++ E2) (subst_tt X A B).
Proof with auto.
  intros.
  generalize dependent A.
  dependent induction H;intros;simpl...
  -
    destruct (X0==X)...
    constructor...
    analyze_binds H...
  -
    assert (type A0).
    apply wf_type in H3...
    apply WF_rec with (L:=L \u {{X}});intros...
    +
      rewrite subst_tt_open_tt_var...
      rewrite_alist (([(X0, bind_sub)] ++ E1) ++ E2).
      apply H0...
      rewrite_alist (nil ++ [(X0, bind_sub)] ++ (E1 ++ E2)).
      apply wf_weakening...
    +
      rewrite subst_tt_open_tt_var...
      rewrite <- subst_tt_open_tt...
      rewrite_alist (([(X0, bind_sub)] ++ E1) ++ E2).
      apply H2...
      rewrite_alist (nil ++ [(X0, bind_sub)] ++ (E1 ++ E2)).
      apply wf_weakening...
Qed.

Lemma wfa_weakening: forall E1 E2 T E,
    WFA (E1 ++ E2) T ->
    WFA (E1 ++ E ++ E2) T.
Proof with auto.
  intros.
  generalize dependent E.
  dependent induction H;intros...
  -
    apply WFA_rec with (L:=L)...
    intros.
    rewrite_alist (([(X, bind_sub)] ++ E1) ++ E ++ E2).
    apply H0...
Qed.


Lemma sub_amber2_weakening: forall E1 E2 A B E,
    sub_amber2 (E1 ++ E2) A B ->
    wf_env (E1 ++ E ++ E2) ->
    sub_amber2 (E1 ++ E ++ E2) A B.
Proof with auto.
  intros.
  generalize dependent E.
  dependent induction H;intros...
  -
    constructor...
    apply wfa_weakening...
  -
    apply sam2_rec with (L:=L \u dom (E1 ++ E ++ E2)).
    intros.
    rewrite_alist (([(X, bind_sub)] ++ E1) ++ E ++ E2)...
    apply H0...
    rewrite_alist ([(X, bind_sub)] ++ E1 ++ E ++ E2)...
    intros...
Qed.

Lemma subst_tt_wfa: forall A B E X,
    WFA E A ->
    WFA E B ->
    WFA E (subst_tt X A B).
Proof with auto.
  intros.
  generalize dependent A.
  dependent induction H0;intros...
  -
    simpl.
    destruct (X0==X)...
  -
    simpl in *...
  -
    simpl.
    apply WFA_rec with (L:=L \u {{X}} \u fv_tt A0).
    intros.
    rewrite  subst_tt_open_tt_var...
    apply H0...
    rewrite_alist (nil ++ [(X0, bind_sub)] ++ E).
    apply wfa_weakening...
    apply wfs_type with (E:=E)...
    apply soundness_wfa...
Qed.

Lemma sub_amber2_unfolding: forall A B,
    typePairR A B ->
    forall C D X m n E,
    sub_amber2 E A B ->
    posvar m X A B ->
    sub_amber2 E C D ->
    posvar n X C D ->
    sub_amber2 E (chooseS m X C D A) (chooseS m X D C B).
Proof with auto.
  intros A B H.
  dependent induction H;intros...
  -
    destruct m...
  -
    apply suba2_regular in H2.
    destruct H2.
    destruct H4.
    apply suba2_regular in H0.
    destruct H0.
    destruct H6.
    destruct m;simpl;constructor...
    apply subst_tt_wfa...
    apply subst_tt_wfa...
  -
    dependent destruction H0.
    destruct m...
  -
    destruct m;simpl;destruct (X==X0)...
    inversion H0.
    destruct H6...
  -
    dependent destruction H1.
    dependent destruction H2.
    rewrite chooseS_arrow.
    rewrite chooseS_arrow.
    constructor...
    destruct m;simpl in *...
    specialize (IHtypePairR1 C D X _ _ E H1_ H2_ H3 H4).
    simpl...
    specialize (IHtypePairR1 C D X _ _ E H1_ H2_ H3 H4).
    simpl...
    apply IHtypePairR2 with (n:=n)...
  -
  Print sub_amber2.
    dependent destruction H1.
    dependent destruction H3.
    +
      assert (Ht:=H6).
      apply posvar_regular in Ht.
      destruct Ht.
      rewrite chooseS_mu.
      rewrite chooseS_mu.
      apply sam2_rec with (L:=L \u L1 \u L0 \u {{X}} \u fv_tt C \u fv_tt D \u dom E \u fv_tt A \u fv_tt B)...
      *
        intros.
        rewrite <- chooseS_open...
        rewrite <- chooseS_open...
        apply H0 with (n:=n)...
        rewrite_alist (nil ++ [(X0, bind_sub)] ++ E).
        apply sub_amber2_weakening...
        simpl...
        constructor...
        apply suba2_regular in H5.
        apply H5.
      *
        intros.
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}}\u {{X0}} \u fv_tt A \u fv_tt B \u fv_tt C \u fv_tt D ).
        --
          intros.
          rewrite <- chooseS_open...
          rewrite <- chooseS_open...
          destruct m;simpl.
          ++
            apply posvar_calc_sign with (X:=X0) (Y:=X) (C:=D) (D:=C) (m1:=Pos) (m2:=Neg) (m4:=n)...
            apply pos_rename_3 with (X:=X) (m:=Neg)...
            apply notin_union.
            split...
            apply notin_union.
            split;apply notin_fv_tt_open_aux...
            simpl.
            apply pos_rename_3 with (X:=X) (m:=n)...
            apply posvar_comm...
            apply posvar_comm...
          ++
            apply posvar_calc_sign with (X:=X0) (Y:=X) (C:=C) (D:=D) (m1:=Pos) (m2:=Pos) (m4:=n)...
            apply pos_rename_3 with (X:=X) (m:=Pos)...
            apply notin_union.
            split...
            apply notin_union.
            split;apply notin_fv_tt_open_aux...
            simpl.
            apply pos_rename_3 with (X:=X) (m:=n)...
        --
          intros.
          rewrite <- chooseS_open...
          rewrite <- chooseS_open...
          destruct m;simpl.
          ++
            eapply posvar_calc_sign...
            simpl...
            apply pos_rename_3 with (X:=X) (m:=n)...
            apply posvar_comm...
            apply posvar_comm...
            apply H6...
          ++
            eapply posvar_calc_sign...
            simpl...
            apply pos_rename_3 with (X:=X) (m:=n)...
            apply H6...

    +
      destruct m;simpl.
      *
        rewrite <- subst_tt_fresh...
        rewrite <- subst_tt_fresh...
        apply sub_amber2_refl...
        pick fresh Z.
        specialize_x_and_L Z L0.
        apply suba2_regular in H1.
        destruct_hypos.
        dependent destruction H1...
        apply WF_rec with (L:=L0 \u fv_tt B);intros.
        --
          assert (X0 \notin L0) as Q by auto.
          apply H1 in Q.
          apply suba2_regular in Q.
          destruct_hypos...
          apply completeness_wf...
          apply soundness_wfa...
        --
          assert (X0 \notin L0) as Q by auto.
          apply H1 in Q.
          apply suba2_regular in Q.
          destruct_hypos...
          apply soundness_wfa in H9...
          rewrite subst_tt_intro with (X:=X0)...
          apply subst_tt_wf...
          apply completeness_wf...
          apply completeness_wf...
      *
        rewrite <- subst_tt_fresh...
        rewrite <- subst_tt_fresh...
        apply sub_amber2_refl...
        pick fresh Z.
        specialize_x_and_L Z L0.
        apply suba2_regular in H1.
        destruct_hypos.
        dependent destruction H1...
        apply WF_rec with (L:=L0 \u fv_tt B);intros.
        --
          assert (X0 \notin L0) as Q by auto.
          apply H1 in Q.
          apply suba2_regular in Q.
          destruct_hypos...
          apply completeness_wf...
          apply soundness_wfa...
        --
          assert (X0 \notin L0) as Q by auto.
          apply H1 in Q.
          apply suba2_regular in Q.
          destruct_hypos...
          apply soundness_wfa in H9...
          rewrite subst_tt_intro with (X:=X0)...
          apply subst_tt_wf...
          apply completeness_wf...
          apply completeness_wf...
Qed.    
        
Lemma strengthening_wfa: forall E1 E2 T X m,
    WFA (E1 ++ X ~ m ++ E2) T->
    X \notin fv_tt T ->
    WFA (E1 ++ E2) T.
Proof with auto.
  intros.
  dependent induction H...
  -
    analyze_binds H...
    simpl.
    apply D.F.singleton_iff...
  -
    simpl in H1.
    constructor...
    apply IHWFA1 with (X0:=X) (m0:=m)...
    apply IHWFA2 with (X0:=X) (m0:=m)...
  -
    simpl in H1.
    apply WFA_rec with (L:=L \u {{X}}).
    intros.
    rewrite_alist (([(X0, bind_sub)] ++ E1) ++ E2).
    apply H0 with (X1:=X) (m0:=m)...
    apply notin_fv_tt_open_aux...
Qed.   

Lemma sub_amber2_strengthing: forall E1 E2 A B (X : atom),
    sub_amber2 (E1 ++ X ~ bind_sub ++ E2) A B ->
    wf_env (E1 ++ E2) ->
    X \notin fv_tt A \u fv_tt B ->
    sub_amber2 (E1 ++ E2) A B.
Proof with auto.
  intros.
  dependent induction H...
  -
    constructor...
    apply strengthening_wfa in H...
  -
    constructor...
    analyze_binds H.
    apply AtomSetImpl.union_2.
    apply D.F.singleton_iff...
  -
    simpl in H2.
    constructor...
    apply IHsub_amber2_1 with (X0:=X)...
    apply IHsub_amber2_2 with (X0:=X)...
  -
    apply sam2_rec with (L:=L \u {{X}} \u dom (E1++E2)).
    intros.
    rewrite_alist (([(X0, bind_sub)] ++ E1) ++ E2)...
    apply H0 with (X1:=X)...
    rewrite_alist ([(X0, bind_sub)] ++ E1 ++ E2)...
    apply notin_union.
    split.
    apply notin_fv_tt_open_aux...  
    apply notin_fv_tt_open_aux...  
    intros...
Qed.

Lemma sam2_typePairR : forall A B E,
    sub_amber2 E  A B ->
    typePairR A B.
Proof with auto.
  intros.
  induction H...
  -
    constructor...
    apply soundness_wfa in H...
    apply wfs_type in H...
  -
    pick fresh X.
    specialize_x_and_L X L.
    apply posvar_typePairR in H1...
Qed.

Lemma wfa_to_wf: forall E A,
    WFA A E -> WF A E.
Proof with auto.
  intros.
  apply soundness_wfa in H...
  apply completeness_wf...
Qed.

Lemma wfa_type: forall E A,
    WFA E A -> type A .
Proof with auto.
  intros.
  apply wfa_to_wf in H...
  apply wf_type in H...
Qed.

Hint Resolve wfa_to_wf: core.

Lemma unfolding_for_pos: forall E A B,
    sub_amber2 E (typ_mu A) (typ_mu B) ->
    sub_amber2 E (open_tt A (typ_mu A)) (open_tt B (typ_mu B)).
Proof with auto.
  intros.
  assert (Ht:=H).
  dependent destruction H.
  destruct (decide_typ A B).
  -
    subst.
    apply sub_amber2_refl...
    apply suba2_regular in Ht.
    destruct_hypos...
    pick fresh X.
    rewrite subst_tt_intro with (X:=X)...
    rewrite_alist (nil ++ E).
    apply subst_tt_wf_v2...
    specialize_x_and_L X L.
    apply suba2_regular in H.
    destruct_hypos...    
    apply suba2_regular in Ht.
    destruct_hypos...
  -
    pick fresh Y.
    rewrite subst_tt_intro with (X:=Y)...
    remember (subst_tt Y (typ_mu A) (open_tt A Y)).
    rewrite subst_tt_intro with (X:=Y)...
    subst.
    rewrite_alist (nil ++ E).
    specialize_x_and_L Y L.
    apply sub_amber2_unfolding with (C:=typ_mu A) (D:=typ_mu B) (m:=Pos) (X:=Y) (n:=Pos) in H...
    +
      simpl in H...
      rewrite_alist (nil ++ Y ~ bind_sub ++ E) in H.
      apply sub_amber2_strengthing in H...
      apply suba2_regular in Ht.
      apply Ht.
      apply notin_union.
      split.
      rewrite <- subst_tt_intro...
      apply notin_fv_tt_open_aux...
      rewrite <- subst_tt_intro...
      apply notin_fv_tt_open_aux...
    +
      apply sam2_typePairR in H...
    +
      dependent destruction H0.
      pick fresh Y.
      specialize_x_and_L Y (L0 \u {{X}}).
      rewrite subst_tt_intro with (X:=Y)...
      remember (subst_tt Y X (open_tt A Y)) .
      rewrite subst_tt_intro with (X:=Y)...
      subst.
      apply pos_rename_1...
      apply notin_union.
      split...
      apply notin_union.
      split;apply notin_fv_tt_open_aux...
      destruct n...
    +
      rewrite_alist (nil ++ Y ~ bind_sub ++ E).
      apply sub_amber2_weakening...
      apply suba2_regular in Ht.
      destruct_hypos.
      constructor...
Qed.

Lemma sub_amber2_trans_aux: forall E B,
    WFA E B ->
    forall A C m X,
      sub_amber2 E A B ->
      sub_amber2 E B C ->
      posvar m X A B ->
      posvar m X B C ->
      sub_amber2 E A C /\ posvar m X A C.
Proof with auto.
  intros E B Hb.
  induction Hb;intros...
  -
    dependent destruction H...
    dependent destruction H1...
  -
    dependent destruction H...
  -
    dependent destruction H0...
  -
    dependent destruction H...
    dependent destruction H1...
    +
      apply suba2_regular in H.
      apply suba2_regular in H0.
      destruct H.
      destruct H5.
      destruct H0.
      destruct H7.
      split;constructor...
      apply wfa_type in H6.
      apply wfa_type in H7...
    +
      dependent destruction H2...
      dependent destruction H3...
      split...
      constructor...
      apply IHHb1 with (m:=flip m) (X:=X)...
      apply IHHb2 with (m:= m) (X:=X)...
      constructor...
      apply IHHb1 with (m:=flip m) (X:=X)...
      apply IHHb2 with (m:= m) (X:=X)...      
  -
    dependent destruction H1...
    dependent destruction H3...
    +
      split;constructor...
      apply WFA_rec with (L:=L0)...
      intros...
      specialize (H1 _ H7).
      apply suba2_regular in H1.
      apply H1.
      apply posvar_regular in H5.
      apply H5.
    +
      destruct (decide_typ A0 A).
      *
        subst.
        split...
        apply sam2_rec with (L:=L \u L0 \u L1 \u fv_tt A \u fv_tt B \u {{X}}).
        intros.
        apply H3...
        intros.
        apply pos_rename_3 with (X:=X) (m:=m)...
      *
        destruct (decide_typ A B).
        --
          subst.
          split...
          apply sam2_rec with (L:=L \u L0 \u L1 \u fv_tt A0 \u fv_tt B \u {{X}}).
          intros.
          apply H1...
          intros.
          apply pos_rename_3 with (X:=X) (m:=m)...
        --
          dependent destruction H5.
          dependent destruction H7.
          split...
          ++
            apply sam2_rec with (L:=L \u L0 \u L1 \u L2 \u {{X}} \u L3  \u fv_tt A0
                              \u fv_tt B \u fv_tt A).
            intros.
            apply H0 with (X0:=X) (m:=m)...
            intros.
            apply pos_rec with (L:=L \u L0 \u L1 \u L2 \u {{X}} \u L3).
            intros.
            eapply H0...
            apply pos_rename_3 with (X:=X) (m:=m)...
            apply notin_union.
            split...
            apply notin_union.
            split;apply notin_fv_tt_open_aux...
            apply pos_rename_3 with (X:=X) (m:=m)...
            apply notin_union.
            split...
            apply notin_union.
            split;apply notin_fv_tt_open_aux...
            intros.
            eapply H0...
          ++
            apply pos_rec with (L:=L \u L0 \u L1 \u L2 \u {{X}} \u L3).
            intros.
            eapply H0...
            intros.
            eapply H0...
          ++
            destruct n0...
          ++
            destruct n...            
Qed.

Lemma sub_amber2_trans: forall E B,
    WFA E B ->
    forall A C ,
      sub_amber2 E A B ->
      sub_amber2 E B C ->
      sub_amber2 E A C.
Proof with auto.
  intros E B Hb.
  induction Hb;intros...
  -
    dependent destruction H...
    dependent destruction H1...
  -
    dependent destruction H...
  -
    dependent destruction H0...
  -
    dependent destruction H...
    dependent destruction H1...
    constructor...
    apply suba2_regular in H.
    apply suba2_regular in H0.
    constructor...
    apply H.
    apply H0.
  -
    dependent destruction H1...
    dependent destruction H3...
    +
      constructor...
      apply WFA_rec with (L:=L0).
      intros...
      specialize (H1 _ H5).
      apply suba2_regular in H1.
      apply H1.
    +
      apply sam2_rec with (L:=L \u L0 \u L1).
      intros...
      intros.
      eapply sub_amber2_trans_aux with (B:=typ_mu A) (E:=E)...
      apply WFA_rec with (L:=L)...
      apply sam2_rec with (L:=L0)...
      apply sam2_rec with (L:=L1)...
Qed.

Inductive wk_sub: env -> typ -> typ -> Prop :=
| W_nat: forall E,
    wf_env E ->
    wk_sub E typ_nat typ_nat
| W_top: forall E A,
    WFA E A ->
    wf_env E ->
    wk_sub E A typ_top
| W_fvar: forall E X ,
    binds X bind_sub E ->
    wf_env E ->
    wk_sub E (typ_fvar X) (typ_fvar X)
| W_arrow: forall E A1 A2 B1 B2,
    wk_sub E B1 A1 ->
    wk_sub E A2 B2 ->
    wk_sub E (typ_arrow A1 A2) (typ_arrow B1 B2)
| W_rec: forall E A B L,
    (forall X , X \notin L -> 
                wk_sub (X ~ bind_sub ++ E) (open_tt A X) (open_tt B X)) ->
    (forall X , X \notin L ->
                posvar Pos X (open_tt A X) (open_tt B X)) ->
    wk_sub E (typ_mu A) (typ_mu B)
| W_refl: forall E A,
    wf_env E ->
    WF E (typ_mu A) ->
    wk_sub E (typ_mu A) (typ_mu A).

Hint Constructors wk_sub : core.

Locate sub_amber2.

Lemma wk_sub_to_sam2: forall E A B,
    wk_sub E A B -> sub_amber2 E A B.
Proof with auto.
  intros.
  induction H...
  -
    apply sam2_rec with (L:=L \u fv_tt A \u fv_tt B)...
    intros.
    apply pos_rec with (L:=L \u fv_tt A \u fv_tt B)...
    intros.
    rewrite subst_tt_intro with (X:=X)...
    remember (subst_tt X Y (open_tt A X)).
    rewrite subst_tt_intro with (X:=X)...
    subst.
    apply pos_rename_2...
    solve_notin.
    apply notin_fv_tt_open_aux...
    apply notin_fv_tt_open_aux...
  -
    apply sub_amber2_refl...
Qed.

Lemma sam2_to_wk_sub: forall E A B,
    sub_amber2 E A B -> wk_sub E A B.
Proof with auto.
  intros.
  assert (Ht:=H).
  apply suba2_regular in Ht.
  induction H...
  -
    destruct_hypos.
    dependent destruction H2.
    dependent destruction H3...
  -
    pick fresh X.
    assert (X\notin L) by auto.
    apply H1 in H2.
    dependent destruction H2.
    +
      destruct_hypos.
      dependent destruction H5.
      dependent destruction H6.
      apply W_rec with (L:=L \u L0 \u {{X}} \u L1 \u L2 \u dom E);intros...      
    +
      destruct_hypos.
      apply W_refl...
Qed.

      
