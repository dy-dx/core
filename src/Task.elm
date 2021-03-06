module Task
    ( Task
    , succeed, fail
    , map, map2, map3, map4, map5, andMap
    , sequence
    , andThen
    , onError, mapError
    , ID, spawn, sleep
    ) where
{-|

# Basics
@docs succeed, fail

# Mapping
@docs map, map2, map3, map4, map5, andMap

# Chaining
@docs andThen, sequence

# Errors
@docs onError, mapError

# Threads
@docs spawn, sleep
-}

import Native.Task
import List exposing ((::))
import Result exposing (Result)
import Signal exposing (Stream)
import Time exposing (Time)


type Task x a = Task


-- BASICS

succeed : a -> Task x a
succeed =
  Native.Task.succeed


fail : x -> Task x a
fail =
  Native.Task.fail


-- MAPPING

map : (a -> b) -> Task x a -> Task x b
map func promiseA =
  promiseA
    `andThen` \a -> succeed (func a)


map2 : (a -> b -> result) -> Task x a -> Task x b -> Task x result
map2 func promiseA promiseB =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> succeed (func a b)


map3 : (a -> b -> c -> result) -> Task x a -> Task x b -> Task x c -> Task x result
map3 func promiseA promiseB promiseC =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> succeed (func a b c)


map4 : (a -> b -> c -> d -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x result
map4 func promiseA promiseB promiseC promiseD =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> succeed (func a b c d)


map5 : (a -> b -> c -> d -> e -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x e -> Task x result
map5 func promiseA promiseB promiseC promiseD promiseE =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> promiseE
    `andThen` \e -> succeed (func a b c d e)


andMap : Task x (a -> b) -> Task x a -> Task x b
andMap promiseFunc promiseValue =
  promiseFunc
    `andThen` \func -> promiseValue
    `andThen` \value -> succeed (func value)


sequence : List (Task x a) -> Task x (List a)
sequence promises =
  case promises of
    [] ->
        succeed []

    promise :: remainingTasks ->
        map2 (::) promise (sequence remainingTasks)


-- interleave : List (Task x a) -> Task x (List a)



-- CHAINING

andThen : Task x a -> (a -> Task x b) -> Task x b
andThen =
  Native.Task.andThen


-- ERRORS

onError : Task x a -> (x -> Task y a) -> Task y a
onError =
  Native.Task.catch_


mapError : (x -> y) -> Task x a -> Task y a
mapError f promise =
  promise `onError` \err -> fail (f err)


-- THREADS

type ID = ID Int


spawn : Task x a -> Task y ID
spawn =
  Native.Task.spawn


-- kill : ID -> Task x ()


sleep : Time -> Task x ()
sleep =
  Native.Task.sleep
