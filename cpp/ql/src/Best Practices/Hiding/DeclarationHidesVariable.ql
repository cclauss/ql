/**
 * @name Declaration hides variable
 * @description A local variable hides another local variable from a surrounding scope. This may be confusing. Consider renaming one of the variables.
 * @kind problem
 * @problem.severity recommendation
 * @precision high
 * @id cpp/declaration-hides-variable
 * @tags maintainability
 *       readability
 */
import cpp

import Best_Practices.Hiding.Shadowing

from LocalVariable lv1, LocalVariable lv2
where shadowing(lv1, lv2) and
      not lv1.getParentScope().(Block).isInMacroExpansion() and
      not lv2.getParentScope().(Block).isInMacroExpansion()
select lv1, "Variable " + lv1.getName() +
            " hides another variable of the same name (on $@).",
            lv2, "line " + lv2.getLocation().getStartLine().toString()
