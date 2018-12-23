# Domain-Specific Languages of Mathematics

Homepage for the 2019 instance of a 7.5hec BSc course at Chalmers and GU.

Homepage: https://github.com/DSLsofMath/DSLsofMath/

Course codes: [DAT326](https://www.student.chalmers.se/sp/course?course_id=26170) / [DIT982](http://kursplaner.gu.se/english/DIT982.pdf)

## News

* Re-exam in August: 2018-08-28, 14.00-18.00 at "M" (registration closes 2018-08-01)
* 2018-03-25: (Inofficial) [exam results](Exam/2018-03/anon_results.md)
* 2018-03-13: Added [exam + solutions](Exam/2018-03/)

## Course team

* Examiner & main lecturer: Patrik Jansson (patrikj AT)
* Guest lecturer: Cezar Ionescu (cezar AT)
* Teaching assistant: To be decided (was Daniel Schoepe (schoepe AT))

## Objectives

The course presents classical mathematical topics from a computing
science perspective: giving specifications of the concepts introduced,
paying attention to syntax and types, and ultimately constructing DSLs
of some mathematical areas mentioned below.

Learning outcomes as in the
[course syllabus](https://www.student.chalmers.se/sp/course?course_id=27332).

* Knowledge and understanding
    * design and implement a DSL (Domain Specific Language) for a new domain
    * organize areas of mathematics in DSL terms
    * explain main concepts of elementary real and complex analysis, algebra, and linear algebra
* Skills and abilities
    * develop adequate notation for mathematical concepts
    * perform calculational proofs
    * use power series for solving differential equations
    * use Laplace transforms for solving differential equations
* Judgement and approach
    * discuss and compare different software implementations of mathematical concepts

The course is elective for both computer science and mathematics
students at both Chalmers and GU.

## Course material

[Lecture notes](L/snapshots/) + references therein cover the course but there is no
printed course textbook.

The main references are listed below.

## Course setup

* Lectures (TBD [was Tue. 13-15 and Thu 13-15 in EB. [[TimeEdit]](https://se.timeedit.net/web/chalmers/db1/public/ri157375X39Z06Q5Z46g0Y30y5096Y35Q01gQY5Q55767.html)])
    * Introduction: Haskell, complex numbers, syntax, semantics, evaluation, approximation
    * Basic concepts of analysis: sequences, limits, convergence, ...
    * Types and mathematics: logic, quantifiers, proofs and programs, Curry-Howard, ...
        * Type classes, derivatives, differentiation, calculational proofs
    * Domain Specific Languages and algebraic structures, algebras, homomorphisms
    * Polynomials, series, power series
    * Power series and differential equations, exp, sin, log, Taylor series, ...
    * Linear algebra: vectors, matrices, functions, bases, dynamical systems as matrices and graphs
    * Laplace transform: exp, powers series cont., solving PDEs with Laplace
* Weekly exercise sessions (TBD [was Tue 15-17 and Thu 15-17 in ES52])
    * Half time helping students solve problems in small groups
    * Half time joint problem solving at the whiteboard

## Changes from last year

The main changes for 2019 (based on the [course eval meeting](eval/2018.txt)) are

* Exercise session structure: first (hour) supervised work, second (hour) demonstration
* More stress on students solving exercises
** Weekly hand-ins to encourage students to spend more hours on the course (not part of the formal examination)

## Examination

There are two compulsory course elements:

* A = Assignments (written + oral examination in groups of three students)
    * two compulsory hand-in assignments (To be decided for 2019 (was 2018-01-30, 2018-02-27))
    * Grading: Pass or fail
    * The assignments are to be handed in via [Fire](https://dslm-lp3-18.frs.cse.chalmers.se)
* E Exam (individual written exam at the end of the course)
    * Grading: **Chalmers**: U, 3, 4, 5; **GU**: U, G, VG
    * Date: [2019-03-19, 14.00-18.00](https://www.student.chalmers.se/sp/course?course_id=27332) (registration closes 2019-02-28)
    * Aids: One textbook of your choice

To pass the course you need to pass both course elements.

## Lectures

The latest PDF snapshot of the full lecture notes can be found in
[L/snapshots](L/snapshots/).

The "source code" for the lecture notes are in subdirectories of
L/: [L/01/](L/01), [L/02/](L/02/), etc.

## Exercises

Chapter 1-8 of the Lecture Notes end with weekly exercises for weeks
1-8.

In [L/RecEx.md](L/RecEx.md) you will find a list of recommended exercises
for each chapter of the lecture notes.

## Using the DSLsofMath

In order to do some of the exercises, you may need/want to have access to the
DSLs introduced during the lectures and in the lecture notes.

To do this, first make sure you have installed
[stack](https://docs.haskellstack.org/en/stable/README/). Next, download [this
tarball](L/DSLsofMath-0.1.9.1.tar.gz) and extract it in a desired location (on
Linux and Mac, you can do this by running `tar -zxf DSLsofMath-x.x.x.x.tar.gz
` in the terminal. In Windows, you might have to use a tool like
[7-Zip](http://www.7-zip.org/)).

Now go into the extracted folder `DSLsofMath-x.x.x.x/` and run `stack init`. You can now interact with
the code from the lectures by typing `stack ghci`, which puts you in ghci with all
DSLs loaded. You can also place your own haskell files inside this folder and import the DSLs you
want by typing the following at the start of your file:

```haskell
import DSLsofMath.W0X
```
where X is the chapter that contains the code you want to use. You should be
able to load your own haskell files in normal ghci.

### Installing stack on the Chalmers linux machines

On the linux remote machines you have a number of options to get stack to work.
Regardless of how you do it the goal is to have a local stack executable in the directory `~/.local/bin`.
One way to do this is to follow these steps:
* Run `stack upgrade`, optionally download the right executable from the stack website.
* Make sure you add `export PATH="/chalmers/home/<<<Your CID here>>>/.local/bin/:$PATH"` to your `.bashrc`.
* Restart the terminal
* Make sure that `which stack` prints `/chalmers/home/<<<Your CID here>>>/.local/bin/stack`

## Evaluation

DSLsofMath course evaluation student representatives 2019: TBD

| Email (@student) | Name                   |
| ---------------- | ---------------------- |
|    | 	    |

## References

Some important references:

### Functional programming

- **Thinking Functionally with Haskell**, Richard Bird, Cambridge
  University Press, 2014
  [URL](http://www.cs.ox.ac.uk/publications/books/functional/)
- **Introduction to Functional Programming Using Haskell**, Richard
  Bird, Prentice-Hall, 1998.  A previous (but *very* different)
  version of the above.
- **An Introduction to Functional Programming**, Richard Bird and Phil
  Wadler, Prentice-Hall, 1988. A previous (but *very* different)
  version of *both* of the above.

### DSLs

- **Functional Programming for Domain-Specific Languages**, Jeremy
  Gibbons.  In *Central European Functional Programming School 2015*,
  LNCS 8606, 2015.
  [URL](http://link.springer.com/chapter/10.1007%2F978-3-319-15940-9_1)

  This is currently *the* standard reference to DSLs for the
  functional programmer.

- **Folding Domain-Specific Languages: Deep and Shallow Embeddings**,
  Jeremy Gibbons and Nicolas Wu,
  ICFP 2014. [URL](http://www.cs.ox.ac.uk/publications/publication7584-abstract.html)

  Available at the same link: a highly recommended
  [short version](http://www.cs.ox.ac.uk/people/jeremy.gibbons/publications/embedding-short.pdf)
  and the two videos of Jeremy presenting the most important ideas
  of DSLs in a very accessible way.

- **Programming Languages**, Mike Spivey.  Lecture notes of a course
  given at the CS Department in Oxford.  Useful material for
  understanding the design and implementation of embedded DSLs.
  [URL](http://spivey.oriel.ox.ac.uk/corner/Programming_languages)

- **Domain Specific Languages**, Martin Fowler, 2011.
  [URL](http://martinfowler.com/books/dsl.html)

  The view from the object-oriented programming perspective.

### The computer science perspective

- **Communicating Mathematics: Useful Ideas from Computer Science**,
  Charles Wells, *American Mathematical Monthly*, May 1995.  [URL](http://www.cwru.edu/artsci/math/wells/pub/pdf/commath.pdf)

  This article was one of the main triggers of this course.

  [Short summary of the recommendations](PedProj/CommunicatingMathematics_Wells.md)

### Mathematics

- **The Language of First-Order Logic, 3rd Edition**, Jon Barwise and John
  Etchemendy, 1993.  Out of print, but you can get it for one penny
  from Amazon UK.  A vast improvement over its successors (as Tony
  Hoare said about Algol 60).

- **Mathematics: Form and Function**, Saunders Mac Lane, Springer 1986.
  An overview of the relationships between the many mathematical
  domains.  Entertaining, challenging, rewarding.
  [Fulltext from the library](http://chalmers.summon.serialssolutions.com/sv-SE/search?ho=t&q=Mathematics%3A%20Form%20and%20Function)

- **Functional Differential Geometry**, Gerald Jay Sussman and Jack
  Wisdom, 2013, MIT.  A book about using programming as a means of
  understanding differential geometry.  Similar in spirit to the course,
  but more advanced and very different in form.  An earlier version
  appeared as an [AIM report](http://web.mit.edu/wisdom/www/AIM-2005-003.pdf).
