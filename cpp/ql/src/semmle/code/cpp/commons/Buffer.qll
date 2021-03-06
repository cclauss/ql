import cpp
import semmle.code.cpp.dataflow.DataFlow

/**
 * Holds if `sizeof(s)` occurs as part of the parameter of a dynamic
 * memory allocation (`malloc`, `realloc`, etc.), except if `sizeof(s)`
 * only ever occurs as the immediate parameter to allocations.
 *
 * For example, holds for `s` if it occurs as
 * ```
 * malloc(sizeof(s) + 100 * sizeof(char))
 * ```
 * but not if it only ever occurs as
 * ```
 * malloc(sizeof(s))
 * ```
*/
private predicate isDynamicallyAllocatedWithDifferentSize(Class s) {
  exists(SizeofTypeOperator sof |
    sof.getTypeOperand().getUnspecifiedType() = s |
    // Check all ancestor nodes except the immediate parent for
    // allocations.
    isStdLibAllocationExpr(sof.getParent().(Expr).getParent+())
  )
}

/**
 * Holds if `v` is a member variable of `c` that looks like it might be variable sized in practice.  For
 * example:
 * ```
 * struct myStruct { // c
 *   int amount;
 *   char data[1]; // v
 * };
 * ```
 * This requires that `v` is an array of size 0 or 1, and `v` is the last member of `c`.  In addition,
 * there must be at least one instance where a `c` pointer is allocated with additional space. 
 */
predicate memberMayBeVarSize(Class c, MemberVariable v) {
  exists(int i |
    i = max(int j | c.getCanonicalMember(j) instanceof Field | j) and
    v = c.getCanonicalMember(i) and
    v.getType().getUnspecifiedType().(ArrayType).getSize() <= 1
  ) and
  isDynamicallyAllocatedWithDifferentSize(c)
}

/**
 * Get the size in bytes of the buffer pointed to by an expression (if this can be determined). 
 */
language[monotonicAggregates]
int getBufferSize(Expr bufferExpr, Element why) {
  exists(Variable bufferVar | bufferVar = bufferExpr.(VariableAccess).getTarget() |
    (
      // buffer is a fixed size array
      result = bufferVar.getType().getUnspecifiedType().(ArrayType).getSize() and
      why = bufferVar and
      not memberMayBeVarSize(_, bufferVar)
    ) or (
      // buffer is an initialized array
      //  e.g. int buffer[] = {1, 2, 3};
      why = bufferVar.getInitializer().getExpr() and
      (
        why instanceof AggregateLiteral or
        why instanceof StringLiteral
      ) and
      result = why.(Expr).getType().(ArrayType).getSize() and
      not exists(bufferVar.getType().getUnspecifiedType().(ArrayType).getSize())
    ) or exists(Class parentClass, VariableAccess parentPtr |
      // buffer is the parentPtr->bufferVar of a 'variable size struct'
      memberMayBeVarSize(parentClass, bufferVar) and
      why = bufferVar and
      parentPtr = bufferExpr.(VariableAccess).getQualifier() and
      parentPtr.getTarget().getType().getUnspecifiedType().(PointerType).getBaseType() = parentClass and
      result =
        getBufferSize(parentPtr, _) +
        bufferVar.getType().getSize() -
        parentClass.getSize()
    )
  ) or (
    // buffer is a fixed size dynamic allocation
    isFixedSizeAllocationExpr(bufferExpr, result) and
    why = bufferExpr
  ) or (
    // dataflow (all sources must be the same size)
    result = min(Expr def |
      DataFlow::localFlowStep(DataFlow::exprNode(def), DataFlow::exprNode(bufferExpr)) |
      getBufferSize(def, _)
    ) and result = max(Expr def |
      DataFlow::localFlowStep(DataFlow::exprNode(def), DataFlow::exprNode(bufferExpr)) |
      getBufferSize(def, _)
    ) and

    // find reason
    exists(Expr def |
      DataFlow::localFlowStep(DataFlow::exprNode(def), DataFlow::exprNode(bufferExpr)) |
      why = def or
      exists(getBufferSize(def, why))
    )
  ) or exists(Type bufferType |
    // buffer is the address of a variable
    why = bufferExpr.(AddressOfExpr).getAddressable() and
    bufferType = why.(Variable).getType() and
    result = bufferType.getSize() and
    not bufferType instanceof ReferenceType and
    not any(Union u).getAMemberVariable() = why
  ) or exists(Union bufferType |
    // buffer is the address of a union member; in this case, we
    // take the size of the union itself rather the union member, since
    // it's usually OK to access that amount (e.g. clearing with memset).
    why = bufferExpr.(AddressOfExpr).getAddressable() and
    bufferType.getAMemberVariable() = why and
    result = bufferType.getSize()
  )
}
