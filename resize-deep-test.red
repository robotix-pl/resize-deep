Red [
	File: %resize-deep-test.red
	Author: loziniak
]

#include %resize-deep.red


view/flags [

	on-resizing [
		resize-deep face
	]

	on-resize [
		resize-deep face
	]

	origin 10x10
	space 15x15

	below

	button "test0" extra [
		expand: ['horizontal 'vertical]
	]

	button "test1"

	button "test2" extra context [
		expand: 'horizontal
	]

	panel red extra context [
		expand: ['horizontal 'vertical]
		fixed: (2 * 10x10) + (2 * 30x0)
	] [
		space 30x30

		button "test3" extra [
			expand: 'vertical
		]
		button "test4" extra [
			expand: ['horizontal]
		]
		button "test5" extra [
			expand: ['vertical 'horizontal]
		]
	]

	do [
		self/extra: reduce [
			to set-word! 'fixed
				(2 * 10x10) ; 2x origin
				+ ((4 - 1) * 0x15) ; 4x space
		]
	]

] 'resize
