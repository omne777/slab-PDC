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

#include "slab_pdc.h"

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

struct sample_struct {
	pdc_t pdc;
	char s[];
};

int
sample_print_and_free(void *obj)
{
	struct sample_struct *q = obj;

	printk("%s\n", q->s);

	return (0);
}

struct sample_struct *p = NULL;
struct sample_struct *r = NULL;

int
slab_pdc_init(void)
{
	p = kzalloc_pdc(1024, GFP_KERNEL, NULL);
	if (!p) {
		printk("Memory allocation failure\n");
		return (-1);
	}
	sprintf(p->s, "p - Hello World!!!");

	r = kzalloc_pdc(1024, GFP_KERNEL, sample_print_and_free);
	if (!p) {
		printk("Memory allocation failure\n");
		return (-1);
	}
	sprintf(r->s, "r - Hello World!!!");

	printk("Memory allocation succeed\n");
	printk(KERN_INFO "Module loaded\n");
	/*
	 * A non 0 return means init_module failed; module can't be loaded.
	 */
	return 0;
}

void
slab_pdc_exit(void)
{
	printk(KERN_INFO "Barrier wait before exit\n");

	if (p)
		printk(KERN_INFO "Memory has to be cleaned up\n");

	kfree_pdc(p);
	kfree_pdc(r);

	rcu_barrier(); /* Wait until all in-flight call_rcu() callbacks complete */

	printk(KERN_INFO "Module unloaded\n");
}

module_init(slab_pdc_init);
module_exit(slab_pdc_exit);

MODULE_AUTHOR("Paolo Missiaggia <paolo.ratm@gmail.com>");
MODULE_DESCRIPTION("Kernel memory handling facilities");

MODULE_LICENSE("GPL");
