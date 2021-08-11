Require Import init.

Require Export linear_base.
Require Import linear_multilinear.
Require Import nat.
Require Import card.
Require Import set.

(** This is a very diffenent definition of a tensor algebra than usual.  Really,
I'm trying to beeline to constructing geometric algebra, so I'm only doing what
is absolutely necessary to reach that goal.  This construction is much easier to
deal with than the traditional constructions.
*)

Section TensorAlgebra.

Variables U V : Type.

Context `{
    UP : Plus U,
    UZ : Zero U,
    UN : Neg U,
    @PlusComm U UP,
    @PlusAssoc U UP,
    @PlusLid U UP UZ,
    @PlusLinv U UP UZ UN,
    UM : Mult U,
    UO : One U,
    @Ldist U UP UM,
    @MultComm U UM,
    @MultAssoc U UM,
    @MultLid U UM UO,

    VP : Plus V,
    VZ : Zero V,
    VN : Neg V,
    @PlusComm V VP,
    @PlusAssoc V VP,
    @PlusLid V VP VZ,
    @PlusLinv V VP VZ VN,

    SM : ScalarMult U V,
    @ScalarId U V UO SM,
    @ScalarLdist U V VP SM,
    @ScalarRdist U V UP VP SM
}.

Existing Instance multilinear_plus.
Existing Instance multilinear_plus_comm.
Existing Instance multilinear_plus_assoc.
Existing Instance multilinear_zero.
Existing Instance multilinear_plus_lid.
Existing Instance multilinear_neg.
Existing Instance multilinear_plus_linv.
Existing Instance multilinear_scalar_mult.
Existing Instance multilinear_scalar_comp.
Existing Instance multilinear_scalar_id.
Existing Instance multilinear_scalar_ldist.
Existing Instance multilinear_scalar_rdist.

Local Open Scope card_scope.

(* TODO: Generalize this inifinite direct product to more general situations *)
Definition tensor_algebra_base := (∀ k, multilinear_type k).
Definition tensor_finite (A : tensor_algebra_base) :=
    finite (|set_type (λ k, 0 ≠ A k)|).
Definition tensor_algebra := set_type tensor_finite.

Lemma tensor_plus_finite : ∀ A B : tensor_algebra,
        tensor_finite (λ k, [A|] k + [B|] k).
    intros [A A_fin] [B B_fin]; cbn.
    apply fin_nat_ex in A_fin as [m m_eq].
    apply fin_nat_ex in B_fin as [n n_eq].
    assert (finite (nat_to_card m + nat_to_card n)) as mn_fin.
    {
        rewrite nat_to_card_plus.
        apply nat_is_finite.
    }
    apply (le_lt_trans2 mn_fin).
    rewrite m_eq, n_eq.
    clear m m_eq n n_eq mn_fin.
    unfold plus at 2, le; equiv_simpl.
    assert (∀ (n : set_type (λ k, 0 ≠ A k + B k)), {0 ≠ A [n|]} + {0 ≠ B [n|]})
        as n_in.
    {
        intros [n n_neq]; cbn.
        classic_case (0 = A n) as [Anz|Anz].
        -   right.
            rewrite <- Anz in n_neq.
            rewrite plus_lid in n_neq.
            exact n_neq.
        -   left; exact Anz.
    }
    exists (λ n, match (n_in n) with
        | strong_or_left  H => inl [[n|]|H]
        | strong_or_right H => inr [[n|]|H]
    end).
    intros a b eq.
    destruct (n_in a) as [neq1|neq1]; destruct (n_in b) as [neq2|neq2].
    all: inversion eq as [eq2].
    all: apply set_type_eq; exact eq2.
Qed.

Instance tensor_plus : Plus tensor_algebra := {
    plus A B := [_|tensor_plus_finite A B]
}.

Program Instance tensor_plus_comm : PlusComm tensor_algebra.
Next Obligation.
    unfold plus; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply plus_comm.
Qed.

Program Instance tensor_plus_assoc : PlusAssoc tensor_algebra.
Next Obligation.
    unfold plus; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply plus_assoc.
Qed.

Lemma tensor_zero_finite : tensor_finite (λ k, 0).
    unfold tensor_finite.
    assert (|set_type (λ k : nat, (zero (U := multilinear_type k)) ≠ 0)| = 0)
        as eq.
    {
        apply card_false_0.
        intros [a neq].
        contradiction.
    }
    rewrite eq.
    apply nat_is_finite.
Qed.

Instance tensor_zero : Zero tensor_algebra := {
    zero := [_|tensor_zero_finite]
}.

Program Instance tensor_plus_lid : PlusLid tensor_algebra.
Next Obligation.
    unfold plus, zero; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply plus_lid.
Qed.

Lemma tensor_neg_finite : ∀ A : tensor_algebra, tensor_finite (λ k, -[A|] k).
    intros [A A_fin]; cbn.
    apply fin_nat_ex in A_fin as [n n_eq].
    apply (le_lt_trans2 (nat_is_finite n)).
    rewrite n_eq; clear n n_eq.
    unfold le; equiv_simpl.
    assert (∀ (n : set_type (λ k, 0 ≠ - A k)), 0 ≠ A [n|]) as n_in.
    {
        intros [n n_neq]; cbn.
        intros eq.
        rewrite <- eq in n_neq.
        rewrite neg_zero in n_neq.
        contradiction.
    }
    exists (λ n, [[n|]|n_in n]).
    intros a b eq.
    apply eq_set_type in eq; cbn in eq.
    apply set_type_eq in eq; cbn in eq.
    exact eq.
Qed.

Instance tensor_neg : Neg tensor_algebra := {
    neg A := [_|tensor_neg_finite A]
}.

Program Instance tensor_plus_linv : PlusLinv tensor_algebra.
Next Obligation.
    unfold plus, neg, zero; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply plus_linv.
Qed.

Lemma tensor_scalar_finite : ∀ α (A : tensor_algebra),
        tensor_finite (λ k, α · [A|] k).
    intros α [A A_fin]; cbn.
    apply fin_nat_ex in A_fin as [n n_eq].
    apply (le_lt_trans2 (nat_is_finite n)).
    rewrite n_eq; clear n n_eq.
    unfold le; equiv_simpl.
    assert (∀ (n : set_type (λ k, 0 ≠ α · A k)), 0 ≠ A [n|]) as n_in.
    {
        intros [n n_neq]; cbn.
        intros eq.
        rewrite <- eq in n_neq.
        rewrite scalar_ranni in n_neq.
        contradiction.
    }
    exists (λ n, [[n|]|n_in n]).
    intros a b eq.
    apply eq_set_type in eq; cbn in eq.
    apply set_type_eq in eq; cbn in eq.
    exact eq.
Qed.

Instance tensor_scalar : ScalarMult U tensor_algebra := {
    scalar_mult α A := [_|tensor_scalar_finite α A]
}.

Program Instance tensor_scalar_comp : ScalarComp U tensor_algebra.
Next Obligation.
    unfold scalar_mult; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply scalar_comp.
Qed.

Program Instance tensor_scalar_id : ScalarId U tensor_algebra.
Next Obligation.
    unfold scalar_mult; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply scalar_id.
Qed.

Program Instance tensor_scalar_ldist : ScalarLdist U tensor_algebra.
Next Obligation.
    unfold plus, scalar_mult; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply scalar_ldist.
Qed.

Program Instance tensor_scalar_rdist : ScalarRdist U tensor_algebra.
Next Obligation.
    unfold plus at 2, scalar_mult; cbn.
    apply set_type_eq; cbn.
    apply functional_ext.
    intros n.
    apply scalar_rdist.
Qed.

End TensorAlgebra.
