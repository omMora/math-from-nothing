Require Import init.

#[universes(template)]
Class Plus U := {
    plus : U → U → U;
}.
Infix "+" := plus : algebra_scope.

Class PlusAssoc U `{Plus U} := {
    plus_assoc : ∀ a b c, a + (b + c) = (a + b) + c;
}.
Class PlusComm U `{Plus U} := {
    plus_comm : ∀ a b, a + b = b + a;
}.

#[universes(template)]
Class Zero U := {
    zero : U;
}.
Class PlusLid U `{Plus U} `{Zero U} := {
    plus_lid : ∀ a, zero + a = a;
}.
Class PlusRid U `{Plus U} `{Zero U} := {
    plus_rid : ∀ a, a + zero = a;
}.

Class PlusLcancel U `{Plus U} := {
    plus_lcancel : ∀ {a b} c, c + a = c + b → a = b;
}.
Class PlusRcancel U `{Plus U} := {
    plus_rcancel : ∀ {a b} c, a + c = b + c → a = b;
}.

#[universes(template)]
Class Neg U := {
    neg : U → U;
}.
Notation "- a" := (neg a) : algebra_scope.
Notation "a - b" := (a + -b) : algebra_scope.
Class PlusLinv U `{Plus U} `{Zero U} `{Neg U} := {
    plus_linv : ∀ a, -a + a = zero;
}.
Class PlusRinv U `{Plus U} `{Zero U} `{Neg U} := {
    plus_rinv : ∀ a, a + -a = zero;
}.
Arguments plus : simpl never.
Arguments zero : simpl never.
Arguments neg : simpl never.

Notation "0" := zero : algebra_scope.

Class Group U `{
    UP : Plus U,
    UZ : Zero U,
    UN : Neg U,
    UPA : @PlusAssoc U UP,
    UPZ : @PlusLid U UP UZ,
    UPZR : @PlusRid U UP UZ,
    UPN : @PlusLinv U UP UZ UN,
    UPNR : @PlusRinv U UP UZ UN
}.

Class AbelianGroup U `{
    AGG : Group U,
    UPC : @PlusComm U UP
}.

Class AllPlus U `{
    APG : AbelianGroup U,
    UPL : @PlusLcancel U UP,
    UPR : @PlusRcancel U UP
}.


(* begin hide *)
Section PlusGroupImply.

Context {U} `{AllPlus U}.

Lemma plus_lid_rid_ : ∀ a, a + zero = a.
Proof.
    intros a.
    rewrite plus_comm.
    apply plus_lid.
Qed.

Lemma plus_lcancel_rcancel_ : ∀ a b c, a + c = b + c → a = b.
Proof.
    intros a b c eq.
    do 2 rewrite (plus_comm _ c) in eq.
    apply plus_lcancel with c.
    exact eq.
Qed.

Lemma plus_linv_rinv : ∀ a, a + -a = 0.
Proof.
    intros a.
    rewrite plus_comm.
    apply plus_linv.
Qed.

Global Instance plus_lid_rid : PlusRid U := {
    plus_rid := plus_lid_rid_;
}.

Global Instance plus_lcancel_rcancel : PlusRcancel U := {
    plus_rcancel := plus_lcancel_rcancel_;
}.

Global Instance plus_linv_rinv_class : PlusRinv U := {
    plus_rinv := plus_linv_rinv
}.

End PlusGroupImply.


Section PlusGroup.

Context {U} `{AllPlus U, NotTrivial U}.

(* end hide *)
Theorem lplus : ∀ {a b} c, a = b → c + a = c + b.
Proof.
    intros a b c ab.
    apply f_equal.
    exact ab.
Qed.
Theorem rplus : ∀ {a b} c, a = b → a + c = b + c.
Proof.
    intros a b c ab.
    rewrite ab.
    reflexivity.
Qed.
Theorem lrplus : ∀ {a b c d}, a = b → c = d → a + c = b + d.
Proof.
    intros a b c d ab cd.
    rewrite ab, cd.
    reflexivity.
Qed.

Theorem not_trivial_zero : ∃ a, 0 ≠ a.
Proof.
    apply not_trivial2.
Qed.

(* begin hide *)
End PlusGroup.

Section PlusGroup2.

Context {U} `{AllPlus U}.

Lemma plus_linv_lcancel : ∀ a b c, c + a = c + b → a = b.
Proof.
    intros a b c eq.
    apply lplus with (-c) in eq.
    do 2 rewrite plus_assoc in eq.
    rewrite plus_linv in eq.
    do 2 rewrite plus_lid in eq.
    exact eq.
Qed.
Lemma plus_rinv_rcancel : ∀ a b c, a + c = b + c → a = b.
Proof.
    intros a b c eq.
    apply rplus with (-c) in eq.
    do 2 rewrite <- plus_assoc in eq.
    rewrite plus_rinv in eq.
    do 2 rewrite plus_rid in eq.
    exact eq.
Qed.
Global Instance plus_linv_lcancel_class : PlusLcancel U := {
    plus_lcancel := plus_linv_lcancel
}.
Global Instance plus_rinv_rcancel_class : PlusRcancel U := {
    plus_rcancel := plus_rinv_rcancel
}.
(* end hide *)
Theorem neg_zero : -0 = 0.
Proof.
    apply plus_rcancel with 0.
    rewrite plus_linv.
    rewrite plus_rid.
    reflexivity.
Qed.

Theorem neg_neg : ∀ a, --a = a.
Proof.
    intros a.
    apply plus_rcancel with (-a).
    rewrite plus_linv, plus_rinv.
    reflexivity.
Qed.

Theorem neg_eq : ∀ a b, a = b ↔ -a = -b.
Proof.
    intros a b.
    split; intros eq.
    -   apply lplus with (-a) in eq.
        rewrite plus_linv in eq.
        apply rplus with (-b) in eq.
        rewrite <- plus_assoc, plus_rinv, plus_rid, plus_lid in eq.
        symmetry; exact eq.
    -   apply lplus with a in eq.
        rewrite plus_rinv in eq.
        apply rplus with b in eq.
        rewrite <- plus_assoc, plus_linv, plus_rid, plus_lid in eq.
        symmetry; exact eq.
Qed.

Theorem neg_plus : ∀ a b, -(a + b) = -a + -b.
Proof.
    intros a b.
    apply plus_rcancel with b.
    apply plus_lcancel with a.
    rewrite plus_comm.
    repeat rewrite <- plus_assoc.
    rewrite (plus_comm b a).
    do 2 rewrite plus_linv.
    rewrite plus_rid.
    rewrite plus_rinv.
    reflexivity.
Qed.

Theorem plus_rrinv : ∀ a b, a + b - b = a.
Proof.
    intros a b.
    rewrite <- plus_assoc.
    rewrite plus_rinv.
    apply plus_rid.
Qed.
Theorem plus_rlinv : ∀ a b, a - b + b = a.
Proof.
    intros a b.
    rewrite <- plus_assoc.
    rewrite plus_linv.
    apply plus_rid.
Qed.
Theorem plus_lrinv : ∀ a b, b + (-b + a) = a.
Proof.
    intros a b.
    rewrite plus_assoc.
    rewrite plus_rinv.
    apply plus_lid.
Qed.
Theorem plus_llinv : ∀ a b, -b + (b + a) = a.
Proof.
    intros a b.
    rewrite plus_assoc.
    rewrite plus_linv.
    apply plus_lid.
Qed.

Theorem plus_llmove : ∀ a b c, a + b = c ↔ b = -a + c.
Proof.
    intros a b c.
    split; intros eq.
    -   apply lplus with (-a) in eq.
        rewrite plus_llinv in eq.
        exact eq.
    -   apply lplus with a in eq.
        rewrite plus_lrinv in eq.
        exact eq.
Qed.
Theorem plus_lrmove : ∀ a b c, a + b = c ↔ a = c - b.
Proof.
    intros a b c.
    split; intros eq.
    -   apply rplus with (-b) in eq.
        rewrite plus_rrinv in eq.
        exact eq.
    -   apply rplus with b in eq.
        rewrite plus_rlinv in eq.
        exact eq.
Qed.
Theorem plus_rlmove : ∀ a b c, a = b + c ↔ -b + a = c.
Proof.
    intros a b c.
    split; intros eq.
    -   apply lplus with (-b) in eq.
        rewrite plus_llinv in eq.
        exact eq.
    -   apply lplus with b in eq.
        rewrite plus_lrinv in eq.
        exact eq.
Qed.
Theorem plus_rrmove : ∀ a b c, a = b + c ↔ a - c = b.
Proof.
    intros a b c.
    split; intros eq.
    -   apply rplus with (-c) in eq.
        rewrite plus_rrinv in eq.
        exact eq.
    -   apply rplus with c in eq.
        rewrite plus_rlinv in eq.
        exact eq.
Qed.

Theorem plus_0_ab_na_b : ∀ a b, 0 = a + b ↔ -a = b.
Proof.
    intros a b.
    rewrite plus_rlmove.
    rewrite plus_rid.
    reflexivity.
Qed.
Theorem plus_0_ab_nb_a : ∀ a b, 0 = a + b ↔ -b = a.
Proof.
    intros a b.
    rewrite plus_rrmove.
    rewrite plus_lid.
    reflexivity.
Qed.
Theorem plus_0_ab_a_nb : ∀ a b, 0 = a + b ↔ a = -b.
Proof.
    intros a b.
    rewrite plus_rlmove.
    rewrite plus_rid.
    rewrite neg_eq.
    rewrite neg_neg.
    reflexivity.
Qed.
Theorem plus_0_ab_b_na : ∀ a b, 0 = a + b ↔ b = -a.
Proof.
    intros a b.
    rewrite plus_rrmove.
    rewrite plus_lid.
    rewrite neg_eq.
    rewrite neg_neg.
    reflexivity.
Qed.

Theorem plus_0_a_ab_b : ∀ a b, 0 = a ↔ a + b = b.
Proof.
    intros a b.
    rewrite plus_llmove.
    rewrite plus_rrmove.
    rewrite plus_rinv.
    rewrite neg_eq.
    rewrite neg_zero.
    reflexivity.
Qed.
Theorem plus_0_a_ba_b : ∀ a b, 0 = a ↔ b + a = b.
Proof.
    intros a b.
    rewrite plus_lrmove.
    rewrite plus_rlmove.
    rewrite plus_linv.
    rewrite neg_eq.
    rewrite neg_zero.
    reflexivity.
Qed.
Theorem plus_0_a_b_ab : ∀ a b, 0 = a ↔ b = a + b.
Proof.
    intros a b.
    rewrite plus_rrmove.
    rewrite plus_rinv.
    reflexivity.
Qed.
Theorem plus_0_a_b_ba : ∀ a b, 0 = a ↔ b = b + a.
Proof.
    intros a b.
    rewrite plus_rlmove.
    rewrite plus_linv.
    reflexivity.
Qed.

Theorem plus_0_nab_a_b : ∀ a b, 0 = -a + b ↔ a = b.
Proof.
    intros a b.
    rewrite plus_0_ab_na_b.
    rewrite neg_neg.
    reflexivity.
Qed.
Theorem plus_0_anb_a_b : ∀ a b, 0 = a - b ↔ a = b.
Proof.
    intros a b.
    rewrite plus_0_ab_a_nb.
    rewrite neg_neg.
    reflexivity.
Qed.
Theorem plus_0_nab_b_a : ∀ a b, 0 = -a + b ↔ b = a.
Proof.
    intros a b.
    rewrite plus_0_ab_b_na.
    rewrite neg_neg.
    reflexivity.
Qed.
Theorem plus_0_anb_b_a : ∀ a b, 0 = a - b ↔ b = a.
Proof.
    intros a b.
    rewrite plus_0_ab_nb_a.
    rewrite neg_neg.
    reflexivity.
Qed.

(* begin hide *)
End PlusGroup2.
(* end hide *)
Tactic Notation "plus_bring_left" constr(x) :=
    repeat rewrite plus_assoc;
    repeat rewrite (plus_comm _ x);
    repeat rewrite <- plus_assoc.
Tactic Notation "plus_bring_left" constr(x) "in" ident(H) :=
    repeat rewrite plus_assoc in H;
    repeat rewrite (plus_comm _ x) in H;
    repeat rewrite <- plus_assoc in H.
Tactic Notation "plus_bring_right" constr(x) :=
    repeat rewrite <- plus_assoc;
    repeat rewrite (plus_comm x _);
    repeat rewrite plus_assoc.
Tactic Notation "plus_bring_right" constr(x) "in" ident(H) :=
    repeat rewrite <- plus_assoc in H;
    repeat rewrite (plus_comm x _) in H;
    repeat rewrite plus_assoc in H.
Tactic Notation "plus_cancel_left" constr(x) :=
    plus_bring_left x;
    apply lplus.
Tactic Notation "plus_cancel_left" constr(x) "in" ident(H) :=
    plus_bring_left x in H;
    apply plus_lcancel in H.
Tactic Notation "plus_cancel_right" constr(x) :=
    plus_bring_right x;
    apply rplus.
Tactic Notation "plus_cancel_right" constr(x) "in" ident(H) :=
    plus_bring_right x in H;
    apply plus_rcancel in H.
