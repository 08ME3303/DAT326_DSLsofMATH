% DSLsofMath-PD.tex
\begin{hcarentry}[updated]{DSLsofMath}
\report{Patrik Jansson}%04/18
\status{active development}
\participants{Cezar Ionescu, Daniel Heurlin, Daniel Schoepe}
\makeheader

``Domain Specific Languages of Mathematics'' is a project at
\href{http://www.chalmers.se/en/Pages/default.aspx}{Chalmers} and
\href{http://www.gu.se/english}{UGOT} which lead to a new BSc level course of
the same name, including accompanying material for learning and applying
classical mathematics (mainly basics of real and complex analysis).
%
The main idea is to encourage the students to approach mathematical domains
from a functional programming perspective:
%
to identify the main functions and types involved and, when necessary, to
introduce new abstractions;
%
to give calculational proofs;
%
to pay attention to the syntax of the mathematical expressions;
%
and, finally, to organize the resulting functions and types in domain-specific
languages.

The third instance of the course was carried out Jan-March 2018 in Gothenburg
and the course material is available on
\href{https://github.com/DSLsofMath/DSLsofMath}{github}.
%
The lecture notes have been collected in an informal ``book'' during
the last six months; contributions and ideas are welcome!
%

Just two example to give a feeling for the contents:
%
Given the definition of
{
% the `doubleequals' macro is due to Jeremy Gibbons
\def\doubleequals{\mathrel{\unitlength 0.01em
  \begin{picture}(78,40)
    \put(7,34){\line(1,0){25}} \put(45,34){\line(1,0){25}}
    \put(7,14){\line(1,0){25}} \put(45,14){\line(1,0){25}}
  \end{picture}}}
%format == = "\doubleequals"
%format Forall(x)(y)          =  "\forall\ " x ".\ " y
%format H2 x = H "_2" x
%format ⋅ = "\cdot"
``|h : A -> B| is a homomorphism from |Op : A->A->A| to |op : B->B->B|'':
\begin{spec}
H2(h,Op,op)  =  Forall x (Forall y (h(Op x y) == op (h x) (h y)))
\end{spec}
Then |H2(exp,(+),(⋅))| says that \(e^{A+B}\) |==| \(e^A\) |⋅| \(e^B\) for all \(A\) and \(B\).
%
A somewhat longer example (\href{https://twitter.com/patrikja/status/966074410611413000}{two tweets}):
%format ∫ = "\int"
%format =~ = "\simeq"
%format ^ = "\hat{\ }"
\begin{code}
import Prelude hiding (exp,sin,cos)
z=zipWith
c∫f  = c:z (/) f [1..]
exp  = 1∫exp
sin  = 0∫cos
cos  = 1∫(-sin)
instance Num a => Num [a] where
  (+)  = z (+)
  (-)  = z (-)
  (*)  = m
  fromInteger i = fromInteger i : repeat 0
m (x:xs) q@(y:ys) = x*y : (map (x*) ys) + xs*q

one = 1 :: [Rational]
test = (sin^2+cos^2) =~ one
d cs = zipWith (*) [1..] (tail cs)
xs =~ ys = and (take 10 (z (==) xs ys))

test2 = exp =~ d exp
\end{code}

}

See also the HCAR entry ``Learn You A Physics'' by a group of BSc students.

\FurtherReading
\begin{compactitem}
\item \href{https://github.com/DSLsofMath}{DSLsofMath (github organisation)}
\item \href{https://github.com/DSLsofMath/BScProj2018/}{``Learn you a physics''} BSc project applying DSLsofMath ideas.
\item \href{https://github.com/DSLsofMath/DSLsofMath/tree/master/L/snapshots}{Latest snapshot of the DSLsofMath Lecture Notes (work in progress)}
\item \href{https://github.com/DSLsofMath/DSLsofMath/blob/master/Exam/2018-03/}{Exam 2018 with solutions}
\item \href{https://github.com/DSLsofMath/tfpie2015}{TFPIE 2015 paper}
\end{compactitem}
\end{hcarentry}
