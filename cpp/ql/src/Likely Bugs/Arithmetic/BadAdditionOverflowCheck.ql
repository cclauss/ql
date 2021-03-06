/**
 * @name Bad check for overflow of integer addition
 * @description Checking for overflow of integer addition by comparing
 *              against one of the arguments of the addition does not work
 *              when the result of the addition is automatically promoted
 *              to a larger type.
 * @kind problem
 * @problem.severity error
 * @precision very-high
 * @id cpp/bad-addition-overflow-check
 * @tags reliability
 *       correctness
 *       security
 *       external/cwe/190
 *       external/cwe/192
 */

import cpp
import BadAdditionOverflowCheck

from RelationalOperation cmp, AddExpr a
where badAdditionOverflowCheck(cmp, a)
select cmp, "Bad overflow check."
