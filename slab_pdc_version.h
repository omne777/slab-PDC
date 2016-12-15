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

#ifndef SLAB_PDC_VERSION_H
#define SLAB_PDC_VERSION_H

#define SLAB_PDC_STR_H(x) #x
#define SLAB_PDC_STR(x) SLAB_PDC_STR_H(x)

#define SLAB_PDC_MAINTAINER "paolo.ratm@gmail.com"

#define SLAB_PDC_NAME  "SLAB_PDC"
#define SLAB_PDC_MAJOR 1
#define SLAB_PDC_MINOR 0
#define SLAB_PDC_PATCH 0

#define SLAB_PDC_VERSION(a, b, c) (((a) << 24) + ((b) << 16) + (c))

#define SLAB_PDC_VERSION_CODE \
	SLAB_PDC_VERSION(SLAB_PDC_MAJOR, SLAB_PDC_MINOR, SLAB_PDC_PATCH)

/* #define SLAB_PDC_ALPHA 1 */
/* #define SLAB_PDC_BETA 1 */

#if defined(SLAB_PDC_ALPHA)
#define SLAB_PDC_VERSION_STR \
	SLAB_PDC_NAME ": "       \
	SLAB_PDC_STR(SLAB_PDC_MAJOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_MINOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_PATCH)  \
	"-A"                \
	SLAB_PDC_STR(SLAB_PDC_ALPHA)
#elif defined(SLAB_PDC_BETA)
#define SLAB_PDC_VERSION_STR \
	SLAB_PDC_NAME ": "       \
	SLAB_PDC_STR(SLAB_PDC_MAJOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_MINOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_PATCH)  \
	"-B"                \
	SLAB_PDC_STR(SLAB_PDC_BETA)
#else
#define SLAB_PDC_VERSION_STR \
	SLAB_PDC_NAME ": "       \
	SLAB_PDC_STR(SLAB_PDC_MAJOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_MINOR)  \
	"."                 \
	SLAB_PDC_STR(SLAB_PDC_PATCH)
#endif


/*
 * E.g.
 *
 * #if SLAB_PDC_VERSION_CODE < SLAB_PDC_VERSION(0, 1, 0)
 *	...
 *	printk(SLAB_PDC_VERSION_STR);
 *	...
 * #else
 *	...
 * #endif
 */

#endif