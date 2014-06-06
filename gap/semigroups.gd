############################################################################# 
## 
#W  semigroups.gd
#Y  Copyright (C) 2013-14                                James D. Mitchell
## 
##  Licensing information can be found in the README file of this package.
## 
############################################################################# 
##

DeclareCategory("IsSemigroupWithInverseOp", IsInverseSemigroup);

DeclareCategory("IsAssociativeElementWithStar", IsAssociativeElement);
DeclareCategoryCollections("IsAssociativeElementWithStar");
DeclareOperation("StarOp", [IsAssociativeElementWithStar]);
DeclareAttribute("Star", IsAssociativeElementWithStar);

DeclareSynonym("IsStarSemigroup", IsSemigroup and
IsAssociativeElementWithStarCollection);
DeclareSynonym("IsRegularStarSemigroup", IsRegularSemigroup and
IsAssociativeElementWithStarCollection);

DeclareOperation("InverseOp", [IsAssociativeElementWithStar]);

DeclareOperation("SemigroupByGenerators",
[IsAssociativeElementCollection, IsRecord]);

DeclareOperation("MonoidByGenerators",
[IsAssociativeElementCollection, IsRecord]);

DeclareOperation("InverseMonoidByGenerators",
[IsAssociativeElementCollection and
IsAssociativeElementCollection, IsRecord]);

DeclareOperation("InverseSemigroupByGenerators",
[IsAssociativeElementCollection, IsRecord]);

DeclareOperation("ClosureInverseSemigroup", [IsSemigroupWithInverseOp,
IsAssociativeElementCollection, IsRecord]);
DeclareOperation("ClosureInverseSemigroup",
[IsSemigroupWithInverseOp, IsAssociativeElementCollection]);
DeclareOperation("ClosureInverseSemigroup", 
[IsSemigroupWithInverseOp, IsAssociativeElement]);
DeclareOperation("ClosureInverseSemigroup",
[IsSemigroupWithInverseOp, IsAssociativeElement, IsRecord]);
DeclareGlobalFunction("ClosureInverseSemigroupNC");

DeclareOperation("ClosureSemigroup", 
[IsSemigroup, IsAssociativeElementCollection, IsRecord]);
DeclareOperation("ClosureSemigroup", 
[IsSemigroup, IsAssociativeElementCollection]);
DeclareOperation("ClosureSemigroup",
[IsSemigroup, IsAssociativeElement, IsRecord]);
DeclareOperation("ClosureSemigroup",
[IsSemigroup, IsAssociativeElement]);
DeclareGlobalFunction("ClosureSemigroupNC");

DeclareGlobalFunction("ChangeDegreeOfTransformationSemigroupOrb");

DeclareAttribute("Generators", IsSemigroup);

DeclareOperation("RandomBinaryRelationSemigroup", [IsPosInt, IsPosInt]);
DeclareOperation("RandomBinaryRelationMonoid", [IsPosInt, IsPosInt]);
DeclareOperation("RandomMatrixSemigroup", [IsRing, IsPosInt, IsPosInt]);
DeclareOperation("RandomBlockGroup", [IsPosInt, IsPosInt]);
DeclareOperation("RandomInverseSemigroup", [IsPosInt, IsPosInt]);
DeclareOperation("RandomInverseMonoid", [IsPosInt, IsPosInt]);
DeclareOperation("RandomTransformationMonoid", [IsPosInt, IsPosInt]);
DeclareOperation("RandomTransformationSemigroup", [IsPosInt, IsPosInt]);
DeclareSynonym("RandomPartialPermSemigroup", RandomBlockGroup);
DeclareOperation("RandomPartialPermMonoid", [IsPosInt, IsPosInt]);
DeclareOperation("RandomBipartitionSemigroup", [IsPosInt, IsPosInt]);
DeclareOperation("RandomBipartitionMonoid", [IsPosInt, IsPosInt]);

DeclareOperation("SubsemigroupByProperty", [IsSemigroup, IsFunction]);
DeclareOperation("SubsemigroupByProperty", 
[IsSemigroup, IsFunction, IsPosInt]);

DeclareOperation("InverseSubsemigroupByProperty", 
[IsSemigroup, IsFunction]);
DeclareOperation("InverseSubsemigroupByProperty", 
[IsSemigroupWithInverseOp, IsFunction, IsPosInt]);

# undoc

DeclareProperty("IsBinaryRelationSemigroup", IsSemigroup);
DeclareGlobalFunction("RegularSemigroup");

#EOF
