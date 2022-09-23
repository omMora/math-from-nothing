Require Import init.

Require Export relation.

Declare Scope set_scope.
Delimit Scope set_scope with set.

(* begin hide *)
Open Scope set_scope.
(* end hide *)

Definition subset {U : Type} (S T : U → Prop) := ∀ x, S x → T x.
Infix "⊆" := subset.
Infix "⊂" := (strict subset) (at level 50, no associativity).

Definition empty {U : Type} := λ x : U, False.
Definition all {U : Type} := λ x : U, True.
Notation "∅" := empty.

Definition singleton {U : Type} (x : U) := λ y, x = y.

Definition union {U : Type} (S T : U → Prop) := λ x, S x ∨ T x.
Infix "∪" := union.
Definition intersection {U : Type} (S T : U → Prop) := λ x, S x ∧ T x.
Infix "∩" := intersection.
Definition set_minus {U : Type} (S T : U → Prop) := λ x, S x ∧ ¬T x.
Infix "-" := set_minus : set_scope.
Definition symmetric_difference {U : Type} (S T : U → Prop) := (S-T) ∪ (T-S).
Infix "+" := symmetric_difference : set_scope.
(** This is "\\mathbf C" *)
Definition 𝐂 {U : Type} (S : U → Prop) := λ x, ¬S x.

Definition cartesian_product {U V : Type} (S : U → Prop) (T : V → Prop) :=
    λ (x : U * V), S (fst x) ∧ T (snd x).
Infix "*" := cartesian_product : set_scope.

Definition disjoint {U : Type} (S T : U → Prop) := S ∩ T = ∅.
Definition intersects {U : Type} (S T : U → Prop) := S ∩ T ≠ ∅.

(* begin hide *)
Section SetBase.

Context {U : Type}.

(* end hide *)
Global Instance subset_refl : Reflexive (subset (U := U)).
Proof.
    split.
    intros S x Sx.
    exact Sx.
Qed.

Global Instance subset_trans : Transitive (subset (U := U)).
Proof.
    split.
    intros R S T RS ST x Rx.
    apply ST.
    apply RS.
    exact Rx.
Qed.

Global Instance subset_antisym : Antisymmetric (subset (U := U)).
Proof.
    split.
    intros S T ST TS.
    apply predicate_ext; intro x.
    split.
    -   apply ST.
    -   apply TS.
Qed.

Theorem empty_sub : ∀ S : U → Prop, ∅ ⊆ S.
Proof.
    intros S x contr.
    contradiction contr.
Qed.
Theorem all_sub : ∀ S : U → Prop, S ⊆ all.
Proof.
    intros S x Sx.
    exact true.
Qed.

Theorem empty_eq : ∀ S : U → Prop, S = ∅ ↔ (∀ x, ¬S x).
Proof.
    intros S.
    split.
    -   intros eq x Sx.
        rewrite eq in Sx.
        contradiction Sx.
    -   intros all_not.
        apply antisym.
        +   intros x Sx.
            exact (all_not x Sx).
        +   apply empty_sub.
Qed.

Theorem empty_neq : ∀ S : U → Prop, S ≠ ∅ ↔ (∃ x, S x).
Proof.
    intros S.
    split.
    -   intros S_neq.
        rewrite empty_eq in S_neq.
        classic_contradiction contr.
        rewrite not_ex in contr.
        contradiction.
    -   intros [x Sx] contr.
        rewrite contr in Sx.
        exact Sx.
Qed.

Theorem all_eq : ∀ S : U → Prop, S = all ↔ (∀ x, S x).
Proof.
    intros S.
    split.
    -   intros eq x.
        rewrite eq.
        exact true.
    -   intros all_in.
        apply antisym.
        +   apply all_sub.
        +   intros x Sx.
            apply all_in.
Qed.

Theorem all_neq : ∀ S : U → Prop, S ≠ all ↔ (∃ x, ¬S x).
Proof.
    intros S.
    split.
    -   intros S_neq.
        rewrite all_eq in S_neq.
        rewrite not_all in S_neq.
        exact S_neq.
    -   intros [x Sx] eq.
        rewrite eq in Sx.
        exact (Sx true).
Qed.

Theorem not_in_empty : ∀ x : U, ¬∅ x.
Proof.
    intros x contr.
    contradiction contr.
Qed.

Theorem union_comm : ∀ S T : U → Prop, S ∪ T = T ∪ S.
Proof.
    intros S T.
    apply predicate_ext; intros x.
    apply or_comm.
Qed.

Theorem union_assoc : ∀ R S T : U → Prop, R ∪ (S ∪ T) = (R ∪ S) ∪ T.
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply or_assoc.
Qed.

Theorem union_lid : ∀ S : U → Prop, ∅ ∪ S = S.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply or_lfalse.
Qed.
Theorem union_rid : ∀ S : U → Prop, S ∪ ∅ = S.
Proof.
    intros S.
    rewrite union_comm.
    apply union_lid.
Qed.

Theorem union_lanni : ∀ S : U → Prop, all ∪ S = all.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply or_ltrue.
Qed.
Theorem union_ranni : ∀ S : U → Prop, S ∪ all = all.
Proof.
    intros S.
    rewrite union_comm.
    apply union_lanni.
Qed.

Theorem union_lsub : ∀ S T : U → Prop, S ⊆ S ∪ T.
Proof.
    intros S T x Sx.
    left; exact Sx.
Qed.
Theorem union_rsub : ∀ S T : U → Prop, T ⊆ S ∪ T.
Proof.
    intros S T.
    rewrite union_comm.
    apply union_lsub.
Qed.

Theorem union_compl_all : ∀ S : U → Prop, S ∪ 𝐂 S = all.
Proof.
    intros S.
    apply predicate_ext; intros x.
    unfold union, 𝐂.
    pose proof (excluded_middle (S x)) as H.
    rewrite (prop_eq_true (S x ∨ ¬S x)) in H.
    rewrite H.
    reflexivity.
Qed.

Theorem union_idemp : ∀ S : U → Prop, S ∪ S = S.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply or_idemp.
Qed.

Theorem inter_comm : ∀ S T : U → Prop, S ∩ T = T ∩ S.
Proof.
    intros S T.
    apply predicate_ext; intros x.
    apply and_comm.
Qed.

Theorem inter_assoc : ∀ R S T : U → Prop, R ∩ (S ∩ T) = (R ∩ S) ∩ T.
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply and_assoc.
Qed.

Theorem inter_lid : ∀ S : U → Prop, all ∩ S = S.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply and_ltrue.
Qed.
Theorem inter_rid : ∀ S : U → Prop, S ∩ all = S.
Proof.
    intros S.
    rewrite inter_comm.
    apply inter_lid.
Qed.

Theorem inter_lanni : ∀ S : U → Prop, ∅ ∩ S = ∅.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply and_lfalse.
Qed.
Theorem inter_ranni : ∀ S : U → Prop, S ∩ ∅ = ∅.
Proof.
    intros S.
    rewrite inter_comm.
    apply inter_lanni.
Qed.

Theorem inter_lsub : ∀ S T : U → Prop, S ∩ T ⊆ S.
Proof.
    intros S T x [Sx Tx].
    exact Sx.
Qed.
Theorem inter_rsub : ∀ S T : U → Prop, S ∩ T ⊆ T.
Proof.
    intros S T.
    rewrite inter_comm.
    apply inter_lsub.
Qed.

Theorem lsub_inter_equal : ∀ S T : U → Prop, S ⊆ T → S ∩ T = S.
Proof.
    intros S T sub.
    apply antisym.
    -   intros x [Sx Tx].
        exact Sx.
    -   intros x Sx.
        split.
        +   exact Sx.
        +   exact (sub x Sx).
Qed.

Theorem rsub_inter_equal : ∀ S T : U → Prop, T ⊆ S → S ∩ T = T.
Proof.
    intros S T sub.
    rewrite inter_comm.
    apply lsub_inter_equal.
    exact sub.
Qed.

Theorem inter_compl_empty : ∀ S : U → Prop, S ∩ 𝐂 S = ∅.
Proof.
    intros S.
    apply empty_eq.
    intros x [Sx nSx].
    contradiction.
Qed.

Theorem inter_idemp : ∀ S : U → Prop, S ∩ S = S.
Proof.
    intros S.
    apply predicate_ext; intros x.
    apply and_idemp.
Qed.

Theorem union_ldist : ∀ R S T : U → Prop, R ∪ (S ∩ T) = (R ∪ S) ∩ (R ∪ T).
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply or_and_ldist.
Qed.
Theorem union_rdist : ∀ R S T : U → Prop, (R ∩ S) ∪ T = (R ∪ T) ∩ (S ∪ T).
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply or_and_rdist.
Qed.
Theorem inter_ldist : ∀ R S T : U → Prop, R ∩ (S ∪ T) = (R ∩ S) ∪ (R ∩ T).
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply and_or_ldist.
Qed.
Theorem inter_rdist : ∀ R S T : U → Prop, (R ∪ S) ∩ T = (R ∩ T) ∪ (S ∩ T).
Proof.
    intros R S T.
    apply predicate_ext; intros x.
    apply and_or_rdist.
Qed.

Theorem union_inter_self : ∀ A B : U → Prop, A ∪ (A ∩ B) = A.
Proof.
    intros A B.
    apply antisym.
    -   intros x [Ax|[Ax Bx]]; exact Ax.
    -   intros x Ax.
        left; exact Ax.
Qed.
Theorem inter_union_self : ∀ A B : U → Prop, A ∩ (A ∪ B) = A.
Proof.
    intros A B.
    apply antisym.
    -   intros x [Ax Bx]; exact Ax.
    -   intros x Ax.
        split; [>|left]; exact Ax.
Qed.

Theorem compl_compl : ∀ A : U → Prop, 𝐂 (𝐂 A) = A.
Proof.
    intros A.
    apply predicate_ext; intros x.
    unfold 𝐂.
    apply not_not.
Qed.

Theorem compl_empty : @𝐂 U ∅ = all.
Proof.
    apply predicate_ext; intros x.
    unfold 𝐂, empty.
    rewrite not_false.
    reflexivity.
Qed.

Theorem compl_all : @𝐂 U all = ∅.
Proof.
    apply predicate_ext; intros x.
    unfold 𝐂, all.
    rewrite not_true.
    reflexivity.
Qed.

Theorem union_compl : ∀ A B : U → Prop,
    𝐂 (A ∪ B) = 𝐂 A ∩ 𝐂 B.
Proof.
    intros A B.
    apply predicate_ext; intros x.
    apply not_or.
Qed.

Theorem inter_compl : ∀ A B : U → Prop,
    𝐂 (A ∩ B) = 𝐂 A ∪ 𝐂 B.
Proof.
    intros A B.
    apply predicate_ext; intros x.
    apply not_and.
Qed.

Theorem compl_eq : ∀ A B : U → Prop, 𝐂 A = 𝐂 B → A = B.
Proof.
    intros A B eq.
    apply predicate_ext; intros x.
    pose proof (func_eq _ _ eq x) as eq2.
    apply not_eq_eq in eq2.
    rewrite eq2.
    reflexivity.
Qed.

Theorem set_minus_formula : ∀ S T : U → Prop, S - T = S ∩ 𝐂 T.
Proof.
    reflexivity.
Qed.

Theorem set_minus_rempty : ∀ S : U → Prop, S - ∅ = S.
Proof.
    intros S.
    rewrite set_minus_formula.
    rewrite compl_empty.
    apply inter_rid.
Qed.

Theorem set_minus_lempty : ∀ S : U → Prop, ∅ - S = ∅.
Proof.
    intros S.
    rewrite set_minus_formula.
    apply inter_lanni.
Qed.

Theorem set_minus_inv : ∀ S : U → Prop, S - S = ∅.
Proof.
    intros S.
    rewrite set_minus_formula.
    apply inter_compl_empty.
Qed.

Theorem set_minus_twice : ∀ S T : U → Prop, S - T - T = S - T.
Proof.
    intros S T.
    do 2 rewrite set_minus_formula.
    rewrite <- inter_assoc.
    rewrite inter_idemp.
    reflexivity.
Qed.

Theorem symdif_formula : ∀ S T : U → Prop, S + T = (S ∪ T) - (S ∩ T).
Proof.
    intros S T.
    unfold symmetric_difference.
    do 3 rewrite set_minus_formula.
    rewrite inter_compl.
    rewrite union_ldist.
    do 2 rewrite union_rdist.
    rewrite (union_comm (𝐂 T)).
    do 2 rewrite union_compl_all.
    rewrite inter_lid.
    rewrite inter_rid.
    apply f_equal.
    apply union_comm.
Qed.

Theorem symdif_comm : ∀ S T : U → Prop, S + T = T + S.
Proof.
    intros S T.
    unfold symmetric_difference.
    apply union_comm.
Qed.

Theorem symdif_assoc : ∀ R S T : U → Prop, R + (S + T) = (R + S) + T.
Proof.
    intros R S T.
    rewrite (symdif_comm R S).
    rewrite (symdif_comm (S + R) T).
    rewrite symdif_formula.
    unfold symmetric_difference at 2.
    rewrite (symdif_formula S T).
    rewrite (symdif_formula T).
    unfold symmetric_difference at 2.
    rewrite (symdif_formula S R).
    do 8 rewrite set_minus_formula.
    do 4 rewrite inter_compl.
    do 2 rewrite union_compl.
    do 4 rewrite inter_compl.
    do 3 rewrite compl_compl.
    do 4 rewrite union_ldist.
    assert (∀ X Y Z : U → Prop, X ∪ (Y ∪ Z) = Z ∪ (Y ∪ X)) as lemma.
    {
        intros X Y Z.
        rewrite union_comm.
        rewrite union_assoc.
        rewrite (union_comm Y).
        reflexivity.
    }
    do 2 rewrite (lemma R).
    rewrite (lemma (𝐂 R)).
    do 2 rewrite (union_assoc _ _ S).
    rewrite (union_comm (𝐂 R) (𝐂 T)).
    do 2 rewrite <- inter_assoc.
    apply f_equal.
    do 2 rewrite inter_assoc.
    apply f_equal2; [>|reflexivity].
    apply inter_comm.
Qed.

Theorem symdif_lid : ∀ S : U → Prop, ∅ + S = S.
Proof.
    intros S.
    unfold symmetric_difference.
    rewrite set_minus_rempty.
    rewrite set_minus_lempty.
    apply union_lid.
Qed.
Theorem symdif_rid : ∀ S : U → Prop, S + ∅ = S.
Proof.
    intros S.
    rewrite symdif_comm.
    apply symdif_lid.
Qed.

Theorem symdif_inv : ∀ S : U → Prop, S + S = ∅.
Proof.
    intros S.
    unfold symmetric_difference.
    rewrite set_minus_inv.
    apply union_lid.
Qed.
(* begin hide *)

End SetBase.

Close Scope set_scope.
(* end hide *)
