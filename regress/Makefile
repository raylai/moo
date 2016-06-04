MOO?=			moo
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
	@# Hexadecimal
	@${MOO} -b 16 < $< | diff -u ${.CURDIR}/$@.16 -
	@# Explicit base ten
	@${MOO} -b 10 < $< | diff -u ${.CURDIR}/$@.10 -
	@# Octal
	@${MOO} -b 8 < $< | diff -u ${.CURDIR}/$@.8 -
	@# Binary
	@${MOO} -b 2 < $< | diff -u ${.CURDIR}/$@.1 -

.include <bsd.regress.mk>
