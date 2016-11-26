# slab-PDC
Small module to extend memory allocation and release in kernel space

Allow to call a pre-distructor function before actually freeing memory.

Requirements:
The first 2 element of the returned struct SHALL be:
* "struct rcu_head"
* "pdc_func_f"

E.g.:

```C
struct foo {
   struct rcu_head rcu;
   pdc_func_f pdc_func;
   int foo1;
};
```
or:

```C
struct foo {
   pdc_t kobj;
   int foo1;
};
```

AAA: Do not perform non atomic actions inside "pdc_func"
AAA: pdc_func SHALL not free the memory itself
