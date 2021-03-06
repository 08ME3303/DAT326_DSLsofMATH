\section{Polynomials and Power Series}
\label{sec:poly}
\begin{code}
{-# LANGUAGE TypeSynonymInstances #-}
module DSLsofMath.W05 where
import DSLsofMath.FunNumInst
\end{code}

\subsection{Polynomials}

From \cite{adams2010calculus}, page 39:

\begin{quote}
A \textbf{polynomial} is a function $P$ whose value at $x$ is

\[P(x) = a_n x^n + a_{n-1} x^{n - 1} + \cdots + a_1 x + a_0\]

where $a_n$, $a_{n-1}$, \ldots, $a_1$, and $a_0$, called the
\textbf{coefficients} of the polymonial [misspelled in the book], are
constants and, if $n > 0$, then $a_n ≠ 0$.
%
The number $n$, the degree of the highest power of $x$ in the
polynomial, is called the \textbf{degree} of the polynomial.
%
(The degree of the zero polynomial is not defined.)
\end{quote}

This definition raises a number of questions, for example ``what is
the zero polynomial?''.

The types of the elements involved in the definition appear to be

\begin{quote}
  $n ∈ ℕ$, $P : ℝ → ℝ$, $x ∈ ℝ$, $a_0$, \ldots, $a_n ∈ ℝ$ with $a_n ≠ 0$ if $n > 0$
\end{quote}

The phrasing should be ``whose value at \emph{any} $x$ is''.
%
The remark that the $a_i$ are constants is probably meant to indicate
that they do not depend on $x$, otherwise every function would be a
polynomial.
%
The zero polynomial is, according to this definition, the |const 0|
function.
%
Thus, what is meant is

\begin{quote}
  A \textbf{polynomial} is a function $P : ℝ → ℝ$ which is either
  constant zero, or there exist $a_0$, \ldots, $a_n$ ∈ ℝ with $a_n ≠ 0$
  such that, for any $x ∈ ℝ$

  \[P(x) = a_n x^n + a_{n-1} x^{n - 1} + \cdots + a_1 x + a_0\]
\end{quote}

Given the coefficients $a_i$ we can evaluate $P$ at any given $x$.
%
Assuming the coefficients are given as

\begin{spec}
as = [a0, a1, ..., an]
\end{spec}
%
(we prefer counting up), then the evaluation function is written
%
\begin{spec}
evalL ::  [REAL] ->  REAL  ->  REAL
evalL     []         x     =   0
evalL     (a : as)   x     =   a + x * evalL as x
\end{spec}
%
Note that we can read the type as |evalL :: [REAL] -> (REAL -> REAL)|
and thus identify |[REAL]| as the type for the (abstract) syntax (for
polynomials) and |(REAL -> REAL)| as the type of the semantics (for
polynomial functions).
%
Exercise: Show that this evaluation function gives the same result as the formula above.

Using the |Num| instance for functions we can rewrite |eval| into
a one-argument function (returning a polynomial function):
%
\begin{code}
evalL :: Num a => [a] -> (a -> a)
evalL []      = const 0
evalL (a:as)  = const a  +  id * evalL as
\end{code}
%
As an example, the polynomial which is usually written just |x| is
represented by the list |[0, 1]| and the polynomial function |\x -> x^2-1| is
represented by the list |[-1,0,1]|.

It is worth noting that the definition of what we call a
``polynomial function'' is semantic, not syntactic.
%
A syntactic defintion would talk about the form of the expression (a
sum of coefficients times natural powers of x).
%
This semantic definition only requires that the function |P|
\emph{behaves like} such a sum.
%
(Has the same value for all |x|.)
%
This may seem pedantic, but here is an interesting example of a family
of functions which syntactically looks very trigonometric:
%
\[T_n(x) = \cos (n*\arccos(x))\ .\]
%
It can be shown that \(T_n\) is a polynomial function of degree |n|.
%
(Exercise~\ref{ex:chebyshev} guides you to a proof.
%
At this point you could just compute \(T_0\), \(T_1\), and \(T_2\) by
hand to get a feeling for how it works.
)

% TODO: perhaps talk about an alternative, recursive, definition of polynomial function, closer to the implementation of |eval| blackboard/W5/20170213_114415.jpg

Not every list of coefficients is valid according to the definition.
%
In particular, the empty list is not a valid list of coefficients, so
we have a conceptual, if not empirical, type error in our evaluator.

The valid lists are those \emph{finite} lists in the set

\begin{spec}
  {[0]} ∪ {(a : as) | last (a : as) ≠ 0}
\end{spec}

We cannot express the |last (a : as) ≠ 0| in Haskell, but we can
express the condition that the list should not be empty:

\begin{code}
data Poly a  =  Single a  |  Cons a (Poly a)
                deriving (Eq, Ord)
\end{code}

Note that if we drop the requirement of what constitutes a ``valid''
list of coefficients we can use |[a]| instead of |Poly a|.
%
Basically, we then use |[]| as the syntax for the ``zero polynomial''
and |(c:cs)| for all non-zero polynomials.

The relationship between |Poly a| and |[a]| is given by the following
functions:

\begin{code}
toList :: Poly a   ->  [a]
toList (Single a)   =  a : []
toList (Cons a as)  =  a : toList as

fromList :: Num a => [a]  ->  Poly a
fromList (a : [])         =  Single a
fromList (a0 : a1 : as)   =  Cons a0 (fromList (a1 : as))
fromList []               =  Single 0  -- to complete the pattern match

instance Show a => Show (Poly a) where
  show = show . toList
\end{code}

Since we only use the arithmetical operations, we can generalise our
evaluator:

\begin{code}
evalPoly :: Num a => Poly a -> (a -> a)
evalPoly (Single a)     x   =  a
evalPoly (Cons a as)    x   =  a + x * evalPoly as x
\end{code}

Since we have |Num a|, there is a |Num| structure on |a -> a|, and
|evalPoly| looks like a homomorphism.
%
Question: is there a |Num| structure on |Poly a|, such that |evalPoly|
is a homomorphism?

For example, the homomorphism condition gives for |(+)|
%
\begin{spec}
evalPoly as + evalPoly bs = evalPoly (as + bs)
\end{spec}

Both sides are functions, they are equal iff they are equal for every
argument.
%
For an arbitrary |x|

%
\begin{spec}
  (evalPoly as + evalPoly bs) x = evalPoly (as + bs) x

<=> {- |+| on functions is defined point-wise -}

  evalPoly as x + evalPoly bs x = evalPoly (as + bs) x
\end{spec}

To proceed further, we need to consider the various cases in the
definition of |evalPoly|.
%
We give here the computation for the last case (where |as| has at
least one |Cons|), using the traditional list notation |(:)| for
brevity.
%

\begin{spec}
evalPoly (a : as) x  +  evalPoly (b : bs) x  =  evalPoly ((a : as)  +  (b : bs)) x
\end{spec}

For the left-hand side, we have:
%
\begin{spec}
  evalPoly (a : as) x  +  evalPoly (b : bs) x      =  {- def. |evalPoly| -}

  (a + x * evalPoly as x) + (b + x * eval bs x)    =  {- properties of |+|, valid in any ring -}

  (a + b) + x * (evalPoly as x + evalPoly bs x)    =  {- homomorphism condition -}

  (a + b) + x * (evalPoly (as + bs) x)             =  {- def. |evalPoly| -}

  evalPoly ((a + b) : (as + bs)) x
\end{spec}

The homomorphism condition will hold for every |x| if we define
%
\begin{spec}
  (a : as) + (b : bs)  = (a + b) : (as + bs)
\end{spec}
%
This is definition looks natural (we could probably have guessed it
early on) but it is still interesting to see that we can derive the
definition as the the form it has to take for the proof to go through.

We leave the derivation of the other cases and operations as an
exercise.
%
Here, we just give the corresponding definitions.
%
\begin{code}
instance Num a => Num (Poly a) where
  (+) = polyAdd
  (*) = polyMul

  negate = polyNeg

  fromInteger =  Single . fromInteger

polyAdd :: Num a => Poly a -> Poly a -> Poly a
polyAdd (Single a )  (Single b )  =  Single (a + b)
polyAdd (Single a )  (Cons b bs)  =  Cons (a + b) bs
polyAdd (Cons a as)  (Single b )  =  Cons (a + b) as
polyAdd (Cons a as)  (Cons b bs)  =  Cons (a + b) (polyAdd as bs)

polyMul :: Num a => Poly a -> Poly a -> Poly a
polyMul (Single a )  (Single b )  =  Single (a * b)
polyMul (Single a )  (Cons b bs)  =  Cons (a * b) (polyMul (Single a) bs)
polyMul (Cons a as)  (Single b )  =  Cons (a * b) (polyMul as (Single b))
polyMul (Cons a as)  (Cons b bs)  =  Cons (a * b) (polyAdd  (polyMul as (Cons b bs))
                                                            (polyMul (Single a) bs)  )
polyNeg :: Num a => Poly a -> Poly a
polyNeg = mapPoly negate

mapPoly :: (a->b) -> (Poly a -> Poly b)
mapPoly f (Single a)   = Single (f a)
mapPoly f (Cons a as)  = Cons (f a) (mapPoly f as)
\end{code}
%
Therefore, we \emph{can} define a ring structure (the mathematical
counterpart of |Num|) on |Poly a|, and we have arrived at the
canonical definition of polynomials, as found in any algebra book
(see, for example, \cite{rotman2006first} for a very readable text):

\begin{quote}
  Given a commutative ring |A|, the commutative ring given by the set
  |Poly A| together with the operations defined above is the ring of
  \textbf{polynomials} with coefficients in |A|.
\end{quote}

%
The functions |evalPoly as| are known as \emph{polynomial functions}.

\textbf{Caveat:} The canonical representation of polynomials in
algebra does not use finite lists, but the equivalent

\begin{quote}
  \begin{spec}
    Poly' A = { a : ℕ → A | {- |a| has only a finite number of non-zero values -} }
  \end{spec}
\end{quote}

Exercise: what are the ring operations on |Poly' A|?  Note: they are different from the operation induced by the ring operations on |A|.

%
For example, here is addition:

\begin{spec}
  a + b = c  <=>  a n + b n = c n  --  |∀ n : ℕ|
\end{spec}

Remark:  Using functions in the definition has certain ``technical'' advantages over using finite lists.  For example, consider adding |[a0, a1, ..., an]| with |[b0, b1, ..., m]|, with |n > m|.  Then, we obtain a polynomial of degree |n|: |[c0, c1, ..., cn]|.  The formula for the |c_i| must now be given via a case distinction:

< ci = if i > m then ai else ai + bi

\noindent
since |bi| does not exist for values greater than |m|.

Compare this with the above formula for functions: no case distinction necessary.  The advantage is even clearer in the case of multiplication.

\textbf{Observations:}

\label{sec:polynotpolyfun}
\begin{enumerate}
\item Polynomials are not, in general, isomorphic (in one-to-one
  correspondence) with polynomial functions.
  %
  For any finite ring |A|, there is a finite number of functions |A ->
  A|, but there is a countable number of polynomials.
  %
  That means that the same polynomial function on |A| will be the
  evaluation of many different polynomials.

  For example, consider the ring |ℤ₂| (|{0, 1}| with addition and
  multiplication modulo |2|).
  %
  In this ring, we have that |p x = x+x^2| is actually a constant function.
  %
  The only two input values to |p| are |0| and |1| and we can easily
  check that |p 0 = 0| and also |p 1 = mod (1+1^2) 2 = mod 2 2 = 0|.
  %
  Thus
  \begin{spec}
    evalPoly [0, 1, 1] = p = const 0 = evalPoly [0]  {- in |ℤ₂ -> ℤ₂| -}
  \end{spec}

  but

  \begin{spec}
    [0, 1, 1] ≠ [0]  {- in |Poly ℤ₂| -}
  \end{spec}

  Therefore, it is not generally a good idea to confuse polynomials
  with polynomial functions.

\item In keeping with the DSL terminology, we can say that the
  polynomial functions are the semantics of the language of
  polynomials.
  %
  We started with polynomial functions, we wrote the evaluation
  function and realised that we have the makings of a homomorphism.
  %
  That suggested that we could create an adequate language for
  polynomial functions.
  %
  Indeed, this turns out to be the case; in so doing, we have
  recreated an important mathematical achievement: the algebraic
  definition of polynomials.

Let

\begin{code}
x :: Num a => Poly a
x = Cons 0 (Single 1)
\end{code}

Then (again, using the list notation for brevity) for any polynomial
|as = [a0, a1, ..., an]| we have

\begin{spec}
as = a0 + a1 * x + a2 * x^2 + ... + an * x^n
\end{spec}

Exercise: check this.

This justifies the standard notation

\[as = \sum_{i = 0}^n a_i * x^i\]

\end{enumerate}

\subsection{Aside: division and the degree of the zero polynomial}

Recall the fundamental property of division we learned in high school:

For all natural numbers |a|, |b|, with |b ≠ 0|, there there exist *unique* integers |q| and |r|, such that

< a = b * q + r, with r < b

When |r = 0|, |a| is divisible by |b|.  Questions of divisibility are essential in number theory and its applications (including cryptography).

A similar theorem holds for polynomials (see, for example, \cite{adams2010calculus} page 40):

For all polynomials |as|, |bs|, with |bs ≠ Single 0|, there there exist *unique* polynomials |qs| and |rs|, such that

< as = bs * qs + rs, with degree rs < degree bs

The condition |r < b| is replaced by |degree rs < degree bs|.  However, we now have a problem.  Every polynomial is divisible by any non-zero constant polynomial, resulting in a zero polynomial remainder.  But the degree of a constant polynomial is zero.  If the degree of the zero polynomial were a natural number, it would have to be smaller than zero.  For this reason, it is either considered undefined (as in \cite{adams2010calculus}), or it is defined as |-∞|.  The next section examines this question from a different point of view, that of homomorphisms.


\subsection{Polynomial degree as a homomorphism}

It is often the case that a certain function is \emph{almost} a
homomorphism and the domain or range \emph{almost} a monoid.
%
In the section on |eval| and |eval'| for |FunExp| we have seen
``tupling'' as one way to fix such a problem and here we will
introduce another way.

The |degree| of a polynomial is a good candidate for being a
homomorphism:
%
if we multiply two polynomials we can normally add their degrees.
%
If we try to check that |degree :: Poly a -> Nat| is the function
underlying a monoid morphism we need to decide on the monoid structure
to use for the source and for the target, and we need to check the
homomorphism laws.
%
We can use |unit = Single 1| and |op = polyMul| for the source monoid
and we can try to use |unit = 0| and |op = (+)| for the target monoid.
%
Then we need to check that
%
\begin{spec}
degree (Single 1) = 0
∀ x, y? degree (x `op` y) = degree x  +  degree y
\end{spec}
%
The first law is no problem and for most polynomials the second law is
also straighforward to prove (exercise: prove it).
%
But we run into trouble with one special case: the zero polynomial.

Looking back at the definition from \cite{adams2010calculus}, page 55
it says that the degree of the zero polynomial is not defined.
%
Let's see why that is the case and how we might ``fix'' it.
%
Assume there is a |z| such that |degree 0 = z| and that we have some
polynomial |p| with |degree p = n|.
%
Then we get
%
\begin{spec}
  z                               = {- assumption -}

  degree 0                        = {- simple calculation -}

  degree (0 * p)                  = {- homomorphism condition -}

  degree 0 + degree p             = {- assumption -}

  z + n
\end{spec}
%
Thus we need to find a |z| such that |z = z + n| for all natural
numbers |n|!
%
At this stage we could either give up, or think out of the box.
%
Intuitively we could try to use |z = -Infinity|, which would seem to
satisfy the law but which is not a natural number (not even an integer).
%
More formally what we need to do is to extend the monoid |(Nat,0,+)|
by one more element.
%
In Haskell we can do that using the |Maybe| type constructor:

%{
%format Monoid' = Monoid
\begin{code}
class Monoid' a where
  unit  :: a
  op    :: a -> a -> a

instance Monoid' a => Monoid' (Maybe a) where
  unit  = Just unit
  op    = opMaybe

opMaybe Nothing    m          = Nothing    -- |-Inf + m   = -Inf|
opMaybe m          Nothing    = Nothing    -- |m + (-Inf) = -Inf|
opMaybe (Just m1)  (Just m2)  = Just (op m1 m2)
\end{code}
%}

% TODO: perhaps mention another construction:
% We quote the Haskell prelude implementation:
% % https://hackage.haskell.org/package/base-4.9.1.0/docs/src/GHC.Base.html#line-314
% \begin{quote}
%   Lift a semigroup into |Maybe| forming a |Monoid| according to
%   \url{http://en.wikipedia.org/wiki/Monoid}: "Any semigroup |S| may be
%   turned into a monoid simply by adjoining an element |e| not in |S|
%   and defining |e*e = e| and |e*s = s = s*e| for all |s ∈ S|." Since
%   there is no |Semigroup| typeclass [..], we use |Monoid| instead.
% \end{quote}

Thus, to sum up, |degree| is a monoid homomorphism from |(Poly a, 1,
*)| to |(Maybe Nat, Just 0, opMaybe)|.

Exercise: check all the Monoid and homomorphism properties.

\subsection{Power Series}

Consider the following ``pseudo proof'':

\begin{theorem}[Fake theorem]
Let |m, n ∈ ℕ| and let |cs| and |as| be any polynomials of degree |m + n| and |n|, respectively, and with |a0 /= 0|.
%
Then |cs| is divisible by |as|.
\end{theorem}

\begin{proof}
We need to find |bs = [b0, ..., bm]| such that |cs = as * bs|.
%
From the multiplication of polynomials, we know that

< ck = {-"\sum_{i = 0}^k a_i * b_{k-i}"-}

Therefore:

< c0 = a0 * b0

Since |c0| and |a0| are known, computing |b0 = c0/a0| is trivial.
%
Next

< c1 = a0 * b1 + a1 * b0

Again, we are given |c1|, |a0| and |a1|, and we have just computed |b0|, therefore we can obtain |b1|.
%
Similarly

< c2 = a0 * b2 + a1 * b1 + a2 * b0

from which we obtain, exactly as before, the value of |b2|.

It is clear that this process can be continued, yielding at every step a value for a coefficient of |bs|, and thus we have obtained |bs| satisfying |cs = as * bs|.

\end{proof}

The problem with this ``proof'' is in the statement ``it is clear that this process can be continued''.
%
In fact, it is rather clear that it cannot (for polynomials)!
%
Indeed, |bs| only has |m+1| coefficients, therefore for all remaining |n| equations of the form |ck = {-"\sum_{i = 0}^k a_i * b_{k-i}"-}|, the values of |bk| have to be zero.
%
But in general this will not satisfy the equations.

However, we can now see that, if we were able to continue for ever, we would be able to divide |cs| by |as| exactly.
%
The only obstacle is the ``finite'' nature of our lists of coefficients.

Power series are obtained from polynomials by removing in |Poly'| the
restriction that there should be a \emph{finite} number of non-zero
coefficients; or, in, the case of |Poly|, by going from lists to
streams.

\begin{spec}
PowerSeries' a = { f : ℕ → a }
\end{spec}

\begin{code}
type PowerSeries a = Poly a   -- finite and infinite non-empty lists
\end{code}

The operations are still defined as before.
%
If we consider only infinite lists, then only the equations which do
not contain the patterns for singleton lists will apply.

Power series are usually denoted

\[   \sum_{n = 0}^{\infty} a_n * x^n   \]

the interpretation of |x| being the same as before.
%
The simplest operation, addition, can be illustrated as follows:
\[
\begin{array}{>{\displaystyle}lllll}
    \sum_{i = 0}^{\infty} a_i * x^i            &\cong  &[a_0,     &a_1,    &\ldots ]
\\  \sum_{i = 0}^{\infty} b_i * x^i            &\cong  &[b_0,     &b_1,    &\ldots ]
\\  \sum_{i = 0}^{\infty} (a_i+b_i) * x^i      &\cong  &[a_0+b_0, &a_1+b_1,&\ldots ]
\end{array}
\]


The evaluation of a power series represented by |a : ℕ → A| is defined,
in case the necessary operations make sense on |A|, as a function

\begin{spec}
eval a : A -> A
eval a x  =  lim s   where   s n = {-" \sum_{i = 0}^n a_i * x^i "-}
\end{spec}

Note that |eval a| is, in general, a partial function (the limit might
not exist).

We will consider, as is usual, only the case in which |A = ℝ| or |A =
ℂ|.

The term \emph{formal} refers to the independence of the definition of
power series from the ideas of convergence and evaluation.
%
In particular, two power series represented by |a| and |b|, respectively,
are equal only if |a = b| (as functions).
%
If |a ≠ b|, then the power series are different, even if |eval a =
eval b|.

Since we cannot in general compute limits, we can use an
``approximative'' |eval|, by evaluating the polynomial resulting from
an initial segment of the power series.

\begin{code}
eval :: Num a => Integer -> PowerSeries a -> (a -> a)
eval n as x = evalPoly (takePoly n as) x

takePoly :: Integer -> PowerSeries a -> Poly a
takePoly n (Single a)   =  Single a
takePoly n (Cons a as)  =  if n <= 1
                              then  Single a
                              else  Cons a (takePoly (n-1) as)
\end{code}
%TODO: perhaps explain with plain lists: |takeP :: Nat -> PS r -> P r| with |takeP n (PS as) = P (take n as)|
%
Note that |eval n| is not a homomorphism: for example:
%
\begin{spec}
  eval 2 (x*x) 1                     =
  evalPoly (takePoly 2 [0, 0, 1]) 1  =
  evalPoly [0,0] 1                   =
  0
\end{spec}
but
\begin{spec}
  (eval 2 x 1)                    =
  evalPoly (takePoly 2 [0, 1]) 1  =
  evalPoly [0, 1] 1               =
  1
\end{spec}
%
and thus |eval 2 (x*x) 1 = 0 /= 1 = 1*1 = (eval 2 x 1) * (eval 2 x
1)|.


\subsection{Operations on power series}

Power series have a richer structure than polynomials.
%
% TODO (by DaHe): I think the note about moving from Z to Q could be expanded
% upon. In Q, we have potentially infinite (repeating) digits, allowing division.
% Similarly, PowerSeries have infinite coefficients, and thus allows division.
% (not sure if there is any actual connection or just a coincidence, but still
% interesting to note)
%
For example, we also have division (this is similar to the move from |ℤ|
to |ℚ|).
%
We start with a special case: trying to compute |p = frac 1 (1-x)| as a
power series.
%
The specification of |a/b = c| is |a=c*b|, thus in our case we need to
find a |p| such that |1 = (1-x)*p|.
%
For polynomials there is no solution to this equation.
%
One way to see that is by using the homomorphism |degree|: the degree
of the left hand side is |0| and the degree of the RHS is |1 +  degree p /= 0|.
%
But there is still hope if we move to formal power series.

Remember that |p| is then represented by a stream of coefficients
|[p0, p1, ...]|.
%
We make a table of the coefficients of the RHS |= (1-x)*p =
p - x*p| and of the LHS |= 1| (seen as a power series).
%
\begin{spec}
  p      ==  [  p0,  p1,     p2,     ...
  x*p    ==  [  0,   p0,     p1,     ...
  p-x*p  ==  [  p0,  p1-p0,  p2-p1,  ...
  1      ==  [  1,   0,      0,      ...
\end{spec}
%
Thus, to make the last two lines equal, we are looking for
coefficients satisfying |p0=1|, |p1-p0=0|, |p2-p1=0|, \ldots.
%
The solution is unique: |1 = p0 = p1 = p2 = | \ldots
%
but only exists for streams (infinite lists) of coefficients.
%
In the common math notation we have just computed
%
\[
  \frac{1}{1-x} = \sum_{i = 0}^{\infty} x^i
\]
%
Note that this equation holds when we interpret both sides as formal
power series, but not necessarily if we try to evaluate the
expressions for a particular |x|.
%
That works for |absBar x < 1| but not for |x=2|, for example.

For a more general case of power series division |p/q| with |p =
a:as|, |q = b:bs|, we assume that |a * b ≠ 0|.
%
Then we want to find, for any given |(a : as)| and |(b : bs)|, the
series |(c : cs)| satisfying
%
\begin{spec}
  (a : as) / (b : bs) = (c : cs)                     <=> {- def. of division -}

  (a : as) = (c : cs) * (b : bs)                     <=> {- def. of |*| for |Cons| -}

  (a : as) = (c * b)  :  (cs * (b : bs)  +  [c]*bs)  <=> {- equality on compnents, def. of division -}

  c   = a / b                          {- and -}
  as  = cs * (b : bs) + [c] * bs       {-" "-}       <=> {- arithmetics -}

  c   = a / b                          {- and -}
  cs  =  (as - [c] * bs) / (b : bs)
\end{spec}

This leads to the implementation:

\begin{code}
instance (Eq a, Fractional a) => Fractional (PowerSeries a) where
  (/) = divPS
  fromRational =  Single . fromRational

divPS :: (Eq a, Fractional a) => PowerSeries a -> PowerSeries a -> PowerSeries a
divPS as           (Single b)    =  as * Single (1 / b)
divPS (Single 0)   (Cons b bs)   =  Single 0
divPS (Single a)   (Cons b bs)   =  divPS (Cons a (Single 0)) (Cons b bs)
divPS (Cons a as)  (Cons b bs)   =  Cons c  (divPS (as - (Single c) * bs) (Cons b bs))
                                    where  c = a / b
\end{code}

The first two equations allow us to also use division on polynomials,
but the result will, in general, be a power series, not a polynomial.
%
The first one should be self-explanatory.
%
The second one extends a constant polynomial, in a process similar to
that of long division.

For example:

\begin{code}
ps0, ps1, ps2 :: (Eq a, Fractional a) => PowerSeries a
ps0  = 1 / (1 - x)
ps1  = 1 / (1 - x)^2
ps2  = (x^2 - 2 * x + 1) / (x - 1)
\end{code}
%
Every |ps| is the result of a division of polynomials: the first two
return power series, the third is a polynomial (almost: it has a
trailing |0.0|).

\begin{code}
example0   = takePoly 10 ps0
example01  = takePoly 10 (ps0 * (1-x))
\end{code}

We can get a feeling for the definition by computing |ps0| ``by
hand''.
%
We let |p = [1]| and |q=[1,-1]| and seek |r = p/q|.
%
\begin{spec}
  divPS p q                                   =  {- def. of |p| and |q| -}
  divPS [1]      (1:[-1])                     =  {- 3rd case of |divPS| -}
  divPS (1:[0])  (1:[-1])                     =  {- 4th case of |divPS| -}
  (1/1) : divPS ([0] - [1] * [-1])  (1:[-1])  =  {- simplification, def. of |(*)| -}
  1 : divPS ([0] - [-1]) (1:[-1])             =  {- def. of |(-)| -}
  1 : divPS [1] (1:[-1])                      =  {- def. of |p| and |q| -}
  1 : divPS p q
\end{spec}
%
Thus, the answer |r| starts with |1| and continues with |r|!
%
In other words, we have that |1/[1,-1] = [1,1..]| as infinite lists of
coefficients and \(\frac{1}{1-x} = \sum_{i=0}^{\infty} x^i\) in the
more traditional mathematical notation.


\subsection{Formal derivative}

Considering the analogy between power series and polynomial functions
(via polynomials), we can arrive at a formal derivative for power
series through the folowing computation:
%
\begin{equation}
  \label{eq:formalderivative}
\begin{aligned}
  \left(\sum_{n = 0}^{\infty} a_n * x^n\right)'  &= \sum_{n = 0}^{\infty} (a_n * x^n)'  =  \sum_{n = 0}^{\infty} a_n * (x^n)' = \sum_{n = 0}^{\infty} a_n * (n * x^{n-1})  \\
  &=  \sum_{n = 0}^{\infty} (n * a_n) * x^{n-1} =  \sum_{n = 1}^{\infty} (n * a_n) * x^{n-1}  =  \sum_{m = 0}^{\infty} ((m+1) * a_{m+1}) * x^m
\end{aligned}
\end{equation}
%
Thus the $m$th coefficient of the derivative is \((m+1) * a_{m+1}\).

%TODO: redo to arrive at the recursive formulation.

We can implement this, for example, as

\begin{code}
deriv (Single a)   =  Single 0
deriv (Cons a as)  =  deriv' as 1
  where  deriv' (Single a)   n  =  Single  (n * a)
         deriv' (Cons a as)  n  =  Cons    (n * a)  (deriv' as (n+1))
\end{code}

Side note: we cannot in general implement a Boolean equality test for
|PowerSeries|.
%
For example, we know that |deriv ps0| equals |ps1| but we cannot
compute |True| in finite time by comparing the coefficients of the two
power series.

\begin{code}
checkDeriv :: Integer -> Bool
checkDeriv n  =  takePoly n (deriv ps0) == takePoly n ps1
\end{code}


Recommended reading: the Functional pearl: ``Power series, power
serious'' \cite{mcilroy1999functional}.


% ================================================================

% \subsection{Signals and Shapes}
%
% Shallow and deep embeddings of a DSL
%
% TODO: perhaps textify DSL/




\subsection{Helpers}

\begin{code}
instance Functor Poly where
  fmap = mapPoly

po1 :: Num a => Poly a
po1 = 1 + x^2 - 3*x^4

instance Num a => Monoid' (Poly a) where
  unit = Single 1
  op = (*)

instance Monoid' Integer where
  unit = 0
  op = (+)

type Nat = Integer

degree :: (Eq a, Num a) => Poly a -> Maybe Nat
degree (Single 0) = Nothing
degree (Single x) = Just 0
degree (Cons x xs) = maxd (degree (Single x)) (fmap (1+) (degree xs))
  where  maxd x        Nothing   = x
         maxd Nothing  (Just d)  = Just d
         maxd (Just a) (Just b)  = Just (max a b)

checkDegree0 = degree (unit :: Poly Integer) == unit
checkDegreeM :: Poly Integer -> Poly Integer -> Bool
checkDegreeM p q = degree (p*q) == op (degree p) (degree q)

\end{code}

%include E5.lhs
