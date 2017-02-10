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

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/moduleparam.h>
#include <linux/version.h>
#include <linux/types.h>
#include <linux/rcupdate.h>

#include "slab_pdc.h"

__always_inline static void
call_rcu_pdc(struct rcu_head *head)
{
	pdc_func_f pdc_func;
	pdc_t *p = NULL;

	p = container_of(head, pdc_t, rcu);
	if (!p)
		return;

	pdc_func = p->pdc_func;
	if (pdc_func)
		pdc_func(p);

	kfree(p);
}

void *
kzalloc_pdc(size_t size, gfp_t flags, pdc_func_f pdc_func)
{
	pdc_t *p = NULL;

	p = kzalloc(size, flags);
	if (unlikely(!p))
		return (NULL);

	p->pdc_func = pdc_func;

	return (p);
}
EXPORT_SYMBOL(kzalloc_pdc);

void
kfree_pdc(const void *obj)
{
	pdc_t *p = NULL;

	if (!obj)
		return;

	p = (pdc_t *)obj;
	if (p->pdc_func)
		call_rcu(&p->rcu, call_rcu_pdc);
	else
		kfree_rcu(p, rcu);
}
EXPORT_SYMBOL(kfree_pdc);

void
pdc_wait_on_exit(void)
{
	return(rcu_barrier());
}
EXPORT_SYMBOL(pdc_wait_on_exit);

int
slab_pdc_init(void)
{
	printk(KERN_INFO "SLAB_PDC module loaded\n");

	return 0;
}

void
slab_pdc_exit(void)
{
	pdc_wait_on_exit();

	printk(KERN_INFO "SLAB_PDC module unloaded\n");
}

module_init(slab_pdc_init);
module_exit(slab_pdc_exit);

MODULE_AUTHOR("Paolo Missiaggia <paolo.ratm@gmail.com>");
MODULE_DESCRIPTION("Kernel memory handling facilities");
MODULE_VERSION(SLAB_PDC_VERSION_STR);

MODULE_LICENSE("GPL");
