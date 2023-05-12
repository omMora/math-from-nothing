Require Import init.
Require Import set.

Require Export category_base.

Record Functor (C1 : Category) (C2 : Category) := make_category {
    functor_f :> cat_U C1 → cat_U C2;
    functor_morphism : ∀ {A B},
        morphism A B → morphism (functor_f A) (functor_f B);
    functor_compose : ∀ {A B C} (f : morphism B C) (g : morphism A B),
        functor_morphism (f ∘ g) = functor_morphism f ∘ functor_morphism g;
    functor_id : ∀ A, functor_morphism (cat_id A) = 𝟙;
}.

Arguments functor_f {C1 C2} f0 A.
Arguments functor_morphism {C1 C2} f0 {A B} f.

Notation "⌈ F ⌉" := (functor_morphism F) (at level 40).

(* begin show *)
Program Definition id_functor (C0 : Category) : Functor C0 C0 := {|
    functor_f A := A;
    functor_morphism A B f := f;
|}.
(* end show *)

Notation "𝟏" := (id_functor _).

(* begin show *)
Program Definition compose_functor {C1 : Category} {C2 : Category} {C3 : Category}
    (F : Functor C2 C3) (G : Functor C1 C2) : Functor C1 C3 :=
{|
    functor_f a := F (G a);
    functor_morphism A B (f : morphism A B) := ⌈F⌉ (⌈G⌉ f);
|}.
(* end show *)
Next Obligation.
Proof.
    rewrite functor_compose.
    rewrite functor_compose.
    reflexivity.
Qed.
Next Obligation.
Proof.
    rewrite functor_id.
    rewrite functor_id.
    reflexivity.
Qed.

Notation "F ○ G" := (compose_functor F G) (at level 40, left associativity).

(* begin show *)
Program Definition inclusion_functor {C : Category} (S : SubCategory C)
    : Functor (subcategory S) C :=
{|
    functor_f x := [x|];
    functor_morphism A B (f : morphism A B) := [f|];
|}.
(* end show *)

Definition faithful_functor {C1 C2 : Category} (F : Functor C1 C2) := ∀ A B,
    Injective (functor_morphism F (A:=A) (B:=B)).
Definition full_functor {C1 C2 : Category} (F : Functor C1 C2) := ∀ A B,
    Surjective (functor_morphism F (A:=A) (B:=B)).

Theorem id_functor_faithful : ∀ C, faithful_functor (id_functor C).
Proof.
    intros C0 A B.
    split.
    intros f g eq.
    cbn in eq.
    exact eq.
Qed.
Theorem id_functor_full : ∀ C, full_functor (id_functor C).
Proof.
    intros C0 A B.
    split.
    intros f.
    cbn in f.
    exists f.
    cbn.
    reflexivity.
Qed.

Theorem inclusion_functor_faithful : ∀ {C : Category} (S : SubCategory C),
        faithful_functor (inclusion_functor S).
Proof.
    intros C0 S A B.
    split.
    intros f g eq.
    cbn in eq.
    apply set_type_eq in eq.
    exact eq.
Qed.
Theorem inclusion_functor_full : ∀ {C : Category} (S : SubCategory C),
    full_subcategory S → full_functor (inclusion_functor S).
Proof.
    intros H S S_full A B.
    split.
    intros f.
    cbn in *.
    unfold full_subcategory in S_full.
    specialize (S_full [A|] [B|]).
    rewrite S_full.
    exists [f|true].
    reflexivity.
Qed.

Definition essentially_surjective {C1 : Category} {C2 : Category}
    (F : Functor C1 C2)
    := ∀ B, ∃ A, isomorphic (F A) B.

(* begin hide *)
Section Functor.

Context {C1 : Category} {C2 : Category} {F : Functor C1 C2}.

(* end hide *)
Theorem functor_isomorphism : ∀ A B, isomorphic A B → isomorphic (F A) (F B).
Proof.
    intros A B [f [g [fg gf]]].
    exists (⌈F⌉ f).
    exists (⌈F⌉ g).
    rewrite <- functor_compose.
    rewrite <- functor_compose.
    rewrite fg, gf.
    split; apply functor_id.
Qed.

(* begin hide *)
End Functor.

(* end hide *)
Definition functor_morphism_convert_type {C1 : Category} {C2 : Category}
        {F : Functor C1 C2} {G : Functor C1 C2} {A B} (H : ∀ A, F A = G A)
        (f : morphism (F A) (F B)) : morphism (G A) (G B).
Proof.
    rewrite (H A) in f.
    rewrite (H B) in f.
    exact f.
Defined.

Theorem functor_eq {C1 : Category} {C2 : Category} : ∀ {F G : Functor C1 C2},
        ∀ (H : ∀ A, F A = G A),
        (∀ {A B} (f : morphism A B),
            functor_morphism_convert_type H (⌈F⌉ f) = ⌈G⌉ f) →
        F = G.
Proof.
    intros [f1 morphism1 compose1 id1] [f2 morphism2 compose2 id2] H eq'.
    cbn in *.
    assert (f1 = f2) as eq.
    {
        apply functional_ext.
        exact H.
    }
    subst f2.
    assert (morphism1 = morphism2) as eq.
    {
        apply functional_ext; intros A.
        apply functional_ext; intros B.
        apply functional_ext; intros f.
        rewrite <- eq'.
        unfold functor_morphism_convert_type.
        pose (HA := Logic.eq_refl (f1 A)).
        pose (HB := Logic.eq_refl (f1 B)).
        rewrite (proof_irrelevance (H A) HA).
        rewrite (proof_irrelevance (H B) HB).
        cbn.
        reflexivity.
    }
    subst morphism2; clear H eq'.
    rewrite (proof_irrelevance compose2 compose1).
    rewrite (proof_irrelevance id2 id1).
    reflexivity.
Qed.

Theorem functor_lid {C1 : Category} {C2 : Category} : ∀ (F : Functor C1 C2),
        𝟏 ○ F = F.
Proof.
    intros F.
    assert (∀ A, (𝟏 ○ F) A = F A) as H by reflexivity.
    apply (functor_eq H).
    intros A B f.
    cbn.
    unfold functor_morphism_convert_type.
    cbn in *.
    pose (HA := Logic.eq_refl (F A)).
    pose (HB := Logic.eq_refl (F B)).
    rewrite (proof_irrelevance (H A) HA).
    rewrite (proof_irrelevance (H B) HB).
    cbn.
    reflexivity.
Qed.

Theorem functor_rid {C1 : Category} {C2 : Category} : ∀ (F : Functor C1 C2),
        F ○ 𝟏 = F.
Proof.
    intros F.
    assert (∀ A, (F ○ 𝟏) A = F A) as H by reflexivity.
    apply (functor_eq H).
    intros A B f.
    cbn.
    unfold functor_morphism_convert_type.
    cbn in *.
    pose (HA := Logic.eq_refl (F A)).
    pose (HB := Logic.eq_refl (F B)).
    rewrite (proof_irrelevance (H A) HA).
    rewrite (proof_irrelevance (H B) HB).
    cbn.
    reflexivity.
Qed.

Theorem functor_assoc
        {C1 : Category} {C2 : Category} {C3 : Category} {C4 : Category} :
        ∀ (F : Functor C3 C4) (G : Functor C2 C3) (H : Functor C1 C2),
        F ○ (G ○ H) = (F ○ G) ○ H.
Proof.
    intros F G H.
    assert (∀ A, (F ○ (G ○ H)) A = ((F ○ G) ○ H) A) as H' by reflexivity.
    apply (functor_eq H').
    intros A B f.
    unfold functor_morphism_convert_type.
    cbn in *.
    pose (HA := Logic.eq_refl (F (G (H A)))).
    pose (HB := Logic.eq_refl (F (G (H B)))).
    rewrite (proof_irrelevance (H' A) HA).
    rewrite (proof_irrelevance (H' B) HB).
    cbn.
    reflexivity.
Qed.

Program Definition CATEGORY : Category := {|
    cat_U := Category;
    morphism A B := Functor A B;
    cat_compose A B C f g := f ○ g;
    cat_id A := id_functor A;
|}.
Next Obligation.
Proof.
    apply functor_assoc.
Qed.
Next Obligation.
Proof.
    apply functor_lid.
Qed.
Next Obligation.
Proof.
    apply functor_rid.
Qed.
