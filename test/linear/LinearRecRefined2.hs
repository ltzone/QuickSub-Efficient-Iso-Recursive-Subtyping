import Data.List
import Prelude hiding (rem)

data Typ = TInt | Top | Fun Typ Typ | Mu Typ | Var Int deriving (Eq)

instance Show Typ where
  show TInt = "int"
  show Top = "T"
  show (Fun a b) = "" ++ show a ++ " -> " ++ show b ++ ""
  show (Var s) = show s
  show (Mu t) = "(mu ." ++ show t ++ ")"


data Cmp = Less | Equal [Int] deriving (Show, Eq)

data Mode = Plus | Minus deriving (Show, Eq)

type Env = [Mode]

eq = Equal []
lt = Less

neg Plus  = Minus
neg Minus = Plus

-- rem :: (Cmp, [Int])  -> Maybe (Cmp, [Int])
-- rem (Less, pxs)
--   | elem 0 pxs    = Just (Less, (map ((-) 1) (delete 0 pxs)))
--   | otherwise     = Nothing
-- rem ((Equal l), pxs)  
--   | elem 0 pxs    = Just (Equal (map ((-) 1) (delete 0 pxs)), (map ((-) 1) (delete 0 pxs)))
--   | otherwise     = Nothing

minus1 :: Int -> Int
minus1 x = x - 1


fvars :: Typ -> [Int]
fvars (Var x) = [x]
fvars (Fun a b) = union (fvars a) (fvars b)
fvars (Mu t) =  map minus1 (delete 0 (fvars t))
fvars _ = []



rem :: Typ -> (Cmp, [Int])  -> Maybe (Cmp, [Int])
rem t (Less, pxs)
  | elem 0 pxs    = Nothing
  | otherwise     = Just (Less, (map minus1 pxs))
rem t ((Equal l), pxs) 
  | elem 0 pxs    = Just ((Equal (union (map minus1 (delete 0 pxs)) (fvars t))), (union (map minus1 (delete 0 pxs)) (fvars t)))
  | otherwise     = Just ((Equal (map minus1 (delete 0 l)), (map minus1 (pxs))))

  -- | elem 0 pxs    = Just (Equal (map minus1 (delete 0 l)), (union (map minus1 (delete 0 pxs)) (fvars t)))
  -- | otherwise     = Just (Equal (map minus1 (delete 0 l)), (map minus1 (pxs)))
  -- when a is not weakly positive in mu a. A <: mu a. B
  -- then all the weakly positive variables in A <: B are no longer weakly positive in mu a. A <: mu a. B



(&&&) :: (Cmp, [Int]) -> (Cmp, [Int]) -> Maybe (Cmp, [Int])
(Less, pv1)        &&& (Less, pv2)          = Just (Less, union pv1 pv2)
(Less, pv1)        &&& ((Equal []), pv2)    = Just (Less, union pv1 pv2)
((Equal []), pv1)  &&& (Less, pv2)          = Just (Less, union pv1 pv2)
((Equal xs), pv1)  &&& ((Equal ys), pv2)    = Just ((Equal (union xs ys)), union pv1 pv2)
_           &&& _             = Nothing


maybe_map :: (a -> Maybe b) -> Maybe a -> Maybe b
maybe_map f Nothing  = Nothing
maybe_map f (Just x) = f x

-- check x e m a b
--
-- x ==> the current de Bruijn index
-- e ==> the current environment
-- m ==> the current mode
-- a ==> first type
-- b ==> second type

check :: Int -> Env -> Mode -> Typ -> Typ -> Maybe (Cmp, [Int])
check x e m TInt       TInt         = Just (eq, [])
check x e m Top        Top          = Just (eq, [])
check x e m a          Top          = Just (lt, [])
check x e m (Var i)    (Var j)
   | i == j && e !! i == m          = Just (eq, [])
   | i == j && e !! i == neg m      = Just (Equal [i], [i])
check x e m (Mu a)     (Mu b)       = maybe_map (rem (Mu b)) $ check (x+1) (m : e) m a b
check x e m (Fun a b)  (Fun c d)    =
   do cmp1 <- check x e (neg m) c a
      cmp2 <- check x e m b d
      (cmp1 &&& cmp2)
check x e m _          _            = Nothing 

chk :: Typ -> Typ -> Maybe (Cmp, [Int])
chk = check 0 [] Plus

judge_chk :: Maybe (Cmp, [Int]) -> Bool
judge_chk (Just (Equal [], _)) = True
judge_chk (Just (Less, _)) = True
judge_chk _ = False

-- Example 1

t1 = Mu (Fun Top (Var 0))
t2 = Mu (Fun (Var 0) (Var 0))

test1 = chk t1 t2

-- Example 2

t3 = Mu (Fun (Var 0) TInt)
t4 = Mu (Fun (Var 0) Top)

test2 = chk t3 t4

-- Example 3

test3 = chk t2 t2

-- Example 4

t5 = Fun t2 TInt
t6 = Fun t2 Top

test4 = chk t5 t6

-- Example 5

t7 = Mu (Fun Top (Fun (Var 0) (Var 0)))
t8 = Mu (Fun TInt (Fun (Var 0) (Var 0)))

test5 = chk t7 t8


-- Example 6
-- should fail:
-- mu a. Top -> (mu b. b -> a) < mu a. a -> (mu b. b -> a)
t9 = Mu (Fun Top (Mu (Fun (Var 0) (Var 1))))
t10 = Mu (Fun (Var 0) (Mu (Fun (Var 0) (Var 1))))

test6 = chk t9 t10


-- mu a. Int -> (mu b. mu c. Int) < mu a. Int -> (mu b. mu c. Top)
t11 = Mu (Fun TInt (Mu (Mu TInt)))
t12 = Mu (Fun TInt (Mu (Mu Top)))

test7 = chk t11 t12

-- mu a. Top -> (mu b. b -> Int) < mu a. Int -> (mu b. b -> Int)
t13 = Mu (Fun Top (Mu (Fun (Var 0) TInt)))
t14 = Mu (Fun TInt (Mu (Fun (Var 0) TInt)))

test8 = chk t13 t14 -- should success



test_res = [test1, test2, test3, test4, test5, test6, test7, test8]


type Env2 = [Maybe Typ]


wf_typ :: Env2 -> Typ -> Bool
wf_typ e TInt                 = True
wf_typ e Top                 = True
wf_typ (Nothing:xs) (Var 0)   = True
wf_typ (Just x : xs) (Var 0)  = True -- wf_typ xs x  
wf_typ (x:xs) (Var i)         = wf_typ xs (Var (i-1))  
wf_typ e (Fun a b)            = wf_typ e a && wf_typ e b
wf_typ e (Mu a)               = wf_typ (Just a:e) a
wf_typ e t                    = error (show e ++ " |- " ++ show t)


wf :: Env2 -> Env2 -> Bool
wf [] []                      = True
wf (Nothing:xs) (Nothing:ys)  = wf xs ys
wf (Just x:xs) (Just y:ys)    = {- wf_typ xs x && wf_typ ys y && -} wf xs ys
wf _ _                        = False


replace :: Int -> a -> [a] -> [a]
replace i x []      = []
replace 0 x (_:xs)  = x:xs
replace i x (y:xs)  = y:(replace (i-1) x xs) 


subRec :: Env2 -> Typ -> Env2 -> Typ -> Bool
subRec e1 a e2 Top                               = wf e1 e2
subRec e1 TInt e2 TInt                            = wf e1 e2
subRec (Nothing:xs) (Var 0) (Nothing:ys) (Var 0)  = wf xs ys
subRec (Just x:xs) (Var 0) (Just y:ys) (Var 0)    = subRec (Nothing:xs) x (Nothing:ys) y
subRec (Just x:xs) (Var i) (Just y:ys) (Var j)
   | i == j    = subRec xs (Var (i-1)) ys (Var (j-1))
   | otherwise = False
subRec e1 (Fun a b) e2 (Fun c d)                  = subRec e2 c e1 a && subRec e1 b e2 d
subRec e1 (Mu a) e2 (Mu b)                        = subRec (Just a : e1) a (Just b : e2) b
subRec e1 t1 e2 t2 = False
    -- error (show e1 ++ " |- " ++ show t1 ++ " <: " ++ show t2 ++ " -| " ++ show e2) 


{-
​
E ::= . | E, a | E, a |-> A
​
==================
E1 |- A <: B -| E2
==================
​
E1 |- A <: Top -| E2
​
E1 |- Int <: Int -| E2
​
a in E1    a in E2    
-------------------
E1 |- a <: a -| E2
​
E1', a, E1'' |- A <: B  -| E2', a, E2''
--------------------------------------------------
E1', a |-> A, E1'' |- a <: a -| E2', a |-> B, E2''
​
E2 |- C <: A -| E1    E1 |- B <: D -| E2
----------------------------------------
E1 |- A -> B <: C -> D |- E2
​
E1, a |-> A |- A <: B -| E2, a |-> B
------------------------------------
E1 |- mu a . A <: mu a. B -| E2
​
-}


sub :: Typ -> Typ -> Bool
sub t1 t2 = subRec [] t1 [] t2





level = 3

generate :: Int -> Int -> [Typ]
generate 0 0 = [Mu x | x <- generate 1 0]
generate n k = if (n==level)
  then
    [TInt, Top] ++ [Var x | x <- [0..k]]
  else
    let x = generate (n+1) k in
      let y = generate (n+1) (k+1) in
    [TInt, Top] ++ [Var x | x <- [0..k]] ++ [Fun a b| a <- x, b <- x]
    ++ [Mu a | a <- y]

types = generate 0 0 -- 81324 types



-- completeness check
counter_example = [(a,b) | a <- types, b <- types, sub a b, not (judge_chk (chk a b))]

-- soundness check
counter_example2 = [(a,b) | a <- types, b <- types, (judge_chk (chk a b)), not (sub a b), not (a == b)]

s1 = Mu (Fun TInt (Mu (Mu TInt)))
s2 = Mu (Fun TInt (Mu (Mu Top)))

stest1 = chk s1 s2

s3 = Mu (Mu TInt)
s4 = Mu (Mu Top)

stest2 = chk s3 s4


s5 = Mu ((Mu (Mu TInt)))
s6 = Mu ((Mu (Mu Top)))

stest3 = chk s5 s6