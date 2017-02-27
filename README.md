# slab-PDC

## Copyright

Authors: Paolo Missiaggia, <paolo.ratm@gmail.com>

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 2 as published by
the Free Software Foundation.

Copyright (C) 2016-2017 - Paolo Missiaggia - All Rights Reserved

## About

SLAB-PDC, a memory allocator with pre-distruction callback (PDC).

Allow to call a pre-distructor function before actually freeing memory.

## Tech info

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
AAA: The pdc_func SHALL not free the memory itself
