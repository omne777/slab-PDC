/*
 * Memory allocator with pre-distruction callback (PDC)
 * (C) 2016
 *
 * Authors:
 *         Paolo Missiaggia, <paolo.ratm@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 */

#ifndef SLAB_PDC_H
#define SLAB_PDC_H

#include <linux/slab.h>

/*
 * Requirements:
 * The first 2 element of the returned struct SHALL be:
 * 1) a "struct rcu_head"
 * 2) a "pdc_func_f"
 *
 * E.g.:
 * struct foo {
 *    struct rcu_head rcu;
 *    pdc_func_f pdc_func;
 *    int foo1;
 * };
 * or:
 * struct foo {
 *    pdc_t kobj;
 *    int foo1;
 * };
 *
 * AAA: Do not perform non atomic actions inside "pdc_func"
 * AAA: dst_func SHALL not free the memory itself
 */

typedef int(*pdc_func_f)(void *obj);

typedef struct {
	struct rcu_head rcu;
	pdc_func_f pdc_func;
} pdc_t;

void *kzalloc_pdc(size_t size, gfp_t flags, pdc_func_f pdc_func);
void  kfree_pdc(const void *obj);

#endif
