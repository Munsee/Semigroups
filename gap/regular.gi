#############################################################################
##
#W  regular.gi
#Y  Copyright (C) 2011-12                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

## Methods for Green's classes of regular acting semigroups

# acting...
#############################################################################
#############################################################################

# new for 1.0! - RhoOrbStabChain - "for a regular D-class "
#############################################################################

# not required for inverse.

InstallMethod(RhoOrbStabChain, "for a regular D-class",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  local g;

  g:=SchutzenbergerGroup(d);

  if IsTrivial(g) then 
    return false;
  elif IsNaturalSymmetricGroup(g) and
     NrMovedPoints(g)=ActionRank(Representative(d)) then 
    return true;
  fi;

  return StabChainImmutable(g);
end);

# main... 
##############################################################################
##############################################################################

# new for 1.0! - \in - "for a regular acting semigroup and elt"
##############################################################################

# different method for inverse

InstallMethod(\in, "for an acting elt and regular acting semigroup",
[IsAssociativeElement, IsActingSemigroup and IsRegularSemigroup], 
function(f, s)
  local lambda_o, rho_o, lambda, rho, lambda_l, rho_l, m, schutz, scc, g, rep;

  if not ElementsFamily(FamilyObj(s))=FamilyObj(f) then 
    Error("the element and semigroup are not of the same type,");
    return;
  fi;

  if HasAsSSortedList(s) then 
    return f in AsSSortedList(s); 
  fi;

  lambda_o:=LambdaOrb(s);
  rho_o:=RhoOrb(s);
  lambda:=LambdaFunc(s)(f);
  rho:=RhoFunc(s)(f); 
  lambda_l:=Position(lambda_o, lambda);
  rho_l:=Position(rho_o, rho);

  if (IsClosed(lambda_o) and lambda_l=fail) or 
   (IsClosed(rho_o) and rho_l=fail) then
    return false;
  fi;
  
  if lambda_l=fail then
    lambda_o!.looking:=true; 
    lambda_o!.lookingfor:=function(o, x) return x=lambda; end;
    lambda_o!.lookfunc:=lambda_o!.lookingfor;
    Enumerate(lambda_o);
    lambda_l:=PositionOfFound(lambda_o);
    lambda_o!.found:=false; lambda_o!.looking:=false;
    Unbind(lambda_o!.lookingfor); Unbind(lambda_o!.lookfunc);

    if lambda_l=false then
      return false;
    fi;
  fi;

  if rho_l=fail then
    rho_o!.looking:=true; 
    rho_o!.lookingfor:=function(o, x) return x=rho; end;
    rho_o!.lookfunc:=rho_o!.lookingfor;
    Enumerate(rho_o);
    rho_l:=PositionOfFound(rho_o);
    rho_o!.found:=false; rho_o!.looking:=false;
    Unbind(rho_o!.lookingfor); Unbind(rho_o!.lookfunc);

    if rho_l=false then
      return false;
    fi;
  fi;

  m:=OrbSCCLookup(lambda_o)[lambda_l];
  schutz:=LambdaOrbStabChain(lambda_o, m);

  if schutz=true then
    return true;
  fi;

  scc:=OrbSCC(lambda_o)[m];
  g:=f;
  
  if lambda_l<>scc[1] then 
    g:=g*LambdaOrbMult(lambda_o, m, lambda_l)[2];
  fi;

  if IsIdempotent(g) then 
    return true;
  elif schutz=false then
    return false;
  fi;

  rep:=RectifyRho(s, rho_o, LambdaOrbRep(lambda_o, m));
  #return SiftGroupElement(schutz, LambdaPerm(s)(rep, g)).isone;
  return SiftedPermutation(schutz, LambdaPerm(s)(rep, g))=();
end);

# new for 1.0! - \in - "for acting elt and regular D-class of acting semigp"
#############################################################################
#JDM revise this if revising \in for elt and D-class in greens.gi

InstallMethod(\in, "for acting elt and regular D-class of acting semigp.",
[IsAssociativeElement, IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(f, d)
  local rep, s, g, m, o, scc, l, schutz;

  rep:=Representative(d);
  s:=ParentSemigroup(d);

  # much much better performance using f[2]<>rep[2] below
  if ElementsFamily(FamilyObj(s)) <> FamilyObj(f) 
    or ActionRank(f) <> ActionRank(rep) then
    return false;
  fi;

  g:=f;
  m:=LambdaOrbSCCIndex(d); o:=LambdaOrb(d); scc:=OrbSCC(o);

  l:=Position(o, LambdaFunc(s)(g));

  if l = fail or OrbSCCLookup(o)[l]<>m then
    return false;
  fi;

  if l<>scc[m][1] then
    g:=g*LambdaOrbMult(o, m, l)[2];
  fi;

  m:=RhoOrbSCCIndex(d); o:=RhoOrb(d); scc:=OrbSCC(o);

  l:=Position(o, RhoFunc(s)(g));

  if l = fail or OrbSCCLookup(o)[l]<>m then
    return false;
  fi;

  schutz:=RhoOrbStabChain(d);

  if schutz=true then
    return true;
  fi;

  if l<>scc[m][1] then
    g:=RhoOrbMult(o, m, l)[2]*g;
  fi;

  if g=rep then 
    return true;
  elif schutz=false then 
    return false;
  fi;

  #return SiftGroupElement(schutz, LambdaPerm(s)(rep, g)).isone;
  return SiftedPermutation(schutz, LambdaPerm(s)(rep, g))=();
end);

#DDD

# new for 1.0! - DClassReps - "for a regular acting semigroup"
##############################################################################

# same method for inverse.

# Note that these are not rectified!

InstallOtherMethod(DClassReps, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  local o, r, out, m;

  o:=LambdaOrb(s);
  r:=Length(OrbSCC(o));
  out:=EmptyPlist(r);

  for m in [2..r] do 
    out[m-1]:=LambdaOrbRep(o, m);
  od;
  return out;
end);

# new for 1.0! - HClassReps - for regular acting semi
############################################################################

# different method for inverse.

InstallOtherMethod(HClassReps, "for a regular acting semigroup", 
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  local lambda_o, lambda_scc, rho_o, rho_scc, len, lookup, rhofunc, out, n, lambda_mults, f, rho_l, rho_m, rho_mults, lambda_m, j, k;
  
  lambda_o:=Enumerate(LambdaOrb(s), infinity);
  lambda_scc:=OrbSCC(lambda_o);
  rho_o:=Enumerate(RhoOrb(s), infinity);
  rho_scc:=OrbSCC(rho_o);

  len:=Length(lambda_scc);
  lookup:=OrbSCCLookup(rho_o);
  rhofunc:=RhoFunc(s);

  out:=EmptyPlist(NrHClasses(s));
  n:=0;

  for lambda_m in [2..len] do
    lambda_mults:=LambdaOrbMults(lambda_o, lambda_m);
    f:=LambdaOrbRep(lambda_o, lambda_m);
    rho_l:=Position(rho_o, rhofunc(f));
    rho_m:=lookup[rho_l];
    rho_mults:=RhoOrbMults(rho_o, rho_m);
    f:=rho_mults[rho_l][2]*f;
    for j in lambda_scc[lambda_m] do
      f:=f*lambda_mults[j][1];
      for k in rho_scc[rho_m] do
        n:=n+1;
        out[n]:=rho_mults[k][1]*f;
      od;
    od;
  od;
  return out;
end);

# new for 1.0! - HClassReps - "for a regular D-class of an acting semigroup"
##############################################################################
  
# different method for inverse
 
InstallOtherMethod(HClassReps, "for a regular D-class of an acting semigroup",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  local o, m, lambda_scc, lambda_mults, rho_scc, rho_mults, f, out, k, g, i, j;
  
  o:=LambdaOrb(d); 
  m:=LambdaOrbSCCIndex(d);
  lambda_scc:=OrbSCC(o)[m];
  lambda_mults:=LambdaOrbMults(o, m);

  o:=RhoOrb(d);
  m:=RhoOrbSCCIndex(d);
  rho_scc:=OrbSCC(o)[m];
  rho_mults:=RhoOrbMults(o, m);

  f:=Representative(d);
  
  out:=EmptyPlist(Length(lambda_scc)*Length(rho_scc));
  k:=0;
  
  for i in lambda_scc do
    g:=f*lambda_mults[i][1];
    for j in rho_scc do 
      k:=k+1;
      out[k]:=rho_mults[j][1]*g;
    od;
  od;
  return out;
end);

# new for 1.0! - HClassReps - "for a regular L-class of an acting semigroup"
##############################################################################
  
# different method for inverse
  
InstallOtherMethod(HClassReps, "for a regular  L-class of an acting semigroup",
[IsRegularClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, out, k, i;
  
  o:=RhoOrb(l); 
  m:=RhoOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=RhoOrbMults(o, m);
  f:=Representative(l);

  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for i in scc do
    k:=k+1;
    out[k]:=mults[i][1]*f;
  od;
  return out;
end);

# new for 1.0! - HClassReps - "for a regular R-class of an acting semigroup"
##############################################################################

# same method for inverse

InstallOtherMethod(HClassReps, "for a regular R-class of an acting semigroup",
[IsRegularClass and IsGreensRClass and IsActingSemigroupGreensClass],
function(l)
  local o, m, scc, mults, f, out, k, i;
  
  o:=LambdaOrb(l); 
  m:=LambdaOrbSCCIndex(l);
  scc:=OrbSCC(o)[m];
  mults:=LambdaOrbMults(o, m);
  f:=Representative(l);
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for i in scc do
    k:=k+1;
    out[k]:=f*mults[i][1];
  od;
  return out;
end);

# new for 1.0! - LClassReps - "for regular acting semigroup 
###############################################################################

# note that the rho values of these reps are not rectified!

# same method for inverse

InstallOtherMethod(LClassReps, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local o, scc, len, out, n, f, mults, m, j;
  
  o:=LambdaOrb(s);
  scc:=OrbSCC(o);

  len:=Length(scc);
  out:=EmptyPlist(NrLClasses(s));
  n:=0;

  for m in [2..len] do
    f:=LambdaOrbRep(o, m);
    mults:=LambdaOrbMults(o, m);
    for j in scc[m] do
      n:=n+1;
      out[n]:=f*mults[j][1];
    od;
  od;
  return out;
end);

# new for 1.0! - LClassReps - "for a regular D-class of acting semigroup 
###############################################################################

# same method for inverse

InstallOtherMethod(LClassReps, "for a regular D-class of acting semigroup",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  local o, m, mults, scc, f, out, k, j;

  o:=LambdaOrb(d);
  m:=LambdaOrbSCCIndex(d);
  mults:=LambdaOrbMults(o, m);
  scc:=LambdaOrbSCC(d);
  f:=Representative(d);

  out:=EmptyPlist(Length(scc));

  k:=0;
  for j in scc do
    k:=k+1;
    out[k]:=f*mults[j][1];
  od;
  return out;
end);

# new for 1.0! - RClassReps - "for regular acting semigroup 
###############################################################################

# different method for inverse

# note that these are not rectified!!

InstallOtherMethod(RClassReps, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local lambda_o, rho_o, scc, len, out, n, f, mults, m, j;
  
  lambda_o:=LambdaOrb(s);
  rho_o:=RhoOrb(s);
  scc:=OrbSCC(rho_o);

  len:=Length(scc);
  out:=EmptyPlist(NrRClasses(s));
  n:=0;

  for m in [2..len] do
    f:=RhoOrbRep(rho_o, m);
    mults:=RhoOrbMults(rho_o, m);
    for j in scc[m] do
      n:=n+1;
      out[n]:=mults[j][1]*f;
    od;
  od;
  return out;
end);

# new for 1.0! - RClassReps - "for regular D-class of acting semigroup 
###############################################################################

# different method for inverse

InstallOtherMethod(RClassReps, "for a D-class of an acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
function(d)
  local o, m, mults, scc, f, out, k, i;

  o:=RhoOrb(d);
  m:=RhoOrbSCCIndex(d);
  mults:=RhoOrbMults(o, m);
  scc:=RhoOrbSCC(d);
  f:=Representative(d);

  out:=EmptyPlist(Length(scc));
  k:=0;
  for i in scc do
    k:=k+1;
    out[k]:=mults[i][1]*f;
  od;
  return out;
end);

#EEE

# mod for 1.0! - Enumerator - "for D-class of regular acting semigp."
#############################################################################

# different method for inverse

InstallOtherMethod(Enumerator, "for a regular D-class of acting semigp.",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
    
    return EnumeratorByFunctions(d, rec(

    schutz:=Enumerator(SchutzenbergerGroup(d)),

    #######################################################################

    ElementNumber:=function(enum, pos)
      local l_scc, r_scc, i, j, k, x, y, z, lmults, rmults;
      if pos>Length(enum) then
        return fail;
      fi;

      if pos<=Length(enum!.schutz) then 
        return Representative(d)*enum!.schutz[pos];
      fi;

      l_scc:=LambdaOrbSCC(d);
      r_scc:=RhoOrbSCC(d);

      pos:=pos-1; 
      
      i:=Length(enum!.schutz); 
      j:=Length(l_scc);
      k:=Length(r_scc);

      x:=QuoInt(pos, i*j); 
      y:=QuoInt(pos-x*i*j, i);
      z:=pos-x*i*j-y*i;

      lmults:=LambdaOrbMults(LambdaOrb(d), LambdaOrbSCCIndex(d));
      rmults:=RhoOrbMults(RhoOrb(d), RhoOrbSCCIndex(d));
      
      return rmults[r_scc[x+1]][1]*enum[z+1]*lmults[l_scc[y+1]][1];
    end,

    #######################################################################

    NumberElement:=function(enum, f)
      local rep, s, o, m, x, y, z, i, j, k, g; 
      
      rep:=Representative(d);

      if ActionRank(f)<>ActionRank(rep) then
        return fail;
      fi;

      if f=rep then
        return 1;
      fi;

      s:=ParentSemigroup(d);
      
      o:=RhoOrb(d); m:=RhoOrbSCCIndex(d);
      x:=Position(o, RhoFunc(s)(f));

      if x=fail or OrbSCCLookup(o)[x]<>m then
        return fail;
      fi;

      g:=f;
      
      if x<>OrbSCC(o)[m][1] then 
        g:=RhoOrbMult(o, m, x)[2]*g;
      fi;
      
      o:=LambdaOrb(d); m:=LambdaOrbSCCIndex(d);
      y:=Position(o, LambdaFunc(s)(g));

      if y=fail or OrbSCCLookup(o)[y]<>m then
        return fail;
      fi;

      if y<>OrbSCC(o)[m][1] then 
        g:=g*LambdaOrbMult(o, m, y)[2];
      fi;
   
      z:=Position(enum!.schutz, LambdaPerm(s)(rep, g));

      if z=fail then
        return fail;
      fi;
      
      i:=Length(enum!.schutz); 
      j:=Length(LambdaOrbSCC(d));
      k:=Length(RhoOrbSCC(d));

      return i*j*(Position(RhoOrbSCC(d), x)-1)+(Position(LambdaOrbSCC(d),
      y)-1)*i+z;
    end,

    #######################################################################

    Membership:=function(elm, enum)
      return elm in d;
    end,

    Length:=enum -> Size(d),

    PrintObj:=function(enum)
      Print( "<enumerator of D-class>");
    return;
  end));
end);

#GGG

# new for 1.0! - GreensDClasses - for regular acting semi
############################################################################

# different method for inverse.

InstallOtherMethod(GreensDClasses, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  local lambda_o, rho_o, len, out, type, drel, d, rectify, m;

  lambda_o:=LambdaOrb(s);
  rho_o:=RhoOrb(s);
  
  len:=Length(OrbSCC(lambda_o)); 
  out:=EmptyPlist(len-1);
  
  type:=DClassType(s);
  drel:=GreensDRelation(s);

  for m in [2..len] do 
    rectify:=RectifyRho(s, rho_o, LambdaOrbRep(lambda_o, m));
    out[m-1]:=CreateDClassNC(s, m, lambda_o, rectify.m, rho_o, rectify.rep,
     false);
  od;
  return out;
end);

# new for 1.0! - GreensHClasses - for regular acting semi
############################################################################

# different method for inverse.

InstallOtherMethod(GreensHClasses, "for a regular acting semigroup", 
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local lambda_o, lambda_scc, rho_o, rho_scc, len, lookup, rhofunc, out, type, hrel, n, lambda_mults, f, rho_l, rho_m, rho_mults, lambda_m, j, k;

  lambda_o:=Enumerate(LambdaOrb(s), infinity);
  lambda_scc:=OrbSCC(lambda_o);
  rho_o:=Enumerate(RhoOrb(s), infinity);
  rho_scc:=OrbSCC(rho_o);

  len:=Length(lambda_scc);
  lookup:=OrbSCCLookup(rho_o);
  rhofunc:=RhoFunc(s);

  out:=EmptyPlist(NrHClasses(s));
  type:=HClassType(s);
  hrel:=GreensHRelation(s);
  n:=0;

  for lambda_m in [2..len] do
    lambda_mults:=LambdaOrbMults(lambda_o, lambda_m);
    f:=LambdaOrbRep(lambda_o, lambda_m);
    rho_l:=Position(rho_o, rhofunc(f));
    rho_m:=lookup[rho_l];
    rho_mults:=RhoOrbMults(rho_o, rho_m);
    f:=rho_mults[rho_l][2]*f;
    for j in lambda_scc[lambda_m] do
      f:=f*lambda_mults[j][1];
      for k in rho_scc[rho_m] do
        n:=n+1;
        # JDM maybe a bad idea to use CreateHClass here, perhaps expand?
        out[n]:=CreateHClass(s, lambda_m, lambda_o, rho_m, rho_o,
         rho_mults[k][1]*f, false);
      od;
    od;
  od;
  return out;
end);

# new for 1.0! - GreensHClasses - "for D-class of regular acting semigroup"
##############################################################################

# different method for inverse

InstallOtherMethod(GreensHClasses, "for D-class of regular acting semigroup",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  local lambda_o, lambda_m, lambda_scc, lambda_mults, rho_o, rho_m, rho_scc,
  rho_mults, f, nc, s, out, k, g, i, j;
  
  lambda_o:=LambdaOrb(d); 
  lambda_m:=LambdaOrbSCCIndex(d);
  lambda_scc:=OrbSCC(lambda_o)[lambda_m];
  lambda_mults:=LambdaOrbMults(lambda_o, lambda_m);

  rho_o:=RhoOrb(d);
  rho_m:=RhoOrbSCCIndex(d);
  rho_scc:=OrbSCC(rho_o)[rho_m];
  rho_mults:=RhoOrbMults(rho_o, rho_m);

  f:=Representative(d);
  nc:=IsGreensClassNC(d);
  s:=ParentSemigroup(d);
 
  out:=EmptyPlist(Length(lambda_scc)*Length(rho_scc));
  k:=0;
  
  for i in lambda_scc do
    g:=f*lambda_mults[i][1];
    for j in rho_scc do 
      k:=k+1;
      out[k]:=CreateHClass(s, lambda_m, lambda_o, rho_m, rho_o, 
       rho_mults[j][1]*g, nc);
    od;
  od;
  return out;
end);

# new for 1.0! - GreensHClasses - "for L-class of regular acting semigroup"
##############################################################################

# different method for inverse

InstallOtherMethod(GreensHClasses, "for L-class of regular acting semigroup",
[IsRegularClass and IsGreensLClass and IsActingSemigroupGreensClass],
function(l)
  local rho_o, rho_m, scc, mults, f, nc, s, lambda_o, lambda_l, lambda_m, out,
  k, j;

  rho_o:=RhoOrb(l);
  rho_m:=RhoOrbSCCIndex(l);
  scc:=OrbSCC(rho_o)[rho_m];
  mults:=RhoOrbMults(rho_o, rho_m);

  f:=Representative(l);
  nc:=IsGreensClassNC(l);
  s:=ParentSemigroup(l);

  if HasLambdaOrb(s) and IsClosed(LambdaOrb(s)) and not nc then 
    lambda_o:=LambdaOrb(s);
    lambda_l:=Position(lambda_o, LambdaFunc(s)(f));
  else
    lambda_o:=GradedLambdaOrb(s, f, nc<>true);
    lambda_l:=LambdaPos(lambda_o);
  fi;
  lambda_m:=OrbSCCLookup(lambda_o)[lambda_l];

  out:=EmptyPlist(Length(scc));
  k:=0;
 
  for j in scc do
    k:=k+1;
    out[k]:=CreateHClass(s, lambda_m, lambda_o, rho_m, rho_o,
     mults[j][1]*f, nc);
    SetLClassOfHClass(out[k], l);
  od;
  
  return out;
end);

# new for 1.0! - GreensHClasses - "for R-class of regular acting semigroup"
##############################################################################

# different method for inverse

InstallOtherMethod(GreensHClasses, "for R-class of regular acting semigroup",
[IsRegularClass and IsGreensRClass and IsActingSemigroupGreensClass],
function(r)
  local lambda_o, lambda_m, scc, mults, f, nc, s, rho_o, rho_l, rho_m, out, k, j;

  lambda_o:=LambdaOrb(r);
  lambda_m:=LambdaOrbSCCIndex(r);
  scc:=OrbSCC(lambda_o)[lambda_m];
  mults:=LambdaOrbMults(lambda_o, lambda_m);

  f:=Representative(r);
  nc:=IsGreensClassNC(r);
  s:=ParentSemigroup(r);

  if HasRhoOrb(s) and IsClosed(RhoOrb(s)) and not nc then 
    rho_o:=RhoOrb(s);
    rho_l:=Position(rho_o, RhoFunc(s)(f));
  else
    rho_o:=GradedRhoOrb(s, f, nc<>true);
    rho_l:=RhoPos(rho_o);
  fi;
  rho_m:=OrbSCCLookup(rho_o)[rho_l];

  out:=EmptyPlist(Length(scc));
  k:=0;
 
  for j in scc do
    k:=k+1;
    out[k]:=CreateHClass(s, lambda_m, lambda_o, rho_m, rho_o,
     f*mults[j][1], nc);
    SetLClassOfHClass(out[k], r);
  od;
  
  return out;
end);

# new for 0.7! - GreensLClasses - for regular acting semigroup
##############################################################################

# different method for inverse

InstallOtherMethod(GreensLClasses, "for a regular acting semigroup", 
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local rho_o, lambda_o, lambda_scc, len, out, n, rectify, m, f, mults, lambda_m, j;
  
  rho_o:=RhoOrb(s);
  lambda_o:=LambdaOrb(s);
  lambda_scc:=OrbSCC(lambda_o);

  len:=Length(lambda_scc);

  out:=EmptyPlist(NrLClasses(s));
  n:=0;

  for lambda_m in [2..len] do
    rectify:=RectifyRho(s, rho_o, LambdaOrbRep(lambda_o, lambda_m));
    m:=rectify.m; 
    f:=rectify.rep;
    mults:=LambdaOrbMults(lambda_o, lambda_m);
    for j in lambda_scc[lambda_m] do
      n:=n+1;
      # use NC here to avoid running RectifyRho repeatedly in this loop
      # maybe expand this to not use CreateLClassNC JDM?
      out[n]:=CreateLClassNC(s, m, rho_o, f*mults[j][1], false);
    od;
  od;
  return out;
end);

# new for 0.7! - GreensLClasses - for regular D-class ofacting semigroup
##############################################################################

# different method for inverse.

InstallOtherMethod(GreensLClasses, "for regular D-class of acting semigroup", 
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
function(d)
  local f, s, o, m, nc, scc, mults, out, k, i;
  
  f:=Representative(d);
  s:=ParentSemigroup(d);
  o:=RhoOrb(d);
  m:=RhoOrbSCCIndex(d);
  nc:=IsGreensClassNC(d);
  scc:=LambdaOrbSCC(d);
  mults:=LambdaOrbMults(LambdaOrb(d), LambdaOrbSCCIndex(d));
  
  out:=EmptyPlist(Length(scc));
  k:=0;
  
  for i in scc do
    k:=k+1;
    #use NC since f has rho value in first place of scc
    #JDM maybe don't use CreateLClassNC here, and rather expand!
    out[k]:=CreateLClassNC(s, m, o, f*mults[i][1], nc);
    SetDClassOfLClass(out[k], d);
  od;

  return out;
end);

# new for 0.7! - GreensRClasses - for regular acting semigroup
##############################################################################

# different method for inverse 

InstallOtherMethod(GreensRClasses, "for a regular acting semigroup", 
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local rho_o, rho_scc, lambda_o, lambda_scc, len, lookup, lambdafunc, out, n, f, lambda_l, lambda_m, mults, rho_m, j;
  
  rho_o:=RhoOrb(s);
  rho_scc:=OrbSCC(rho_o);
  lambda_o:=LambdaOrb(s);
  lambda_scc:=OrbSCC(lambda_o);

  len:=Length(rho_scc);
  lookup:=OrbSCCLookup(lambda_o);
  lambdafunc:=LambdaFunc(s);

  out:=EmptyPlist(NrRClasses(s));
  n:=0;

  for rho_m in [2..len] do
    f:=RhoOrbRep(rho_o, rho_m);
    lambda_l:=Position(lambda_o, lambdafunc(f));
    lambda_m:=lookup[lambda_l];
    f:=f*LambdaOrbMult(lambda_o, lambda_m, lambda_l)[2];
    mults:=RhoOrbMults(rho_o, rho_m);
    for j in rho_scc[rho_m] do
      n:=n+1;
      out[n]:=CreateRClassNC(s, lambda_m, lambda_o, mults[j][1]*f, false);
    od;
  od;
  return out;
end);

# new for 1.0! - GreensRClasses - "for a regular D-class of acting semigroup"
##############################################################################

# different method for inverse

InstallMethod(GreensRClasses, "for a regular D-class of acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
function(d)
  local mults, scc, f, s, o, m, nc, out, k, i;

  mults:=RhoOrbMults(RhoOrb(d), RhoOrbSCCIndex(d));
  scc:=RhoOrbSCC(d);
  f:=Representative(d);

  s:=ParentSemigroup(d);
  o:=LambdaOrb(d);
  m:=LambdaOrbSCCIndex(d);
  nc:=IsGreensClassNC(d);

  out:=EmptyPlist(Length(scc));

  k:=0;
  for i in scc do
    k:=k+1;
    out[k]:=CreateRClassNC(s, m, o, mults[i][1]*f, nc);
  od;

  return out;
end);

# new for 1.0! - GreensRClassOfElement - for regular acting semi and elt"
############################################################################

# same method for inverse.

InstallOtherMethod(GreensRClassOfElement, "for regular acting semi and elt",
[IsRegularSemigroup and IsActingSemigroup, IsAssociativeElement],
function(s, f)
  local o;

  if not f in s then 
    Error("the element does not belong to the semigroup,");
    return;
  fi;
  
  if HasLambdaOrb(s) and IsClosed(LambdaOrb(s)) then 
    o:=LambdaOrb(s);
  else
    o:=GradedLambdaOrb(s, f, true);
  fi;

  return CreateRClass(s, fail, o, f, false); 
end);

#III

# new for 1.0! - IteratorOfDClassData - "for regular acting semigroup"
###############################################################################
# JDM review this...

# the first part of this could really be a method for IteratorOfGradedLambdaOrbs

# same method for inverse

InstallMethod(IteratorOfDClassData, "for regular acting semigp",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
local iter;

  if not IsClosed(LambdaOrb(s)) then 
    #JDM next 3 lines still necessary?
    if Length(LambdaOrb(s))=1 then 
      Enumerate(LambdaOrb(s), 2);
    fi;
    iter:=IteratorByFunctions( rec(

      last_called_by_is_done:=false,

      next_value:=fail,

      seen:=HTCreate([1,1],
       rec(forflatplainlists:=true, hashlen:=s!.opts.hashlen.S)),
      
      o:=GradedLambdaOrb(s, LambdaOrb(s)!.gens[1], true),

      m:=0,

      IsDoneIterator:=function(iter)
        local m, seen, lambda_o, new, val, f, i;  

        if iter!.last_called_by_is_done then 
          return iter!.next_value=fail;
        fi;

        iter!.last_called_by_is_done:=true;
        iter!.next_value:=fail;

        m:=iter!.m;
        
        if m=Length(OrbSCC(iter!.o)) then 
          m:=1;
          seen:=iter!.seen;
          # look for a new lambda value
          lambda_o:=LambdaOrb(s);

          # check existing lambda values
          new:=false;
          for i in [2..Length(lambda_o)] do 
            val:=Position(GradedLambdaOrbs(s), lambda_o[i]);
            if val=fail or HTValue(seen, val{[1,2]})=fail then          
              new:=i;
              break;
            fi;
          od;

          # look for new lambda value
          if new=false then  
            lambda_o!.looking:=true;
            lambda_o!.lookingfor:=
              function(o, x) 
                local val;
                val:=Position(GradedLambdaOrbs(s), x);
                return val=fail or HTValue(seen, val{[1,2]})=fail; 
              end;
            lambda_o!.lookfunc:=lambda_o!.lookingfor;
            Enumerate(lambda_o);
            new:=PositionOfFound(lambda_o);
            lambda_o!.found:=false; lambda_o!.looking:=false;
            Unbind(lambda_o!.lookingfor); Unbind(lambda_o!.lookfunc);
          fi;

          if new=false then 
            return true;
          fi;
          
          val:=Position(GradedLambdaOrbs(s), lambda_o[new]);
          if val<>fail then 
            iter!.o:=GradedLambdaOrbs(s)[val[1]][val[2]];
            HTAdd(seen, val{[1,2]}, true);
          else
            iter!.o:=GradedLambdaOrb(s,
             EvaluateWord(lambda_o!.gens, TraceSchreierTreeForward(lambda_o,
             new)), true);
            HTAdd(seen, iter!.o!.val{[1,2]}, true);
          fi;
        else
          m:=m+1;
        fi;
        iter!.m:=m; 
        
        f:=LambdaOrbRep(iter!.o, m)*
         LambdaOrbMult(iter!.o, m, iter!.o!.lambda_l)[2]; 
         if IsActingSemigroupWithInverseOp(s) then 
           iter!.next_value:=[s, m, iter!.o, fail, fail, f, false];
         else
           iter!.next_value:=[s, m, iter!.o, 1, GradedRhoOrb(s, f, false), f, 
            false];
         fi;
        return false;
      end,

      NextIterator:=function(iter)
        if not iter!.last_called_by_is_done then
          IsDoneIterator(iter);
        fi;
        iter!.last_called_by_is_done:=false;
        return iter!.next_value;
      end,

      ShallowCopy:=iter-> rec( last_called_by_is_done:=false,
      next_value:=fail,
      seen:=HTCreate([1,1],
       rec(forflatplainlists:=true, hashlen:=s!.opts.hashlen.S)),
      o:=GradedLambdaOrb(s, LambdaOrb(s)!.gens[1], true),
      m:=0)));

    HTAdd(iter!.seen, iter!.o!.val{[1,2]}, true);
  else ####

    iter:=IteratorByFunctions( rec(
                 
      m:=1, 
     
      i:=0,      

      scc_limit:=Length(OrbSCC(LambdaOrb(s))),

      IsDoneIterator:=iter-> iter!.m=iter!.scc_limit,

      NextIterator:=function(iter)
        local m, o, f, scc; 
        m:=iter!.m; 

        if m=iter!.scc_limit then
          return fail; 
        fi;

        o:=LambdaOrb(s); scc:=OrbSCC(o);

        m:=m+1;
        iter!.m:=m;
 
        # f ok here? JDM
        f:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, scc[m][1])); 
        if IsActingSemigroupWithInverseOp(s) then 
          return [s, m, LambdaOrb(s), fail, fail, f, false];
        else
          return [s, m, LambdaOrb(s), 1, GradedLambdaOrb(s, f, false), false];
        fi;
      end,

      #JDM fill this in!
      ShallowCopy:=iter-> rec()));
  fi;
  return iter;
end);
# new for 0.7! - IteratorOfLClassData - "for a regular acting semigroup
###############################################################################

# no method required for inverse (use IteratorOfRClassData instead)

InstallMethod(IteratorOfLClassData, "for regular acting semigp",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
local iter, scc;

  if not IsClosed(LambdaOrb(s)) then 
    
    iter:=IteratorByFunctions( rec(

      i:=1,

      IsDoneIterator:=iter-> IsClosed(LambdaOrb(s)) and 
       iter!.i>=Length(LambdaOrb(s)),

      NextIterator:=function(iter)
        local i, o, r, f;
        
        o:=LambdaOrb(s); i:=iter!.i;

        if IsClosed(o) and i>=Length(o) then 
          return fail;  
        fi;
        
        i:=i+1;
        
        if i>Length(o) then 
          if not IsClosed(o) then 
            Enumerate(o, i);
            if i>Length(o) then 
              return fail;
            fi;
          else 
            return fail;
          fi;
        fi;

        iter!.i:=i; 
        f:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, i));
        return [s, fail, GradedRhoOrb(s, f, true), f, false];
      end,

      ShallowCopy:=iter-> rec(i:=1)));
  else ####

    scc:=OrbSCC(LambdaOrb(s));

    iter:=IteratorByFunctions( rec(
                 
      m:=1, 
     
      i:=0,      

      scc_limit:=Length(scc),

      i_limit:=Length(scc[Length(scc)]),

      IsDoneIterator:=iter-> iter!.m=iter!.scc_limit and 
       iter!.i=iter!.i_limit,

      NextIterator:=function(iter)
        local i, o, m, scc, f, r, mults;
        
        i:=iter!.i; 
        m:=iter!.m; 

        if m=iter!.scc_limit and i=iter!.i_limit then
          return fail; 
        fi;

        o:=LambdaOrb(s); scc:=OrbSCC(o);

        if i<Length(scc[m]) then 
          i:=i+1;
        else
          i:=1; m:=m+1;
        fi;

        iter!.i:=i; iter!.m:=m;
 
        return [s, fail, RhoOrb(s), LambdaOrbRep(o, m), false];
      end,

      ShallowCopy:=iter-> rec(m:=1, i:=0,
      scc_limit:=iter!.scc_limit, i_limit:=iter!.i_limit)));
  fi;
  
  return iter;
end);

# new for 0.7! - IteratorOfRClassData - "for a regular acting semigroup
###############################################################################

# different method for inverse

InstallMethod(IteratorOfRClassData, "for regular acting semigp",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
local iter, scc;

  if not IsClosed(RhoOrb(s)) then 
    
    iter:=IteratorByFunctions( rec(

      i:=1,

      IsDoneIterator:=iter-> IsClosed(RhoOrb(s)) and 
       iter!.i>=Length(RhoOrb(s)),

      NextIterator:=function(iter)
        local i, o, r, f;
        
        o:=RhoOrb(s); i:=iter!.i;

        if IsClosed(o) and i>=Length(o) then 
          return fail;  
        fi;
        
        i:=i+1;
        
        if i>Length(o) then 
          if not IsClosed(o) then 
            Enumerate(o, i);
            if i>Length(o) then 
              return fail;
            fi;
          else 
            return fail;
          fi;
        fi;

        iter!.i:=i; 
        f:=EvaluateWord(o!.gens, TraceSchreierTreeForward(o, i)); 
        return [s, fail, GradedLambdaOrb(s, f, true), f, false]; 
      end,

      ShallowCopy:=iter-> rec(i:=1)));
  else ####

    scc:=OrbSCC(RhoOrb(s));

    iter:=IteratorByFunctions( rec(
                 
      m:=1, 
     
      i:=0,      

      scc_limit:=Length(scc),

      i_limit:=Length(scc[Length(scc)]),

      IsDoneIterator:=iter-> iter!.m=iter!.scc_limit and 
       iter!.i=iter!.i_limit,

      NextIterator:=function(iter)
        local i, o, m, scc, f, r, mults;
        
        i:=iter!.i; 
        m:=iter!.m; 

        if m=iter!.scc_limit and i=iter!.i_limit then
          return fail; 
        fi;

        o:=RhoOrb(s); scc:=OrbSCC(o);

        if i<Length(scc[m]) then 
          i:=i+1;
        else
          i:=1; m:=m+1;
        fi;

        iter!.i:=i; iter!.m:=m;
 
        return [s, fail, LambdaOrb(s), RhoOrbRep(o, m), false];
      end,

      ShallowCopy:=iter-> rec(m:=1, i:=0,
      scc_limit:=iter!.scc_limit, i_limit:=iter!.i_limit)));
  fi;
  
  return iter;
end);

# new for 0.7! - IteratorOfDClassReps - "for a regular acting semigroup"
###############################################################################

# same method for inverse

InstallMethod(IteratorOfDClassReps, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  if HasDClassReps(s) then
    return IteratorList(DClassReps(s));
  fi;
  return IteratorByIterator(IteratorOfDClassData(s), x-> x[6],
   [IsIteratorOfDClassReps]);
end);

# new for 0.7! - IteratorOfDClasses - "for a regular acting semigroup"
###############################################################################

# same method for inverse

InstallMethod(IteratorOfDClasses, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  if HasGreensDClasses(s) then
    return IteratorList(GreensDClasses(s));
  fi;
  return IteratorByIterator(IteratorOfDClassData(s), x->
   CallFuncList(CreateDClassNC, x), [IsIteratorOfDClasses]);
end);

# new for 0.7! - IteratorOfLClassReps - "for a regular acting semigroup"
###############################################################################

# different method for inverse

InstallMethod(IteratorOfLClassReps, "for a regular acting semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup],
s-> IteratorByIterator(IteratorOfLClassData(s), x-> x[4],
[IsIteratorOfLClassReps]));

# new for 0.7! - IteratorOfLClasses - "for a part perm inverse semigroup"
###############################################################################

# different method for inverse

InstallMethod(IteratorOfLClasses, "for a part perm inverse semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup],
s-> IteratorByIterator(IteratorOfLClassData(s), x->
CallFuncList(CreateLClass, x), [IsIteratorOfLClasses]));

# new for 0.7! - IteratorOfRClasses - "for regular acting semigroup 
###############################################################################

# same method for inverse

InstallMethod(IteratorOfRClasses, "for regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
s-> IteratorByIterator(IteratorOfRClassData(s), x->
CallFuncList(CreateRClass, x), [IsIteratorOfRClasses]));

#NNN

# new for 1.0! - NrDClasses - "for a regular acting semigroup"
############################################################################

# same method for inverse semigroups

InstallMethod(NrDClasses, "for a regular acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup and IsRegularSemigroup],
function(s)
  local o;
  o:=Enumerate(LambdaOrb(s), infinity);
  return Length(OrbSCC(o))-1;
end);

# new for 1.0! - NrHClasses - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallMethod(NrHClasses, "for a regular acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup and IsRegularSemigroup],
function(s)
  local lambda_o, rho_o, nr, lambda_scc, rho_scc, r, i, rhofunc, lookup, rho, m;
  
  lambda_o:=Enumerate(LambdaOrb(s), infinity);
  rho_o:=Enumerate(RhoOrb(s), infinity);
  
  nr:=0;
  lambda_scc:=OrbSCC(lambda_o);
  rho_scc:=OrbSCC(rho_o);
  r:=Length(lambda_scc);
  rhofunc:=RhoFunc(s);
  lookup:=OrbSCCLookup(rho_o);

  for m in [2..r] do 
    rho:=rhofunc(LambdaOrbRep(lambda_o, m));
    nr:=nr+Length(lambda_scc[m])*Length(rho_scc[lookup[Position(rho_o, rho)]]);
  od;

  return nr;
end);

# new for 1.0! - NrHClasses - "for a D-class of regular acting semigroup"
############################################################################

# different method for inverse.

InstallOtherMethod(NrHClasses, "for a D-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
d-> Length(LambdaOrbSCC(d))*Length(RhoOrbSCC(d)));

# new for 1.0! - NrHClasses - "for a L-class of regular acting semigroup"
############################################################################

# different method for inverse semigroups 

InstallOtherMethod(NrHClasses, "for a L-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensLClass],
l-> Length(RhoOrbSCC(l)));

# new for 1.0! - NrHClasses - "for a R-class of regular acting semigroup"
############################################################################

# same method for inverse semigroups 

InstallOtherMethod(NrHClasses, "for a R-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensRClass],
r-> Length(LambdaOrbSCC(r)));

# new for 1.0! - NrLClasses - "for a regular acting semigroup"
############################################################################

# same method for inverse semigroups

InstallMethod(NrLClasses, "for a regular acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup and IsRegularSemigroup],
s-> Length(Enumerate(LambdaOrb(s), infinity))-1);

# new for 1.0! - NrLClasses - "for a D-class of regular acting semigroup"
############################################################################

# same method for inverse semigroups

InstallOtherMethod(NrLClasses, "for a D-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
d-> Length(LambdaOrbSCC(d)));

# new for 1.0! - NrRClasses - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallMethod(NrRClasses, "for a regular acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup and IsRegularSemigroup],
s-> Length(Enumerate(RhoOrb(s), infinity))-1);

# new for 1.0! - NrRClasses - "for a D-class of regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallOtherMethod(NrRClasses, "for a D-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensDClass],
d-> Length(RhoOrbSCC(d)));

# new for 1.0! - NrIdempotents - for a regular acting semigroup
############################################################################

# different method for inverse

InstallOtherMethod(NrIdempotents, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  local nr, tester, rho_o, scc, lambda_o, gens, rhofunc, lookup, rep, rho, j,
  i, k;

  nr:=0;
  tester:=IdempotentLambdaRhoTester(s);
  rho_o:=RhoOrb(s);
  scc:=OrbSCC(rho_o); 
  lambda_o:=LambdaOrb(s);
  gens:=lambda_o!.gens;
  rhofunc:=RhoFunc(s);
  lookup:=OrbSCCLookup(rho_o);

  for i in [1..Length(lambda_o)] do
    rep:=EvaluateWord(TraceSchreierTreeForward(lambda_o, i), gens);
    rho:=rhofunc(rep);
    j:=lookup[Position(rho_o, rho)];
    for k in scc[j] do
      if tester(lambda_o[i], rho_o[k]) then
        nr:=nr+1;
      fi;
    od;
  od;

  return nr;
end);

# new for 1.0! - NrRegularDClasses - "for a regular acting semigroup"
############################################################################

# same method for inverse semigroups

InstallMethod(NrRegularDClasses, "for a regular acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup and IsRegularSemigroup],
NrDClasses);

#PPP

# new for 1.0! - PartialOrderOfDClasses - "for a regular acting semigroup" 
############################################################################## 

# different method for inverse

InstallMethod(PartialOrderOfDClasses, "for a regular acting semigp",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local d, n, out, o, gens, lookup, lambdafunc, i, x, f;

  d:=GreensDClasses(s);
  n:=Length(d);
  out:=List([1..n], x-> EmptyPlist(n));
  o:=LambdaOrb(s);
  gens:=o!.gens;
  lookup:=OrbSCCLookup(o);
  lambdafunc:=LambdaFunc(s);

  for i in [1..n] do
    for x in gens do
      for f in RClassReps(d[i]) do
        AddSet(out[i], lookup[Position(o, lambdafunc(x*f))]-1);
      od;
      for f in LClassReps(d[i]) do 
        AddSet(out[i], lookup[Position(o, lambdafunc(f*x))]-1);
      od;
    od;
  od;

  Perform(out, ShrinkAllocationPlist);
  return out;
end);

#RRR

# new for 1.0! - Random - "for a regular acting semigroup"
#############################################################################

# different method for inverse

InstallMethod(Random, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(s)
  local gens, i, w, lambda_o, m, f, rho_o, rho_m, j;
  
  if not IsClosed(LambdaOrb(s)) or not IsClosed(RhoOrb(s)) then
    gens:=GeneratorsOfSemigroup(s);    
    i:=Random([1..Int(Length(gens)/2)]);
    w:=List([1..i], x-> Random([1..Length(gens)]));
    return EvaluateWord(gens, w);
  fi;
  
  lambda_o:=LambdaOrb(s);
  i:=Random([1..Length(lambda_o)]);
  m:=OrbSCCLookup(lambda_o)[i];
  f:=LambdaOrbRep(lambda_o, m);
  
  rho_o:=RhoOrb(s);
  rho_m:=OrbSCCLookup(rho_o)[Position(rho_o, RhoFunc(s)(f))]; 
  j:=Random(OrbSCC(rho_o)[rho_m]);

  return RhoOrbMult(rho_o, rho_m, j)[1]*f*
   Random(LambdaOrbSchutzGp(lambda_o, m))*
    LambdaOrbMult(lambda_o, m, i)[1];
end);

#SSS

# new for 1.0! - SchutzenbergerGroup - "for D-class of regular acting semigroup"
#############################################################################

# same method for inverse

InstallMethod(SchutzenbergerGroup, "for D-class of regular acting semigroup",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
d-> LambdaOrbSchutzGp(LambdaOrb(d), LambdaOrbSCCIndex(d)));

# new for 1.0! - SchutzenbergerGroup - "for H-class of regular acting semigroup"
#############################################################################

# same method for inverse

InstallMethod(SchutzenbergerGroup, "for H-class of regular acting semigroup",
[IsActingSemigroupGreensClass and IsRegularClass and IsGreensHClass],
h-> LambdaOrbSchutzGp(LambdaOrb(h), LambdaOrbSCCIndex(h)));

# new for 1.0! - Size - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallMethod(Size, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  local lambda_o, rho_o, nr, lambda_scc, rho_scc, r, i, rhofunc, lookup, rho, m;

  lambda_o:=Enumerate(LambdaOrb(s), infinity);
  rho_o:=Enumerate(RhoOrb(s), infinity);
  
  nr:=0;
  lambda_scc:=OrbSCC(lambda_o);
  rho_scc:=OrbSCC(rho_o);
  r:=Length(lambda_scc);
  rhofunc:=RhoFunc(s);
  lookup:=OrbSCCLookup(rho_o);

  for m in [2..r] do 
    rho:=rhofunc(LambdaOrbRep(lambda_o, m));
    nr:=nr+Length(lambda_scc[m])*Size(LambdaOrbSchutzGp(lambda_o,m))*
     Length(rho_scc[lookup[Position(rho_o, rho)]]);
  od;

  return nr;
end);

# new for 1.0! - Size - "for a regular D-class of acting semigroup"
#############################################################################

InstallOtherMethod(Size, "for a regular D-class of an acting semigp.",
[IsRegularClass and IsGreensDClass and IsActingSemigroupGreensClass],
function(d)
  return Size(SchutzenbergerGroup(d))*Length(LambdaOrbSCC(d))
   *Length(RhoOrbSCC(d));
end);

# technical...
#############################################################################
#############################################################################

# new for 1.0! - DClassType - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallOtherMethod(DClassType, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsRegularClass and IsGreensDClass 
         and IsActingSemigroupGreensClass);
end);

# new for 1.0! - HClassType - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallOtherMethod(HClassType, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsRegularClass and IsGreensHClass 
         and IsActingSemigroupGreensClass);
end);

# new for 1.0! - LClassType - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallOtherMethod(LClassType, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsRegularClass and IsGreensLClass and
         IsActingSemigroupGreensClass);
end);

# new for 1.0! - RClassType - "for a regular acting semigroup"
############################################################################

# different method for inverse semigroups

InstallOtherMethod(RClassType, "for a regular acting semigroup",
[IsRegularSemigroup and IsActingSemigroup],
function(s)
  return NewType( FamilyObj( s ), IsEquivalenceClass and
         IsEquivalenceClassDefaultRep and IsRegularClass and IsGreensRClass and
         IsActingSemigroupGreensClass);
end);

#EOF
