import .euclid
import tactic


-- Redo the local notation
--------------------------
local infix ` ≃ `:55 := congruent  -- typed as \ equiv
local infix `⬝`:56 := Segment.mk  -- typed as \ cdot


-- Lemma needed for Proposition 1
lemma hypothesis1_about_circles_radius (s : Segment) :
  let c₁ : Circle := ⟨s.p1, s.p2⟩ in
  let c₂ : Circle := ⟨s.p2, s.p1⟩ in
  radius c₁ + radius c₂ >= distance c₁.center c₂.center :=
begin
  intros,
  show distance s.p1 s.p2 ≤ radius c₁ + radius c₂,
    calc distance s.p1 s.p2 ≤ distance s.p1 s.p2 + distance s.p1 s.p2
                                              : by {simp, apply distance_not_neg}
         ... = radius c₁ + distance s.p1 s.p2 : by refl
         ... = radius c₁ + distance s.p2 s.p1 : by simp
         ... = radius c₁ + radius c₂ : by refl,
end


-- Another lemma needed for Proposition 1
lemma hypothesis2_about_circles_radius (s : Segment) :
  let c₁ : Circle := ⟨s.p1, s.p2⟩ in
  let c₂ : Circle := ⟨s.p2, s.p1⟩ in
  abs (radius c₁ - radius c₂) <= distance c₁.center c₂.center :=
  begin
    intros,
    show abs (radius c₁ - radius c₂) ≤ distance s.p1 s.p2,
    calc abs (radius c₁ - radius c₂) = abs (distance s.p1 s.p2 - radius c₂) : by refl
         ... = abs (distance s.p1 s.p2 - distance s.p2 s.p1) : by refl
         ... = abs (distance s.p1 s.p2 - distance s.p1 s.p2) : by simp
         ... = 0 : by simp
         ... ≤ distance s.p1 s.p2 : by apply distance_not_neg,
  end


-- # Proposition 1
------------------
lemma construct_equilateral (s : Segment) : ∃ (tri: Triangle),
  s.p1 = tri.p1 ∧ s.p2 = tri.p2 ∧ is_equilateral tri :=
begin
  set c₁ : Circle := ⟨s.p1, s.p2⟩,
  set c₂ : Circle := ⟨s.p2, s.p1⟩,
  have h₁ := (hypothesis1_about_circles_radius s),
  have h₂ := hypothesis2_about_circles_radius s,
  set p : Point := circles_intersect c₁ c₂ h₁ h₂,
  have hp₁ : p ∈ circumference c₁, from (circles_intersect' c₁ c₂ h₁ h₂).1,
  have hp₂ : p ∈ circumference c₂, from (circles_intersect' c₁ c₂ h₁ h₂).2,
  use ⟨s.p1, s.p2, p⟩,
  --- Cleaning up the context ---
    tidy;
    unfold circumference radius_segment at hp₁ hp₂;
    unfold sides_of_triangle;
    dsimp * at *,
  --- Cleaning done ---
    {calc s.p1 ⬝ s.p2 ≃ s.p2 ⬝ s.p1 : by symmetry
                  ... ≃ s.p2 ⬝ p    : by assumption},
    {calc s.p2 ⬝ p ≃ s.p2 ⬝ s.p1 : by {apply cong_symm, assumption}
               ... ≃ s.p1 ⬝ s.p2 : by apply segment_symm
               ... ≃ s.p1 ⬝ p    : by assumption
               ... ≃    p ⬝ s.p1 : by symmetry},
end



lemma ray_cut_length (r : Ray) (s : Segment) (h : r.base ≠ r.ext)
  : ∃ p : Point, p ∈ points_of_ray r h ∧ r.base ⬝ p ≃ s :=
begin
  sorry
end



-- lemma ray_circle_intersect (AB : Ray) (ne : AB.base ≠ AB.ext) (C : Circle) (center : C.center = AB.base): 
-- ∃ (p : Point), (p ∈ circumference C) ∧ (p ∈ points_of_ray AB ne) :=
-- begin
-- have h := extend (Segment.mk AB.base AB.ext Segment.mk AB.ext ) CD? ne,
-- end
-- Lemma needed for proposition 2
lemma ray_circle_intersect (AB : Ray) (ne : AB.base ≠ AB.ext) (C : Circle) (p : Point) :
  circle_interior p C
  → p ∈ points_of_ray AB ne
  → ∃ x : Point, x ∈ points_of_ray AB ne ∧ x ∈ circumference C :=
begin
  sorry,
end

-- Use *have* for introducing new facts. Follow it up with a proof of
-- said fact.
-- have x_pos : x > 0, .....

-- Use *let* for introducing new terms (of a given type). Follow it up
-- with a definition of the term.
-- Ex: let x : ℕ := 5

-- Use *set* is similar to *let*, but it additionally replaces every term
-- in the context with the new definition.
-- Ex: set x : ℕ := 5, -> replace x with 5 everywhere

-- Lemma needed for Proposition 2
lemma equilateral_triangle_nonzero_side_1 (abc : Triangle) :
  abc.p1 ≠ abc.p2 → is_equilateral abc
  → abc.p2 ≠ abc.p3 :=
begin
  intros ne_a_b h,
  unfold is_equilateral at h,
  rcases h with ⟨h₁, h₂⟩,
  intros eq_b_c,
  have cong_cc_bc : abc.p3⬝abc.p3 = abc.p2⬝abc.p3, by simp[eq_b_c],
  have eq_a_b : abc.p1 = abc.p2,
    { apply zero_segment (abc.p1 ⬝ abc.p2) abc.p3,
      rw cong_cc_bc,
      assumption},
  exact ne_a_b eq_a_b,
end

lemma equilateral_triangle_nonzero_side_2 (abc : Triangle) :
  abc.p1 ≠ abc.p2 → is_equilateral abc
  → abc.p3 ≠ abc.p1 :=
begin
  intros ne_a_b h,
  unfold is_equilateral at h,
  rcases h with ⟨h₁, h₂⟩,
  set sides := sides_of_triangle abc,
  have h₃ := cong_trans sides.1 sides.2.1 sides.2.2 h₁ h₂,
  have eq_1_3 : abc.p1 ⬝ abc.p3 ≃ abc.p3 ⬝ abc.p1, {
      apply seg_symm,
  },
  intros eq_b_c,
  have cong_cc_bc : abc.p3⬝abc.p3 = abc.p1⬝abc.p3, by simp[eq_b_c],
  have eq_a_b : abc.p1 = abc.p2,
    { apply zero_segment (abc.p1 ⬝ abc.p2) abc.p3,
      rw cong_cc_bc,
      let a := abc.p1 ⬝ abc.p2,
      let b := abc.p3 ⬝ abc.p1,
      let c := abc.p1 ⬝ abc.p3,
      have a_cong : a ≃ b, tidy,
      have b_cong : b ≃ c, apply seg_symm,
      have abc_trans : a ≃ c, {
        apply cong_trans a b c a_cong b_cong,
      },
      apply abc_trans,
    },
  exact ne_a_b eq_a_b,
end

lemma radius_non_zero (c : Circle) :
  c.center ≠ c.outer → 0 < radius c :=
begin
  intro,
  unfold radius,
  simp,
  unfold radius_segment,
  simp,
  apply distance_pos,
  apply a,
end

lemma radii_equal (c : Circle) (a b : Point) :
a ∈ circumference c → b ∈ circumference c → c.center ⬝ a ≃ c.center ⬝ b :=
begin
  intros h₁ h₂,
  have eq_a_rad : c.center ⬝ a ≃ radius_segment c, {
    unfold circumference at h₁,
    simp at h₁,
    apply cong_symm,
    exact h₁,
  },
  have eq_b_rad : radius_segment c ≃ c.center ⬝ b, {
    tidy,
  }, 
  apply cong_trans (c.center ⬝ a) (radius_segment c) (c.center ⬝ b) eq_a_rad eq_b_rad,
end


--Proposition 2
lemma placeline (bc : Segment) (a : Point) :
     a ≠ bc.p1
  → bc.p1 ≠ bc.p2
  → ∃ (s : Segment), (a = s.p1) ∧ bc ≃ s :=
begin
  intros ne_a_b ne_b_c,
  set ab : Segment := a⬝bc.p1,
  choose abd h using construct_equilateral ab,
  rcases h with ⟨h₁, h₂, h₃⟩,
  set da : Ray := ⟨abd.p3, a⟩,
  set db : Ray := ⟨abd.p3, ab.p2⟩,
  set circ : Circle := ⟨bc.p1, bc.p2⟩,
  have ne_d_b : db.base ≠ db.ext,
  { have x : db.base = abd.p3, by refl,
    have y : db.ext = abd.p2, by tidy,
    symmetry,
    rw [x, y],
    apply equilateral_triangle_nonzero_side_1,
    have eq_aa : abd.p1 = a, {rw h₁},
    have eq_bb : abd.p2 = bc.p1, {rw h₂},
    rw eq_aa,
    rw eq_bb,
    exact ne_a_b,
    exact h₃,
  },
  have ne_d_a : da.base ≠ da.ext,
    { have x : da.base = abd.p3, by refl,
      have y : da.ext = abd.p1, by tidy,
      have ne : abd.p1 ≠ abd.p2, {
        finish,
      },
      symmetry,
      apply ne_symm,
      rw [x, y],
      apply equilateral_triangle_nonzero_side_2 abd ne,
      assumption,
  },
  have b_in_circ : circle_interior bc.p1 circ,
    { simp [circle_interior, radius],
      apply distance_pos,
      exact ne_b_c},
  
  have b_in_bc : db.ext ∈ points_of_ray db ne_d_b, {
    sorry,
  },
  have ray_circle_intersect := ray_circle_intersect db ne_d_b circ bc.p1 b_in_circ b_in_bc,
  rcases ray_circle_intersect with ⟨g, g_in_ray,g_in_circum⟩,
  let c₁ : Circle := ⟨abd.p3, g⟩,
  have ne_d_g : abd.p3 ≠ g, {
    sorry,
  },
  have d_in_c₁ : circle_interior abd.p3 c₁, {
    unfold circle_interior,
    have center_eq : c₁.center = abd.p3, {refl,},
    have dist_0 : distance c₁.center abd.p3 = 0, {
      finish,
    },
    rw dist_0,
    apply radius_non_zero,
    apply ne_d_g,
  },
  have d_in_da : da.base ∈ points_of_ray da ne_d_a, {
    sorry,
  },
  have ray_circle_intersect2 := ray_circle_intersect da ne_d_a c₁ abd.p3 d_in_c₁ d_in_da,
  rcases ray_circle_intersect2 with ⟨l, l_in_ray, l_in_circum⟩,
  have bc_eq_bg : distance bc.p1 g = distance bc.p1 bc.p2, {
    sorry,
  },
  have al_eq_bg : distance a l = distance bc.p1 bc.p2 :=
  begin sorry, end,
  let al := a ⬝ l,
  let dl := da.base ⬝ l,
  let dg := da.base ⬝ g,
  let bg := bc.p1 ⬝ g,
  have dl_eq_dg : dl ≃ dg, {
  let circum := circumference c₁,
    let rad := radius_segment c₁,
    have dl_eq_rad : rad ≃ dl, {tidy},
    have dg_eq_rad : dg ≃ rad, {tidy},
    have pls_work_trans := cong_trans dg rad dl dg_eq_rad dl_eq_rad,
    apply cong_symm,
    apply pls_work_trans,
  },
  have bc_eq_bg : bc ≃ bg, {
    let circum := circumference circ,
    let rad := radius_segment circ,
    have dl_eq_rad : rad ≃ bc, {tidy},
    have dg_eq_rad : dg ≃ rad, {tidy},
    have pls_work_trans := cong_trans bg rad dl dg_eq_rad dl_eq_rad,
    apply cong_symm,
    apply pls_work_trans,
  },
  have cong_bg_al : bg ≃ al, {
    sorry,
  },
  use al,
  simp,
  apply cong_trans bc bg al cong_bc_bg cong_bg_al,
end

-- # Proposition 3
lemma prop3 (AB C : Segment) (greater : length AB > length C):
  ∃ (s : Segment), (length s = length C) ∧ (s.p1 = AB.p1) ∧ (between AB.p1 s.p2 AB.p2) :=
begin
  sorry
end

-- # Proposition 4
------------------
-- If two triangles have two sides equal to two sides respectively,
-- and have the angles contained by the equal straight lines equal,
-- then they also have the base equal to the base, the triangle equals
-- the triangle, and the remaining angles equal the remaining angles
-- respectively, namely those opposite the equal sides.
-- SAS congruency.
lemma prop4 (t1 t2 : Triangle) (dif1 : distinct t1.p1 t1.p2 t1.p3) (dif2 : distinct t2.p1 t2.p2 t2.p3):
  let sides1 := (sides_of_triangle t1) in
  let sides2 := (sides_of_triangle t2) in
  let angles1 := (angles_of_triangle t1 dif1) in
  let angles2 := (angles_of_triangle t2 dif2) in
     (sides1.1 = sides2.1)
  → (sides1.2.1 = sides2.2.1)
  → (angles1.1 ≃ angles2.1)
  → (sides1.2.2 = sides2.2.2)
     ∧ (angles1.nth 1 = angles2.nth 1) ∧ (angles1.nth 2 = angles2.nth 2) :=
begin
  sorry
end



-- # Proposition 5
-- # Proposition 7
-- # Proposition 8
-- # Proposition 10
-- # Proposition 11
-- # Proposition 13
-- # Proposition 14
-- # Proposition 15
-- # Proposition 16
-- # Proposition 18
-- # Proposition 19
-- # Proposition 20
-- # Proposition 22
-- # Proposition 26
-- # Proposition 29
-- # Proposition 31
-- # Proposition 34
-- # Proposition 37
-- # Proposition 41
-- # Proposition 46
-- # Proposition 47
-- # Proposition 48
