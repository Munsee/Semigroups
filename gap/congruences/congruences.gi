############################################################################
##
#W  congruences.gi
#Y  Copyright (C) 2015                                   Michael C. Torpey
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains some general functions, operations and attributes of
## semigroup congruences.  Methods for specific types of congruence are
## implemented in the following files:
##
##       cong-inverse.gi - Inverse semigroups
##       cong-pairs.gi   - Congruences with generating pairs
##       cong-rees.gi    - Rees congruences
##       cong-reesmat.gi - (0-)simple Rees matrix semigroups
##       cong-simple.gi  - (0-)simple semigroups
##       cong-univ.gi    - Universal congruences
##
## congruences.gd contains declarations for many of these.
##

InstallGlobalFunction(SemigroupCongruence,
function(arg)
  local s, pairs, cong;
  if not Length(arg) >= 2 then
    Error("Semigroups: SemigroupCongruence: usage,\n",
          "at least 2 arguments are required,");
    return;
  fi;
  if not IsSemigroup(arg[1]) then
    Error("Semigroups: SemigroupCongruence: usage,\n",
          "1st argument <s> must be a semigroup,");
    return;
  fi;
  s := arg[1];

  if IsHomogeneousList(arg[2]) then
    # We should have a list of generating pairs
    if Length(arg) = 2 then
      pairs := arg[2];
      if not IsEmpty(pairs) and not IsList(pairs[1]) then
        pairs := [pairs];
      fi;
    elif Length(arg) > 2 then
      pairs := arg{[2 .. Length(arg)]};
    fi;
    if not ForAll(pairs, p -> Size(p) = 2) then
      Error("Semigroups: SemigroupCongruence: usage,\n",
            "<pairs> should be a list of lists of size 2,");
      return;
    fi;
    if not ForAll(pairs, p -> p[1] in s and p[2] in s) then
      Error("Semigroups: SemigroupCongruence: usage,\n",
            "each pair should contain elements from the semigroup <s>,");
      return;
    fi;
    # Remove any reflexive pairs
    pairs := Filtered(pairs, p -> p[1] <> p[2]);
    if ((HasIsSimpleSemigroup(s) or IsActingSemigroup(s)) and
        IsSimpleSemigroup(s)) or
       ((HasIsZeroSimpleSemigroup(s) or IsActingSemigroup(s)) and
        IsZeroSimpleSemigroup(s)) then
      return SEMIGROUPS_SimpleCongFromPairs(s, pairs);
    elif (HasIsSemilatticeAsSemigroup(s) or IsActingSemigroup(s))
        and IsSemilatticeAsSemigroup(s) then
      cong := SemigroupCongruenceByGeneratingPairs(s, pairs);
      SetIsSemilatticeCongruence(cong, true);
      return cong;
    elif (HasIsInverseSemigroup(s) or IsActingSemigroup(s))
        and IsInverseSemigroup(s) then
      return SEMIGROUPS_InverseCongFromPairs(s, pairs);
    else
      return SemigroupCongruenceByGeneratingPairs(s, pairs);
    fi;
  elif (IsRMSCongruenceByLinkedTriple(arg[2]) and IsSimpleSemigroup(s)) or
    (IsRZMSCongruenceByLinkedTriple(arg[2]) and IsZeroSimpleSemigroup(s)) then
    # We should have a congruence of an isomorphic RMS/RZMS
    if Range(IsomorphismReesMatrixSemigroup(s)) = Range(arg[2]) then
      return SEMIGROUPS_SimpleCongFromRMSCong(s, arg[2]);
    else
      Error("Semigroups: SemigroupCongruence: usage,\n",
            "<cong> should be over a Rees (0-)matrix semigroup ",
            "isomorphic to <s>");
      return;
    fi;
  elif IsSemigroupIdeal(arg[2]) and Parent(arg[2]) = s then
    return ReesCongruenceOfSemigroupIdeal(arg[2]);
  elif Length(arg) = 3 and
    IsInverseSemigroup(arg[2]) and
    IsDenseList(arg[3]) and
    IsInverseSemigroup(s) then
    # We should have the kernel and trace of a congruence on an inverse
    # semigroup
    return InverseSemigroupCongruenceByKernelTrace(s, arg[2], arg[3]);
  else
    TryNextMethod();
  fi;
end);

#

InstallMethod(ViewObj,
"for a semigroup congruence",
[IsSemigroupCongruence],
1,
function(cong)
  Print("<semigroup congruence over ");
  ViewObj(Range(cong));
  if HasGeneratingPairsOfMagmaCongruence(cong) then
    Print(" with ", Size(GeneratingPairsOfSemigroupCongruence(cong)),
          " generating pairs");
  fi;
  Print(">");
end);

#

InstallMethod(PrintObj,
"for a semigroup congruence",
[IsSemigroupCongruence],
1,
function(cong)
  Print("SemigroupCongruence( ");
  PrintObj(Range(cong));
  Print(", ");
  if HasGeneratingPairsOfMagmaCongruence(cong) then
    Print(GeneratingPairsOfSemigroupCongruence(cong));
  fi;
  Print(")");
end);

#

InstallMethod(\*,
"for an equivalence class and a list",
[IsEquivalenceClass, IsList],
function(class, list)
  return List(list, x -> class * x);
end);

#

InstallMethod(\*,
"for a list and an equivalence class",
[IsList, IsEquivalenceClass],
function(list, class)
  return List(list, x -> x * class);
end);

#
