import System.Environment
import System.IO
import Data.Bits


{-
Implementations of a parser for the Pablo Language for the Parabix.

Author: Parsa Habibi

The language BNF∷

Expression Syntax

<expression> ::=  <term> | <expression> "|" <term> | <expression> "^" <term>
<term> ::=  <factor> | <term> "&" <factor>
<factor> ::= <primitive> | "~" <primitive> | "(" <primitive ")"
<primitive> ::= <literal> | <variable> | <function-call>
<literal> ::= <int> | "<" <int> ">"
<variable> ::= <identifier> | <identifier> "[" <int> "]"
<function-call> ::= <identifier> "(" <expression> {"," <expression>} ")"
<int> = [1-9][0-9]*

Statements

<block> ::= {<statement>}
<statement> ::= <assignment> | <if> | <while>
<assignment> ::= <variable> "=" <expression>
<if> ::= "if" <expression> ":" <block>
<while> ::= "while" <expression> ":" <block>

Types

<type> ::= <integer-type> | <stream-type> | <stream-set-type>
<integer-type> ::= "i" <int>
<stream_type> ::= "<" <integer-type> ">"
<stream_set-type> ::= <stream_type> "[" <integer> "]"

Kernels

<kernel> ::= "kernel" <identifier> "::" <signature> "{" block "}"
<signature> ::= <parameter_list> "->" <parameter_list>
<parameter_list> ::= [<parameter_spec> {"," <parameter_spec>} ]
<parameter_spec> ::= <type> <identifier> | <type> "(" <identifier> {"," <identifier>} ")"
-}

data Pablo = INT Integer | IDEN [Char] | OR Pablo Pablo | XOR Pablo Pablo | AND Pablo Pablo
 |NEG Pablo | Group Pablo | LIT Pablo| LIST Pablo | COM Pablo | Block [Pablo] | EQ Pablo Pablo| IF Pablo
 | While Pablo | COL Pablo | I Pablo | DCOL Pablo | Arrow Pablo | ParamL [Pablo]
 | Kernal Pablo deriving Show


-- parsePablo :: [Char] -> Maybe(Pablo , [Char])
-- Implementations fo parse EXP
--  <expression> ::=  <term> | <expression> "|" <term> | <expression> "^" <term>
parseEXP :: [Char] -> Maybe (Pablo , [Char])
parseEXTP :: (Pablo, [Char]) -> Maybe (Pablo , [Char])

parseEXP [] = Nothing
parseEXP s =
  case parseTerm s of
    Just (p , rest) -> parseEXTP (p,rest)
    _ -> Nothing
parseEXTP (pab1, '|':rest) =
  case parseTerm rest of
    Just(pab2 , yet_more) -> parseEXTP (OR pab1 pab2 , yet_more)
    _-> Nothing
parseEXTP (pab1, '^':rest) =
  case parseTerm rest of
    Just(pab2 , yet_more) -> parseEXTP (XOR pab1 pab2 , yet_more)
    _-> Nothing
parseEXRP (pab1 , rest) = Just (pab1 , rest)

--
--

-- <term> ::=  <factor> | <term> "&" <factor>
parseTerm :: [Char] -> Maybe (Pablo , [Char])
parseTerm s =
  case parseFactor s of
    Just(e, more) -> parseTermEXT(e,more)
    _->Nothing

parseTermEXT:: (Pablo , [Char] )-> Maybe (Pablo , [Char])
parseTermEXT (p1, '&':rest) =
  case parseFactor rest of
    Just (p2, more) -> parseTermEXT(AND p1 p2 , more)
    _-> Nothing
parseTermEXT (p1 , s) = Just (p1 , s)

--
--
--
-- <factor> ::= <primitive> | "~" <primitive> | "(" <primitive ")"

parseFactor :: [Char] -> Maybe (Pablo , [Char])

parseFactor ('~':rest) =
  case parsePrem rest of
    Just (p , more) -> Just(NEG p , more)
    _->Nothing

parseFactor ('(' : rest) =
  case parsePrem rest of
    Just(p , ')':more) -> Just (Group p , more)
    _->Nothing

parseFactor s =
  case parsePrem s of
    Just (p , more) -> Just (p , more)
    _-> Nothing
--
--
-- <primitive> ::= <literal> | <variable> | <function-call>

parsePrem :: [Char] -> Maybe (Pablo, [Char])

parsePrem s = Just (INT 23 , s)
-- parsePrem s =
--   case parseLit s of
--     Just (p , more) -> Just (p , more)
--     _-> Nothing
--
-- parsePrem s =
--   case parseVar s of
--     Just (p , more ) -> Just (p , more)
--     _->Nothing
--
-- parsePrem s =
--   case pareFNC s of
--     Just (p , more) -> Just (p, more)
