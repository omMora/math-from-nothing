Require Import init.

Require Export order_bounds.
Require Import set_base.
Require Import set_set.
Require Import set_order.

Section Zorn.

Context {U : Type}.
Variable (op : U → U → Prop).
Context `{
    Reflexive U op,
    Antisymmetric U op,
    Transitive U op
}.

Local Instance zorn_order : Order U := {le := op}.

Section NotZorn.

Hypothesis not_zorn : ¬((∀ F : U → Prop, is_chain le F → has_upper_bound le F) →
    ∃ a : U, ∀ x : U, ¬ a < x).

Lemma zorn_sub_ex : ∀ C : U → Prop, is_chain le C → ∃ x, ∀ a, C a → a < x.
Proof.
    intros C C_chain.
    rewrite not_impl in not_zorn.
    destruct not_zorn as [ub gt].
    specialize (ub C C_chain) as [u u_upper].
    rewrite not_ex in gt.
    specialize (gt u).
    rewrite not_all in gt.
    destruct gt as [x x_gt].
    rewrite not_not in x_gt.
    exists x.
    intros a Ca.
    specialize (u_upper a Ca).
    exact (le_lt_trans u_upper x_gt).
Qed.

Let f (C : U → Prop) (H : is_chain le C) := ex_val (zorn_sub_ex C H).

Lemma zorn_f_lt : ∀ (C : U → Prop) (H : is_chain le C), ∀ x, C x → x < f C H.
Proof.
    intros C CH x Cx.
    unfold f.
    rewrite_ex_val z z_gt.
    apply z_gt.
    exact Cx.
Qed.

Lemma zorn_f_eq : ∀ A B H1 H2, A = B → f A H1 = f B H2.
Proof.
    intros A B AH BH eq.
    subst.
    apply f_equal.
    apply proof_irrelevance.
Qed.

Let P (C : U → Prop) (x : U) := λ y, C y ∧ y < x.

Lemma zorn_wo_chain : ∀ (A : U → Prop) x, well_orders le A → is_chain le (P A x).
Proof.
    intros A x A_wo.
    apply well_orders_chain in A_wo.
    apply (chain_subset A A_wo).
    intros a Pa.
    apply Pa.
Qed.

Let conforming (A : U → Prop) :=
    well_orders le A ⋏
    λ H, (∀ x, A x → x = f (P A x) (zorn_wo_chain A x H)).

Let initial_segment (A : U → Prop) (B : U → Prop) := ∃ x, B x ∧ A = P B x.

Local Open Scope set_scope.

Lemma zorn_initial1 : ∀ A B, conforming A → conforming B →
    ∀ x y, A y → B x → ¬B y → x < y.
Proof.
    intros A B [A_wo A_conf] [B_wo B_conf] a b Ab Ba Bb.
    pose proof (A_wo (A - B)) as AB_ex.
    prove_parts AB_ex; [>apply inter_lsub|exists b; split; assumption|].
    destruct AB_ex as [x [[Ax Bx] x_least]].
    apply (lt_le_trans2 (x_least b (make_and Ab Bb))).
    classic_contradiction contr.
    pose proof (B_wo (B - P A x)) as BA_ex.
    prove_parts BA_ex; [>apply inter_lsub| |].
    {
        exists a.
        split; [>exact Ba|].
        unfold P.
        rewrite not_and.
        right; exact contr.
    }
    destruct BA_ex as [y [[By PAy] y_least]].
    clear a b Ba Ab Bb contr.
    pose proof (A_wo (A - P B y)) as z_ex.
    prove_parts z_ex; [>apply inter_lsub| |].
    {
        exists x.
        split; [>exact Ax|].
        unfold P.
        rewrite not_and.
        left.
        exact Bx.
    }
    destruct z_ex as [z [[Az PBz] z_least]].
    assert (z ≤ x) as zx.
    {
        apply z_least.
        split; [>exact Ax|].
        unfold P.
        rewrite not_and.
        left.
        exact Bx.
    }
    assert (P A z = P B y) as eq.
    {
        apply antisym.
        -   intros c [Ac c_lt].
            classic_contradiction PBc.
            specialize (z_least c (make_and Ac PBc)).
            destruct (le_lt_trans z_least c_lt); contradiction.
        -   intros c [Bc c_lt].
            split.
            +   classic_contradiction contr2.
                assert (y ≤ c) as leq.
                {
                    apply y_least.
                    split; [>exact Bc|].
                    unfold P.
                    rewrite not_and.
                    left.
                    exact contr2.
                }
                destruct (lt_le_trans c_lt leq); contradiction.
            +   unfold P in PBz.
                rewrite not_and in PBz.
                classic_case (B z) as [Bz|Bz].
                2: {
                    pose proof (x_least z (make_and Az Bz)) as xz.
                    pose proof (antisym xz zx) as eq; subst z.
                    classic_contradiction contr2.
                    assert (y ≤ c) as leq.
                    {
                        apply y_least.
                        split; [>exact Bc|].
                        unfold P.
                        rewrite not_and.
                        right.
                        exact contr2.
                    }
                    destruct (lt_le_trans c_lt leq); contradiction.
                }
                destruct PBz as [Bz'|zy]; [>contradiction|].
                apply (lt_le_trans c_lt).
                unfold strict in zy.
                rewrite not_and in zy.
                rewrite not_not in zy.
                destruct zy as [leq|eq].
                --  destruct (well_orders_chain B B_wo y z By Bz) as [yz|yz].
                    ++  exact yz.
                    ++  contradiction.
                --  subst; apply refl.
    }
    specialize (A_conf z Az).
    specialize (B_conf y By).
    pose proof (zorn_f_eq _ _ (zorn_wo_chain A z A_wo)
        (zorn_wo_chain B y B_wo) eq) as eq2.
    rewrite <- A_conf, <- B_conf in eq2.
    subst z.
    unfold P in PAy.
    rewrite not_and in PAy.
    destruct PAy as [Ay|yx]; [>contradiction|].
    apply yx.
    split; [>exact zx|].
    intro; subst y.
    contradiction.
Qed.

Lemma zorn_initial2 : ∀ A B, conforming A → conforming B →
    ∀ x y, x ≤ y → A x → B y → B x.
Proof.
    intros A B A_conf B_conf x y xy Ax By.
    classic_contradiction Bx.
    pose proof (zorn_initial1 A B A_conf B_conf y x Ax By Bx) as ltq.
    contradiction (irrefl _ (le_lt_trans xy ltq)).
Qed.

Lemma zorn_conforming_union : conforming (⋃ conforming).
Proof.
    assert (well_orders le (⋃ conforming)) as conf_wo.
    {
        intros S S_sub [x Sx].
        pose proof Sx as Sx'.
        apply S_sub in Sx'.
        destruct Sx' as [A [A_conf Ax]].
        pose proof (ldand A_conf) as A_wo.
        specialize (A_wo (A ∩ S) (inter_lsub _ _)
            (ex_intro _ x (make_and Ax Sx))) as [a [[Aa Sa] a_le]].
        exists a.
        split; [>exact Sa|].
        intros y Sy.
        pose proof Sy as Sy'.
        apply S_sub in Sy'.
        destruct Sy' as [B [B_conf By]].
        clear x Sx Ax.
        classic_case (A y) as [Ay|nAy].
        -   apply a_le.
            split; assumption.
        -   apply (zorn_initial1 B A B_conf A_conf _ _ By Aa nAy).
    }
    split with conf_wo.
    intros x [A [A_conf Ax]].
    pose proof A_conf as [A_wo x_eq].
    specialize (x_eq x Ax).
    rewrite x_eq at 1; clear x_eq.
    apply zorn_f_eq.
    apply antisym.
    -   intros c [Ac c_lt].
        split; [>|exact c_lt].
        exists A.
        split; assumption.
    -   intros c [[B [B_conf Bc]] c_lt].
        split; [>|exact c_lt].
        exact (zorn_initial2 B A B_conf A_conf _ _ (land c_lt) Bc Ax).
Qed.

Theorem zorn_contr : False.
Proof.
    pose (x := f _ (well_orders_chain _ (ldand zorn_conforming_union))).
    assert (conforming (⋃ conforming ∪ ❴x❵)) as conf.
    {
        assert (well_orders le (⋃ conforming ∪ ❴x❵)) as wo.
        {
            intros S S_sub S_ex.
            classic_case (⋃ conforming ∩ S = ∅) as [S_empty|S_nempty].
            {
                assert (S = ❴x❵) as S_eq.
                {
                    apply antisym.
                    -   intros y Sy.
                        specialize (S_sub _ Sy) as [y_in|y_eq].
                        +   assert (∅ y) as y_in'.
                            {
                                rewrite <- S_empty.
                                split; assumption.
                            }
                            contradiction y_in'.
                        +   exact y_eq.
                    -   intros y y_eq.
                        rewrite singleton_eq in y_eq; subst y.
                        destruct S_ex as [y Sy].
                        specialize (S_sub _ Sy) as [y_in|y_eq].
                        +   assert (∅ y) as y_in'.
                            {
                                rewrite <- S_empty.
                                split; assumption.
                            }
                            contradiction y_in'.
                        +   rewrite singleton_eq in y_eq; subst.
                            exact Sy.
                }
                exists x.
                subst S.
                split; [>rewrite singleton_eq; reflexivity|].
                intros y y_eq; rewrite singleton_eq in y_eq; subst.
                apply refl.
            }
            rewrite empty_neq in S_nempty.
            pose proof (ldand zorn_conforming_union (⋃ conforming ∩ S)) as a_ex.
            prove_parts a_ex; [>apply inter_lsub|exact S_nempty|].
            destruct a_ex as [a [[a_in Sa] a_least]].
            exists a.
            split; [>exact Sa|].
            intros y Sy.
            specialize (S_sub y Sy) as [y_in|y_eq].
            -   apply a_least.
                split; assumption.
            -   rewrite singleton_eq in y_eq; subst y.
                unfold x.
                apply zorn_f_lt.
                exact a_in.
        }
        split with wo.
        intros y [y_in|y_eq].
        -   destruct y_in as [A [A_conf Ay]].
            pose proof A_conf as [A_wo A_conf'].
            rewrite (A_conf' y Ay) at 1.
            apply zorn_f_eq.
            apply antisym.
            +   intros a [Aa a_lt].
                split; [>|exact a_lt].
                left.
                exists A.
                split; assumption.
            +   intros a [[a_in|a_eq] a_lt].
                *   split; [>|exact a_lt].
                    destruct a_in as [B [B_conf Ba]].
                    exact (zorn_initial2 B A B_conf A_conf _ _ (land a_lt) Ba Ay).
                *   rewrite singleton_eq in a_eq.
                    subst a.
                    assert (y < x) as ltq.
                    {
                        apply zorn_f_lt.
                        exists A.
                        split; assumption.
                    }
                    destruct (trans a_lt ltq); contradiction.
        -   rewrite singleton_eq in y_eq; subst y.
            unfold x at 1.
            apply zorn_f_eq.
            apply antisym.
            +   intros a a_in.
                split.
                *   left.
                    exact a_in.
                *   apply zorn_f_lt.
                    exact a_in.
            +   intros a [a_in a_lt].
                destruct a_in as [a_in|a_eq].
                *   exact a_in.
                *   rewrite singleton_eq in a_eq; subst a.
                    destruct a_lt; contradiction.
    }
    assert ((⋃ conforming ∪ ❴x❵) x) as x_in1 by (right; reflexivity).
    assert ((⋃ conforming) x) as x_in2.
    {
        exists (⋃ conforming ∪ ❴x❵).
        split; [>exact conf|exact x_in1].
    }
    unfold x in x_in2.
    unfold f in x_in2.
    rewrite_ex_val x' x'_lt.
    specialize (x'_lt _ x_in2).
    destruct x'_lt; contradiction.
Qed.

End NotZorn.

Theorem zorn : (∀ F : U → Prop, is_chain le F → has_upper_bound le F) →
    ∃ a : U, ∀ x : U, ¬ a < x.
Proof.
    classic_contradiction contr.
    exact (zorn_contr contr).
Qed.

End Zorn.
