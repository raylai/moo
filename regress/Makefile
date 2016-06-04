MOO?=			moo
CLEANFILES+=		moo.out
REGRESS_TARGETS?=	t1  t2  t3  t4  t5  t6  t7  t8  t9  t10	\
			t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 \
			t21 t22 t23

# t1:  +
# t2:  -
# t3:  *
# t4:  /
# t5:  %
# t6:  !
# t7:  ~
# t8:  unary -
# t9:  <<
# t10: >>
# t11: <
# t12: <=
# t13: >
# t14: >=
# t15: ==
# t16: !=
# t17: &
# t18: ^
# t19: |
# t20: &&
# t21: ||
# t22: precedence
# t23: ()

.SUFFIXES: .in

.in:
	@# Decimal
	@${MOO} < $< > moo.out
	@cut -f2 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Hexadecimal
	@${MOO} -b 16 < $< > moo.out
	@cut -f1 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Explicit base ten
	@${MOO} -b 10 < $< > moo.out
	@cut -f2 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Octal
	@${MOO} -b 8 < $< > moo.out
	@cut -f3 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Binary
	@${MOO} -b 2 < $< > moo.out
	@cut -f4 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Hex and dec
	@${MOO} -b 16 -b 10 < $< > moo.out
	@cut -f1,2 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Hex and oct
	@${MOO} -b 16 -b 8 < $< > moo.out
	@cut -f1,3 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Hex and bin
	@${MOO} -b 16 -b 2 < $< > moo.out
	@cut -f1,4 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Dec and oct
	@${MOO} -b 10 -b 8 < $< > moo.out
	@cut -f2,3 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Dec and bin
	@${MOO} -b 10 -b 2 < $< > moo.out
	@cut -f2,4 ${.CURDIR}/$@.out | diff -u - moo.out
	@# Oct and bin
	@${MOO} -b 8 -b 2 < $< > moo.out
	@cut -f3,4 ${.CURDIR}/$@.out | diff -u - moo.out

.include <bsd.regress.mk>
