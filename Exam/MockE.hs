{-# LANGUAGE FlexibleInstances #-}
module MockE where

import Lecture11
import Lecture10


{- IMPORTANT NOTE:

  These solutions are provided to aid you in studying and as guidance. In the
  exam clear, complete answers have to be provided, with justification and
  explicit explanation wherever necessary.
-}


-- 1. Vector space over R

-- * i.   Type class for vector spaces
class Vector a where
  zero  :: a

  plus  :: a -> a -> a
  scale :: Double -> a -> a
  plusInv :: a -> a
  plusInv = scale (-1)


-- * ii.  The language of vector space expressions as a datatype
data VecExpr v =
      Zero
    | Plus (VecExpr v) (VecExpr v)
    | Scale (RExpr v) (VecExpr v)
    | Vec v
  deriving (Eq, Show)

data RExpr v =
      D Double
    | V v
  deriving (Eq, Show)

-- Note: we accidentally skipped the instantiation of the expression language as
-- a type of class 'Vector'
instance Vector (VecExpr v) where
  zero  = Zero
  plus  = Plus
  scale t = Scale (D t)


-- *iii.  Another two instances

-- 3D vector space of components of type such that we can operate with 'Double'
-- values with them (easily)
type Vc a = (a, a, a)

repeatVc :: a -> Vc a
repeatVc u = (u, u, u)

mapVc :: (a -> b) -> Vc a -> Vc b
mapVc f (v1, v2, v3) = (f v1, f v2, f v3)

zipVcWith :: (a -> b -> c) -> Vc a -> Vc b -> Vc c
zipVcWith f (v1, v2, v3) (w1, w2, w3) = (f v1 w1, f v2 w2, f v3 w3)

instance Fractional a => Vector (Vc a) where
  zero  = repeatVc 0
  plus  = zipVcWith (+)
  scale = mapVc . (*) . fromRational . toRational

-- Functions with a vector space codomain form a vector space
instance Vector a => Vector (x -> a) where
  zero      = const zero
  plus f g  = \a -> f a `plus` g a
  scale x f = \a -> x `scale` f a

-- The positive fragment of real numbers (including 0) forms a vector space
-- OBS! Check the operations under which they do!
newtype RPlus = RP Double
  deriving Show

instance Vector RPlus where
  zero = RP 1
  plus  (RP x) (RP y)
    | x < 0 || y < 0 = error "plus: arguments are not positive reals!"
    | otherwise      = RP $ x * y
  scale t (RP x)
    | x < 0          = error "scale: arguments are not positive reals!"
    | otherwise      = RP $ x ** t

-- Others:
-- * Polynomials of finite degree (but arbitrarily large, all together)
-- * Matrices


-- * iv. General evaluator
-- Two assignment functions: one for scalar ('Double') variables, the second for
-- vector variables
evalV :: Vector a => (v -> Double) -> (v -> a) -> VecExpr v -> a
evalV _ _  Zero         = zero
evalV f g (Plus v1 v2)  = plus (evalV f g v1) (evalV f g v2)
evalV f g (Scale t v)   = scale (look t) (evalV f g v)
  where look (D u) = u
        look (V ß) = f ß
evalV f g (Vec v)       = g v


-- * v. Specialise evaluator and example expressions
evalL :: Fractional a => (v -> Double) -> (v -> Vc a) -> VecExpr v -> Vc a
evalL = evalV

evalF :: Vector a => (v -> Double) -> (v -> (x -> a)) -> VecExpr v -> x -> a
evalF = evalV

evalRP :: (v -> Double) -> (v -> RPlus) -> VecExpr v -> RPlus
evalRP = evalV

-- Machinery necessary to give the assignments
type Env v d = [(v,d)]

lookUp :: Eq v => Env v r -> v -> r
lookUp ((y,v) : rest) x | x == y    = v
                        | otherwise = lookUp rest x

type Var = String

examples :: [ VecExpr Var ]
examples = [ Plus (Scale ß (Plus w Zero)) (Plus w (Scale (D 1) u))
           , Scale µ (Plus v (Plus v (Scale x v)))
           , Scale (D (-1.9)) (Scale ß (plusInv v)) ]
  where ß = V "ß"
        µ = V "µ"
        x = V "x"
        u = Vec "u"
        v = Vec "v"
        w = Vec "w"

td = [ ("ß", -2), ("µ", -1.09), ("x", 8.1) ]
t1 = [ ("u", (11, -(exp 1), 0)), ("v", (0.2, 4, -3.2)), ("w", (0, 1.1, 3.4)) ]
t2 = [ ("u", const 3.2), ("v", (^2) . (-1)), ("w", (*2) . (+5.5)) ]
t3 = [ ("u", RP 2.3), ("v", RP 0), ("w", RP 3.4) ]

instance Vector Double where
  zero = 0
  plus = (+)
  scale = (*)



-- 2. Differential equations

-- The given equation and conditions are:
--    f'' t - 2 f' t + f t - 2 = 3 e^2t , f 0 = 5 , f' 0 = 6


-- * i. Compute the first 3 coefficients of the power series fs via functions
--      'integ' and 'deriv'.

-- What we need to compute these coefficients is the following computation,
-- where fs is the power series for f and as the power series for f'
as = integ (2 * as - fs + 2 + 3*expx2) 6
  -- we integrate the second derivative, obtained from the original equation
fs = integ as 5
  -- we integrate the first derivative

{- Note that additionally we need the power series for the term with the
  exponential function.
  Since
    f = e^2t  <==> f' t = 2 * f t  and  f 0 = 1
  the corresponding power series may be computed by:    -}
expx2 = integ (2 * expx2) 1

{- Now we have defined our solution, let's compute the actual coefficients:

  Let's denote the expression for second derivative's power series with
    h = 2 * (deriv fs) - fs + Single 2 + 3 * expx2

  First, we have

    fs = integ (deriv fs) 5

==> { def integ }

    fs = Cons 5 (...)  ==>  f0 = 5


  Next, given the relation between the power series for f and f', we have
    as = deriv fs
  hence
    deriv fs = integ h 6

==> { def integ }

    deriv fs = Cons 6 (integ' h 1)                  (1)

==> { def deriv (check Lecture 11 for details) }

    f1 = a0 = 6


  We now integrate h, but first, we compute its leading coefficient, by
  expressing its power series (note we have power series expressions for all of
  the terms the second derivative is defined with).

    deriv fs  = deriv (Cons f0 (Cons f1 (...))) = Cons f1 (...)
    fs        = Cons f0 (...)
    expx2     = integ (2 * expx2) 1 = Cons 1 (...)

  And hence the power series for second derivative has leading coefficient:
    h =
        2 * Cons f1 (...)
      - Cons f0 (...)
      + Single 2
      + 3 * Cons 1 (...)
    = Cons (2 * f1 - f0 + 2 + 3) (...) = Cons 12 (...)

==> { considering equation (1) and by definition of integ' }

    integ' (Cons 12 (...)) 1 = Cons (12/1) (...)

==> { def deriv }

      2 * f2 = a1 = 12  ==>  f2 = 6


So overall, the first three coefficients are:
  f0 = 5 , f1 = 6 , f2 = 6
-}


{- Of course, we could use our knowledge about the relationship between the
  power series for a function and its Taylor or Maclaurin series to check our
  solution ensuring we did all computations correctly:
    ƒ k 0 = fact k * a k
  where
    ƒ k = f^(k)
    a k is the k-th coefficient of the power series such that
        fs = eval . map a [0, 1, .. ]

  With this, we would immediately have:
    a 0 = 5
    a 1 = 6
  and the third coefficient would be immediate to compute,
    f'' 0 = 2 f' 0 - f 0 + 2 + 3 e^0 = 2 * 6 - 5 + 2 + 3 = 12
    a 2 = f'' 0 / fact 2 = 12 / 2 = 6
-}



-- * ii.  Solving the equation using the Laplace transform

{- For convenience, let's denote the Laplace transform simply by L
  Applying the Laplace transform to both sides of the equation (to the function
  corresponding to each side):
    L f'' s - L ((2 *) . f') s + L f s - L 2 s = L ((3*) . e . (*2)) s

    <==> { linearity of L }

    L f'' s - 2 * L f' s + L f s - 2 * L 1 s = 3 * L (e . (*2)) s

    <==> { relations between L of derivatives of a function and L of the
           function itself, summarised by the equation:
            L f^(k) s = s^k * L f s - sum_{j=0}^{k-1} (s^(k - j -1) * f^(j) 0) }

    s^2 * L f s - s * f 0 - f' 0 - 2 * (s * L f s - f 0) + L f s - 2 * L 1 s
      = 3 * L (e . (*2)) s

    <==> { aggregate terms }

    (s^2 - 2 * s + 1) * L f s - s * f 0 - (f' 0 - 2 * f 0) - 2 * L 1 s
      = 3 * L (e . (*2)) s

    <==> { f 0 = 5 , f' 0 = 6 }

    (s^2 - 2 * s + 1) * L f s - 5 * s + 4 - 2 * L 1 s = 3 * L (e . (*2)) s

    <==> { apply the given equation: L (e . (*ß)) s = 1 / (s - ß)
           to rhs but also to  L 1 s  since 1 = e^0 }

    (s^2 - 2 * s + 1) * L f s - 5 * s + 4 - 2 / s = 3 / (s - 2)

    <==> { solve for L f s  ;   s^2 - 2 * s + 1 = (s - 1)^2 }

    L f s =
      3 / (s - 2) + 2 / s - 4 + 5 * s
      -------------------------------
                (s - 1)^2

      3 * s + 2 * (s - 2) - 4 * s * (s - 2) + 5 * s^2 * (s - 2)
    = ---------------------------------------------------------
                    s * (s - 2) * (s - 1)^2

      5 * s^3 - 14 * s^2 + 13 * s - 4
    = -------------------------------
          s * (s - 2) * (s - 1)^2

  And then, just solve as in the example in the lecture notes:
    from  L f s = F s  recover f by considering F a sum of functions with known
    inverse transforms.

  L f s = F s = A / s + B / (s - 2) + C / (s - 1) + D / (s - 1)^2

  ==> { multiply by F's denominator }

  5 * s^3 - 14 * s^2 + 13 * s - 4
    = A * (s - 2) * (s - 1)^2 + B * s * (s - 1)^2 + C * s * (s - 2) * (s - 1)
      + D * s * (s - 2)

  In this case this must hold for values s > 2 (conjunction of all the
  denominator-imposed domain restrictions). But we check at the zeroes of the
  denominator.

  a) s = 0:  A * (-2) * (-1)^2 = -4   =>  A = 2

  b) s = 2:  B * 2 * 1^2 = 40 - 56 + 26 - 4 = 6  =>  B = 3

  c) s = 1:  D * 1 * (-1) = 5 - 14 + 13 - 4 = 0  =>  D = 0

  d) s = 3:  2 * 4 + 3 * 3 * 4 + C * 3 * 2 = 44  =>  6 * C = (44 - 44) = 0
    * one last value to determine the last constant

  So we arrive at
    F s = 2 / s + 3 / (s - 2)
  and hence, given the equation about the inverse Laplace transform of
  exponentials:
    f t = 2 + 3 * e^(2 * t)

  Let us check the original equation:
    f'  t =  6 * e^(2 * t)
    f'' t = 12 * e^(2 * t)

  ==>
    f'' t - 2 f' t + f t - 2 = 3 e^2t , f 0 = 5 , f' 0 = 6

  ==> { denote  h = 3 * e^(2 * t) }
    
    12 * h - 2 * 6 h + 2 + 3 * h - 2 = 3 * h

  The equation holds, and we have correctly solved the problem with:
    f t = 2 + 3 * e^(2 * t)
-}
