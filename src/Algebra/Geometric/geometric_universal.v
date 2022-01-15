Require Import init.

Require Import set.
Require Import card.
Require Import ring_ideal.
Require Import unordered_list.

Require Import linear_quadratic.
Require Import module_category.
Require Import algebra_category.
Require Import category_initterm.
Require Import tensor_algebra.

Require Export geometric_construct.

Section GeometricCategory.

Context {F : CRing} {V : Module F}.

Let UP := cring_plus F.
Let UN := cring_neg F.
Let UM := cring_mult F.
Let VP := module_plus V.
Let VS := module_scalar V.

Existing Instances UP UN UM VP VS.

Context (Q : set_type (quadratic_form (cring_U F) (module_V V))).

Record to_ga := make_to_ga {
    to_ga_algebra : Algebra F;
    to_ga_homo : ModuleHomomorphism V (algebra_module to_ga_algebra);
    to_ga_contract : ∀ v,
        @mult _ (algebra_mult to_ga_algebra)
        (module_homo_f to_ga_homo v)
        (module_homo_f to_ga_homo v) =
        @scalar_mult _ _ (algebra_scalar to_ga_algebra)
            ([Q|] v) (@one _ (algebra_one to_ga_algebra))
}.

Definition to_ga_set (f g : to_ga)
    (h : cat_morphism (ALGEBRA F)
                      (to_ga_algebra f)
                      (to_ga_algebra g))
    := ∀ x, algebra_homo_f h (module_homo_f (to_ga_homo f) x) =
            module_homo_f (to_ga_homo g) x.

Definition to_ga_compose {F G H : to_ga}
    (f : set_type (to_ga_set G H)) (g : set_type (to_ga_set F G))
    := [f|] ∘ [g|].

Lemma to_ga_set_compose_in {F' G H : to_ga} :
        ∀ (f : set_type (to_ga_set G H)) g,
        to_ga_set F' H (to_ga_compose f g).
    intros [f f_eq] [g g_eq].
    unfold to_ga_set in *.
    unfold to_ga_compose; cbn.
    intros x.
    rewrite g_eq.
    apply f_eq.
Qed.

Lemma to_ga_set_id_in : ∀ f : to_ga, to_ga_set f f 𝟙.
    intros f.
    unfold to_ga_set.
    intros x.
    cbn.
    reflexivity.
Qed.

Program Instance TO_GA : Category := {
    cat_U := to_ga;
    cat_morphism f g := set_type (to_ga_set f g);
    cat_compose {F G H} f g := [_|to_ga_set_compose_in f g];
    cat_id f := [_|to_ga_set_id_in f];
}.
Next Obligation.
    apply set_type_eq; cbn.
    apply (@cat_assoc (ALGEBRA F)).
Qed.
Next Obligation.
    apply set_type_eq; cbn.
    apply (@cat_lid (ALGEBRA F)).
Qed.
Next Obligation.
    apply set_type_eq; cbn.
    apply (@cat_rid (ALGEBRA F)).
Qed.

Definition vector_to_ga_homo := make_module_homomorphism
    F
    V
    (algebra_module (geometric_algebra Q))
    (vector_to_ga Q)
    (vector_to_ga_plus Q)
    (vector_to_ga_scalar Q).

Let GM := ga_mult Q.
Let GO := ga_one Q.
Let GS := ga_scalar Q.

Existing Instances GM GO GS.

Lemma ga_contract2 : ∀ v, vector_to_ga Q v * vector_to_ga Q v = [Q|] v · 1.
    intros v.
    rewrite (ga_contract Q).
    apply scalar_to_ga_one_scalar.
Qed.

Definition ga_to_ga := make_to_ga
    (geometric_algebra Q)
    vector_to_ga_homo
    ga_contract2.

Theorem gaerior_universal : @initial TO_GA ga_to_ga.
    pose (UZ := cring_zero F).
    pose (UPC := cring_plus_comm F).
    pose (UPZ := cring_plus_lid F).
    pose (UPN := cring_plus_linv F).
    pose (UO := cring_one F).
    pose (TP := algebra_plus (tensor_algebra V)).
    pose (TZ := algebra_zero (tensor_algebra V)).
    pose (TN := algebra_neg (tensor_algebra V)).
    pose (TO := algebra_one (tensor_algebra V)).
    pose (TPA := algebra_plus_assoc (tensor_algebra V)).
    pose (TPC := algebra_plus_comm (tensor_algebra V)).
    pose (TPZ := algebra_plus_lid (tensor_algebra V)).
    pose (TPN := algebra_plus_linv (tensor_algebra V)).
    pose (TL := algebra_ldist (tensor_algebra V)).
    pose (TR := algebra_rdist (tensor_algebra V)).
    pose (TMA := algebra_mult_assoc (tensor_algebra V)).
    pose (TML := algebra_mult_lid (tensor_algebra V)).
    pose (TMR := algebra_mult_rid (tensor_algebra V)).
    pose (TSMO := algebra_scalar_id (tensor_algebra V)).
    pose (TSMR := algebra_scalar_rdist (tensor_algebra V)).
    pose (GP := ga_plus Q).
    unfold ga_to_ga, initial; cbn.
    intros [A f f_contr].
    unfold to_ga_set; cbn.
    pose (AP := algebra_plus A).
    pose (AZ := algebra_zero A).
    pose (AN := algebra_neg A).
    pose (APA := algebra_plus_assoc A).
    pose (APC := algebra_plus_comm A).
    pose (APZ := algebra_plus_lid A).
    pose (APN := algebra_plus_linv A).
    pose (ASM := algebra_scalar A).
    pose (ASMO := algebra_scalar_id A).
    pose (ASMR := algebra_scalar_rdist A).
    pose (AM := algebra_mult A).
    pose (AO := algebra_one A).
    pose (AL := algebra_ldist A).
    pose (AR := algebra_rdist A).
    apply card_unique_one.
    -   apply ex_set_type.
        pose proof (tensor_algebra_universal V (make_to_algebra V A f)) as g_ex.
        apply card_one_ex in g_ex as [g g_eq]; cbn in *.
        unfold to_algebra_set in g_eq; cbn in g_eq.
        change (to_algebra_algebra V (to_tensor_algebra V))
            with (tensor_algebra V) in g.
        change (module_homo_f (to_algebra_homo V (to_tensor_algebra V)))
            with (@vector_to_tensor F V) in g_eq.
        assert (∀ a b, eq_equal (ideal_equiv (ga_ideal Q)) a b →
            algebra_homo_f g a = algebra_homo_f g b) as g_wd.
        {
            intros a b eq.
            destruct eq as [l l_eq].
            rewrite <- plus_0_anb_a_b.
            rewrite <- (algebra_homo_neg g).
            rewrite <- (algebra_homo_plus _ _ g).
            unfold algebra_V, TN in l_eq.
            rewrite l_eq; clear l_eq.
            induction l as [|v l] using ulist_induction.
            {
                rewrite ulist_image_end, ulist_sum_end.
                symmetry; apply algebra_homo_zero.
            }
            rewrite ulist_image_add, ulist_sum_add.
            rewrite (algebra_homo_plus _ _ g).
            rewrite <- IHl; clear l IHl.
            rewrite plus_rid.
            destruct v as [[v1 v2] [v3 [v v3_eq]]]; cbn.
            rewrite v3_eq.
            do 2 rewrite (algebra_homo_mult _ _ g).
            rewrite algebra_homo_plus.
            rewrite algebra_homo_mult.
            rewrite g_eq.
            rewrite f_contr.
            rewrite algebra_homo_neg.
            rewrite algebra_homo_scalar.
            rewrite algebra_homo_one.
            rewrite plus_rinv.
            rewrite mult_ranni, mult_lanni.
            reflexivity.
        }
        pose (h := unary_op g_wd).
        change (equiv_type (ideal_equiv (ga_ideal Q))) with (ga Q) in h.
        assert (h_plus : ∀ u v, h (u + v) = h u + h v).
        {
            intros u v.
            equiv_get_value u v.
            unfold plus at 1, h; equiv_simpl.
            apply algebra_homo_plus.
        }
        assert (h_scalar : ∀ a v, h (a · v) = a · h v).
        {
            intros a v.
            equiv_get_value v.
            unfold scalar_mult at 1, h; equiv_simpl.
            apply algebra_homo_scalar.
        }
        assert (h_mult : ∀ u v, h (u * v) = h u * h v).
        {
            intros u v.
            equiv_get_value u v.
            unfold mult at 1, h; equiv_simpl.
            apply algebra_homo_mult.
        }
        assert (h_one : h 1 = 1).
        {
            unfold one at 1, h; equiv_simpl.
            apply algebra_homo_one.
        }
        exists (make_algebra_homomorphism F (geometric_algebra Q) A h
            h_plus h_scalar h_mult h_one).
        cbn.
        intros x.
        unfold h, vector_to_ga, tensor_to_ga; equiv_simpl.
        apply g_eq.
    -   intros [g g_eq] [h h_eq].
        apply set_type_eq; cbn.
        apply algebra_homomorphism_eq.
        intros x.
        pose proof (ga_sum Q x) as [l l_eq]; subst x.
        induction l using ulist_induction.
        {
            rewrite ulist_image_end, ulist_sum_end.
            replace (algebra_homo_f g 0) with 0;
                [>|symmetry; apply (algebra_homo_zero g)].
            symmetry; apply (algebra_homo_zero h).
        }
        rewrite ulist_image_add, ulist_sum_add.
        do 2 rewrite algebra_homo_plus.
        rewrite IHl; clear IHl.
        apply rplus; clear l.
        destruct a as [α l]; cbn.
        do 2 rewrite algebra_homo_scalar.
        apply f_equal; clear α.
        induction l.
        {
            cbn.
            change (tensor_to_ga Q 1) with (@one _ EO).
            do 2 rewrite algebra_homo_one.
            reflexivity.
        }
        cbn.
        do 2 rewrite algebra_homo_mult.
        rewrite IHl; clear IHl.
        apply rmult; clear l.
        rewrite g_eq, h_eq.
        reflexivity.
Qed.

End GeometricCategory.
