-- Tarski's axioms formalized
import tactic

noncomputable theory
open_locale classical

constant Point : Type  -- There is a type called point

-- There is an infinite hierarchy of types
-- Type 0 == Type
-- Type 1
-- Type 2
-- .....

-- This is the Betweenness relation.
-- This is saying "y" is in between "x" and "z".
constant B (x y z : Point) : Prop

-- Axioms for betweenness that Tarski asked us to include
@[refl] axiom B_includes_end1 (x z : Point) : B x x z
@[refl] axiom B_includes_end2 (x z : Point) : B x z z

-- Congruence relation between 4 points.
-- A Segment just contains two pieces of data, i.e. the two end point.
structure Segment : Type := (p1 p2 : Point)
-- Lean automatically makes a definition for Segment.mk
constant C (s1 s2 : Segment) : Prop  -- s1 has the same length as s2

/-
-- Let us make some segments
variables x y : Point
#check Segment.mk x y
#check ({p1 := x,  p2 := y} : Segment)-/

-- We are defining our own operator here
local infix ` ≃ `:55 := C  -- \ equiv == equivalence/congruence
local infix `⬝`:56 := Segment.mk  -- \ cdot == center-dot

--- Next, we look at congruence axioms.

--- xy is congruent to yx
@[symm] axiom C_swap (x y : Point) : x⬝y ≃ y⬝x
@[tidy] axiom C_iden (x y z : Point) :  x⬝y ≃ z⬝z → x = y
@[trans] axiom C_trans (u v w x y z : Point) : (u⬝v ≃ z⬝w) → (u⬝v ≃ x⬝y) → z⬝w ≃ x⬝y
-- used to be (u⬝v ≃ z⬝w) ∧ (u⬝v ≃ x⬝y) → z⬝w ≃ x⬝y

--- Equivalence relations: (~ means is related to)
-- 1. Reflexive x ~ x
-- 2. Symmetric x ~ y → y ~ x
-- 3. Transitive x ~ y ∧ y ~ z → x ~ z
--- Example : Equality =
--- Non-example : Less-than-or-equal relation "≤"

--  Tarski is claiming that the congruence relation is an equivalence relation
-- Marking this lemma with a "refl" attribute.
-- This means, we are training the Lean AI called "refl" to learn this lemma
-- and apply it wherever appropriate.



@[refl] lemma C_refl (s : Segment) : s ≃ s :=
begin
  cases s with x y,  -- s is made of 2 points. Let's call these x and y.
  fapply C_trans,    -- fapply means apply the C_trans axiom.
  use y,
  use x,
  repeat {symmetry},     -- simmplify. Same as apply C_swap.
end

@[symm] lemma C_symm (s1 s2 : Segment) : s1 ≃ s2 → s2 ≃ s1 :=
begin
  intro H,
  cases s1 with x1 y1,
  cases s2 with x2 y2,
  fapply C_trans, 
    use x1,
    use y1,
    assumption, -- "use statements from the hypothesis". Same as apply H,
    refl,      -- "refl" means this is true by definition. Same as apply C_refl.
end


@[trans] lemma C_trans2 (s1 s2 s3 : Segment): s1 ≃ s2 → s2 ≃ s3 → s1 ≃ s3 :=
begin
  intros H1 H2,
  cases s1 with x1 y1,
  cases s2 with x2 y2,
  cases s3 with x3 y3,
  fapply C_trans,
    use x2,
    use y2,
    -- {...} helps us separate the proof of the two goals.
    { symmetry,  -- uses lemmas tagged with @[symm]. Same as apply C_symm.
      assumption}, -- Same as apply H1,
    { assumption},
end

lemma C_equiv : equivalence C :=
begin
  unfold equivalence,  -- replace with the definition of equivalence in the Goal
  split,
    { exact C_refl},
    split,
      { exact C_symm},
      { exact C_trans2},
end


@[symm] lemma C_swap_right (x y w z : Point) : x⬝y ≃ z⬝w → x⬝y ≃ w⬝z :=
begin
  intro H,
  transitivity,
    apply H,  -- this means use z⬝w for the unknown variable.
    exact C_swap z w,
end

@[symm] lemma C_swap_left (x y w z : Point) : x⬝y ≃ z⬝w → y⬝x ≃ z⬝w :=
begin
  intro H,
  fapply C_trans,
    use x,
    use y,
    { symmetry, refl},
    { exact H},
end

@[symm] lemma C_swap_both (x y w z : Point) : x⬝y ≃ z⬝w → y⬝x ≃ w⬝z :=
begin
  intro H,
  apply C_swap_right,
  apply C_swap_left,
  apply H,
end


-- Betweeness Axioms:
-- The only point on the line segment xx is itself
axiom B_id (x y : Point) : B x y x → x = y

-- Pasch's axiom
-- If uvxy is a quadrilateral then its diagonals must meet at a point "a".
axiom pasch (u v x y z : Point) :
  (B x u z) → (B y v z) → ∃ (a : Point), B u a y ∧ B v a x 

-- Defining the axiom schema
-- Phi and Psi are just some "properties"
axiom dedekind_cut (φ ψ : Point → Prop) :
    ∃ (a : Point), ∀ (x y : Point), φ x ∧ ψ y → B a x y
  → ∃ (b : Point), ∀ (x y : Point), φ x ∧ ψ y → B x b y
--  a--------x-------y  (this is the hypothesis)
--  Then we can find a point b such that
--  a--------x---b---y

-- This means our geometry has more than 1 dimension
axiom plane_geom1 : ∃ (a b c : Point),
  (¬ B a b c) ∧ (¬ B b a a) ∧ (¬ B c a b)

-- This means our geometry has less than 3 dimensions
axiom plane_geom2 (u v x y z : Point) :
  (x⬝u ≃ x⬝v) → (y⬝u ≃ z⬝v) → (z⬝u ≃ z⬝v) → (u ≠ v)
  → (B x y z) ∨ (B y z x) ∨ (B z x y)


-- # Axioms of Euclid
---------------------
axiom euclid_a (u v w x y z : Point) :
     B x y w → x⬝y ≃ y⬝w
  → B x u v → x⬝u ≃ u⬝v
  → B y u z → y⬝u ≃ z⬝u
  → y⬝z ≃ v⬝w



lemma euclid_b (x y z : Point) :
  (B x y z) ∨ (B y z x) ∨ (B z x y) ∨ (∃ a : Point, (x⬝a ≃ y⬝a) ∧ (x⬝a ≃ z⬝a)) :=
begin
  have euclid_a := euclid_a,
  right,
  right,
  right,
  tidy,
   { exact x},
   { apply euclid_a, tidy, repeat {sorry}},
   { apply euclid_a, tidy, repeat {sorry}},
end


-- We need to prove Euclid variant C starting with varint B
lemma euclid_c (u v x y z : Point) :
  B x u v → B y u z →  x ≠ u
  → ∃ (a b : Point), (B x y a ∧ B x z b ∧ B a v b) :=
begin
  have euclid_b, from euclid_b,
  sorry
end



-- Axiom of five segments
axiom five_segments (x y z u x' y' z' u' : Point) :
  (x ≠ y) → (B x y z) → (B x' y' z')
  → (x⬝y ≃ x'⬝y') → (y⬝z ≃ y'⬝z') → (x⬝u ≃ x'⬝u') → (y⬝u ≃ y'⬝u')
  → (z⬝u ≃ z'⬝u')


-- Axiom of segment construction
axiom segment_construct (x y a b : Point) :
  ∃ z : Point, (B x y z) ∧ (y⬝z ≃ a⬝b)


-- More results:
@[refl] lemma B_refl (x y : Point) : B x x y :=
  by fapply B_includes_end1


@[symm] lemma B_symm (x y z : Point) : B x y z → B z y x := 
begin
   intro H,
   hint,
    sorry,
end



@[trans] lemma B_trans (w x y z : Point) : B x y w → B y z w → B x y z :=
begin
   intros hp hq,
   sorry,
end

lemma B_connect (w x y z : Point) : B x y w → B x z w → B x y z ∨ B x z y :=
sorry

-- TODO: Need to figure out how Bxyz can translate to a total order?
-- lemma total_order_segment : is_total B :=  sorry

lemma zero_segments_are_congruent (y v : Point) : y⬝y ≃ v⬝v :=
begin
  have h := segment_construct v y v y,
  choose x h using h,
  cases h with h₁ h₂,
  have h₃ : v⬝y ≃ y⬝x,
    {exact C_symm (y⬝x) (v⬝y) h₂},
  fapply euclid_a,
  use y,
  use x,
    repeat {solve_by_elim},
    repeat {refl},
end

-- TFAE is short for "the following are equivalent"
-- The usual strategy to prove such results is to prove a cycle:
-- Either show 1 → 2 → 3 → 1, or show 1 → 3 → 2 → 1.
theorem extend_identity (x y z : Point): tfae [(x⬝y ≃ z⬝z), (x=y), (B x y x)] :=
begin
  tfae_have: 1 → 2,
    apply C_iden,
  tfae_have: 2 → 3,
    intro H,
    rw H,
    fapply B_includes_end1,
  tfae_have: 3 → 2,
    apply B_id,
  tfae_have: 2 → 1,
    intro H,
    rw H,
    fapply zero_segments_are_congruent,
  tfae_finish,
end
