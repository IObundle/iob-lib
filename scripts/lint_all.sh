#find all modules
LINT_EXPECTED=`find hardware -name "*_lint.expected"`

#extract respective directories
for i in $LINT_EXPECTED; do LINT_DIRS+=" `dirname $i`" ; done

#extract respective modules
for i in $LINT_DIRS; do LINT_MODULES+=" `basename $i`" ; done

#run tests
for i in $LINT_MODULES; do
  make lint-run MODULE=$i
  tail +33 spyglass_reports/moresimple.rpt > spyglass.rpt
  expected_file=$(find hardware -name $i"_lint.expected") 
  diff -q $expected_file spyglass.rpt
done
