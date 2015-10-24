############################################################################
##
#W  congruences/rees.gi
#Y  Copyright (C) 2015                                   Michael C. Torpey
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains methods for Rees congruences; i.e. semigroup congruences
## defined by a two-sided ideal.  See Howie 1.7
##

InstallMethod(IsReesCongruence,
"for a semigroup congruence",
[IsSemigroupCongruence],
1, #FIXME why is this here?
function(cong)
  local S, classes, sizes, pos, class, ideal;
  # This function is adapted from code in the library
  S := Range(cong);
  if NrCongruenceClasses(cong) = Size(S) then
    # Trivial congruence - only possible ideal is zero
    if MultiplicativeZero(S) <> fail then
      SetSemigroupIdealOfReesCongruence(cong, MinimalIdeal(S));
      return true;
    else
      return false;
    fi;
  else
    # Find all the non-trivial classes
    classes := EquivalenceClasses(cong);
    sizes := List(classes, Size);
    pos := PositionsProperty(sizes, n -> n > 1);
    if Length(pos) > 1 then
      return false;
    fi;
    # Only one non-trivial class - check it is an ideal
    class := classes[pos[1]];
    ideal := SemigroupIdeal(S, AsList(class));
    if Size(class) = Size(ideal) then
      SetSemigroupIdealOfReesCongruence(cong, ideal);
      return true;
    else
      return false;
    fi;
  fi;
end);

#

InstallMethod(ReesCongruenceOfSemigroupIdeal,
"for a semigroup ideal",
[IsSemigroupIdeal],
1, #FIXME why is this here?
function(I)
  local S, fam, type, cong;
  S := Parent(I);
  # Construct the object
  fam := GeneralMappingsFamily(ElementsFamily(FamilyObj(S)),
                               ElementsFamily(FamilyObj(S)));
  type := NewType(fam, IsSemigroupCongruence and IsAttributeStoringRep);
  cong := Objectify(type, rec());
  # Set some attributes
  SetSource(cong, S);
  SetRange(cong, S);
  SetSemigroupIdealOfReesCongruence(cong, I);
  SetIsReesCongruence(cong, true);
  return cong;
end);

#

InstallMethod(ViewObj,
"for a Rees congruence",
[IsReesCongruence],
function(cong)
  Print("<Rees congruence of ");
  ViewObj(SemigroupIdealOfReesCongruence(cong));
  Print(" over ");
  ViewObj(Range(cong));
  Print(">");
end);

#

InstallMethod(PrintObj,
"for a Rees congruence",
[IsReesCongruence],
function(cong)
  Print("ReesCongruenceOfSemigroupIdeal( ");
  Print(SemigroupIdealOfReesCongruence(cong));
  Print(" )");
end);

#

InstallMethod(NrCongruenceClasses,
"for a Rees congruence",
[IsReesCongruence],
cong -> Size(Range(cong)) - Size(SemigroupIdealOfReesCongruence(cong)) + 1);

#

InstallMethod(\=,
"for two Rees congrunces",
[IsReesCongruence, IsReesCongruence],
function(c1, c2)
  return SemigroupIdealOfReesCongruence(c1) =
         SemigroupIdealOfReesCongruence(c2);
end);

#

InstallMethod(\in,
"for an associative element collection and a Rees congruence",
[IsAssociativeElementCollection, IsReesCongruence],
function(pair, cong)
  local S, I;
  # Check for validity
  if Size(pair) <> 2 then
    ErrorMayQuit("Semigroups: \in: usage,\n",
                 "the first arg <pair> must be a list of length 2,");
  fi;
  S := Range(cong);
  if not ForAll(pair, x -> x in S) then
    ErrorMayQuit("Semigroups: \in: usage,\n",
                 "the elements of 1st arg <pair> ",
                 "must be in the range of 2nd arg <cong>,");
  fi;
  I := SemigroupIdealOfReesCongruence(cong);
  return (pair[1] = pair[2]) or (pair[1] in I and pair[2] in I);
end);

#

InstallMethod(ImagesElm,
"for a Rees congruence and an associative element",
[IsReesCongruence, IsAssociativeElement],
function(cong, elm)
  if not elm in Range(cong) then
    ErrorMayQuit("Semigroups: ImagesElm: usage,\n",
                 "the args <cong> and <elm> must refer to the same semigroup,");
  fi;
  if elm in SemigroupIdealOfReesCongruence(cong) then
    return Elements(SemigroupIdealOfReesCongruence(cong));
  else
    return [elm];
  fi;
end);

#

InstallMethod(JoinSemigroupCongruences,
"for two Rees congruences",
[IsReesCongruence, IsReesCongruence],
function(c1, c2)
  local gens1, gens2, I;
  if Range(c1) <> Range(c2) then
    ErrorMayQuit("Semigroups: JoinSemigroupCongruences: usage,\n",
                 "the args <c1> and <c2> must be congruences of the same ",
                 "semigroup,");
  fi;
  gens1 := GeneratorsOfSemigroupIdeal(SemigroupIdealOfReesCongruence(c1));
  gens2 := GeneratorsOfSemigroupIdeal(SemigroupIdealOfReesCongruence(c2));
  I := SemigroupIdeal(Range(c1), Concatenation(gens1, gens2));
  I := SemigroupIdeal(Range(c1), MinimalIdealGeneratingSet(I));
  return ReesCongruenceOfSemigroupIdeal(I);
end);

#

#InstallMethod(MeetSemigroupCongruences,
#"for two Rees congruences",
#[IsReesCongruence, IsReesCongruence],
#function(c1, c2)
#
#end);

#

InstallMethod(EquivalenceClasses,
"for a Rees congruence",
[IsReesCongruence],
function(cong)
  local classes, I, next, x;
  classes := EmptyPlist(NrCongruenceClasses(cong));
  I := SemigroupIdealOfReesCongruence(cong);
  classes[1] := EquivalenceClassOfElementNC(cong, I.1);
  next := 2;
  for x in Range(cong) do
    if not (x in I) then
      classes[next] := EquivalenceClassOfElementNC(cong, x);
      next := next + 1;
    fi;
  od;
  return classes;
end);

#

InstallMethod(EquivalenceClassOfElement,
"for a Rees congruence and an associative element",
[IsReesCongruence, IsAssociativeElement],
function(cong, elm)
  # Check that the args make sense
  if not elm in Range(cong) then
    ErrorMayQuit("Semigroups: EquivalenceClassOfElement: usage,\n",
                 "the second arg <elm> must be ",
                 "in the semigroup of first arg <cong>,");
  fi;
  return EquivalenceClassOfElementNC(cong, elm);
end);

#

InstallMethod(EquivalenceClassOfElementNC,
"for a Rees congruence and an associative element",
[IsReesCongruence, IsAssociativeElement],
function(cong, elm)
  local is_ideal_class, fam, class;
  # Ensure consistency of representatives
  if elm in SemigroupIdealOfReesCongruence(cong) then
    is_ideal_class := true;
    elm := SemigroupIdealOfReesCongruence(cong).1;
  else
    is_ideal_class := false;
  fi;

  # Construct the object
  fam := CollectionsFamily(FamilyObj(elm));
  class := Objectify(NewType(fam, IsReesCongruenceClass),
                     rec(is_ideal_class := is_ideal_class));
  SetParentAttr(class, cong);
  SetEquivalenceClassRelation(class, cong);
  SetRepresentative(class, elm);
  return class;
end);

#

InstallMethod(\in,
"for an associative element and a Rees congruence class",
[IsAssociativeElement, IsReesCongruenceClass],
function(elm, class)
  if class!.is_ideal_class then
    return elm in SemigroupIdealOfReesCongruence(Parent(class));
  else
    return elm = Representative(class);
  fi;
end);

#

InstallMethod(\*,
"for two Rees congruence classes",
[IsReesCongruenceClass, IsReesCongruenceClass],
function(c1, c2)
  if not Parent(c1) = Parent(c2) then
    ErrorMayQuit("Semigroups: \\*: usage,\n",
                 "the args <c1> and <c2> must be classes of the same ",
                 "congruence,");
  fi;
  if c1!.is_ideal_class then
    return c1;
  fi;
  if c2!.is_ideal_class then
    return c2;
  fi;
  return EquivalenceClassOfElementNC(Parent(c1),
                                     Representative(c1) * Representative(c2));
end);

#

InstallMethod(Size, "for a Rees congruence class",
[IsReesCongruenceClass],
function(class)
  local rel;

  if class!.is_ideal_class then
    rel := EquivalenceClassRelation(class);
    return Size(SemigroupIdealOfReesCongruence(rel));
  fi;
  return 1;
end);

#

InstallMethod(\=,
"for two Rees congruence classes",
[IsReesCongruenceClass, IsReesCongruenceClass],
function(c1, c2)
  return (Representative(c1) = Representative(c2))
         or (c1!.is_ideal_class and c2!.is_ideal_class);
end);

#

InstallMethod(AsSemigroupCongruenceByGeneratingPairs,
"for a Rees congruence",
[IsReesCongruence],
function(cong)
  local S, gens, min, nrclasses, pairs, y, x;
  S := Range(cong);
  gens := MinimalIdealGeneratingSet(SemigroupIdealOfReesCongruence(cong));
  min := MinimalIdeal(S);
  nrclasses := NrCongruenceClasses(cong);
  pairs := [];
  cong := SemigroupCongruence(S, pairs);
  for y in min do
    for x in gens do
      if not [x, y] in cong then
        Add(pairs, [x, y]);
        cong := SemigroupCongruence(S, pairs);
      fi;
    od;
  od;
  return cong;
end);

#

InstallMethod(GeneratingPairsOfMagmaCongruence,
"for a Rees congruence",
[IsReesCongruence],
function(cong)
  cong := AsSemigroupCongruenceByGeneratingPairs(cong);
  return GeneratingPairsOfSemigroupCongruence(cong);
end);