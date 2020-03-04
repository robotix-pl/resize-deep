Red [
	File: %resize-deep.red
	Author: "loziniak"
	License: "MIT License"
]

context [

in-extra?: make op! function [
	field [word!]
	face [object!]
	return: [logic!]
] [
	to logic!
		switch/default  to word! type? face/extra [
			object! [in face/extra field]
			block! [find face/extra field]
		] [
			false
		]
]

set 'resize-deep function [parent [object!]] [
	if any [
		not in parent 'pane
		not block? parent/pane
		empty? parent/pane
	] [
		return none
	]

	;-- pre-calculate

	horiz-aligns: [top middle bottom]
	vert-aligns: [left center right]
	fixed: 0x0
	expand-x: copy []
	expand-y: copy []
	expand-x-sum: copy []
	expand-y-sum: copy []

	if 'fixed in-extra? parent [
		fixed: fixed + parent/extra/fixed
	]

	current-block-x: copy []
	current-block-y: copy []
	foreach child parent/pane [
		child-align: child/options/vid-align
		append current-block-x child
		append current-block-y child

		either 'expand in-extra? child [
			child-expand-x: find  to block! child/extra/expand  'horizontal
			child-expand-y: find  to block! child/extra/expand  'vertical

			if find vert-aligns child-align [
				if child-expand-x [append expand-x child]
				either child-expand-y [
					append/only expand-y-sum current-block-y
					current-block-y: copy []
				] [
					fixed: fixed + as-pair 0 child/size/y
				]
			]
			if find horiz-aligns child-align [
				if child-expand-y [append expand-y child]
				either child-expand-x [
					append/only expand-x-sum current-block-x
					current-block-x: copy []
				] [
					fixed: fixed + as-pair child/size/x 0
				]
			]
		] [
			if find vert-aligns child-align [
				fixed: fixed + as-pair 0 child/size/y
			]
			if find horiz-aligns child-align [
				fixed: fixed + as-pair child/size/x 0
			]
		]
	]

	unless empty? expand-x-sum [append/only expand-x-sum current-block-x]
	unless empty? expand-y-sum [append/only expand-y-sum current-block-y]

	;-- apply

	foreach dim [x y] [

		expand: switch dim [
			x [expand-x]
			y [expand-y]
		]
		expand-sum: switch dim [
			x [expand-x-sum]
			y [expand-y-sum]
		]

		foreach child expand [
			new-dim: parent/size/(dim) - fixed/(dim)
			if not-equal? child/size/(dim) new-dim [
				child/size/(dim): new-dim
				do-actor child none 'resizing
			]
		]

		cumulative-offset: 0
		last-sum: 0
		i: 1
		foreach blk expand-sum [
			unless cumulative-offset = 0 [
				foreach child blk [
					child/offset/(dim): child/offset/(dim) + cumulative-offset
				]
			]
			unless blk =? last expand-sum [
				this-sum: (parent/size/(dim) - fixed/(dim)) * i / ((length? expand-sum) - 1)
				new-dim: this-sum - last-sum
				expanding-child: last blk
				dim-change: new-dim - expanding-child/size/(dim)
				unless dim-change = 0 [
					expanding-child/size/(dim): new-dim
					do-actor expanding-child none 'resizing
				]
				cumulative-offset: cumulative-offset + dim-change
				last-sum: this-sum
			]
			i: i + 1
		]
	]

	;-- recurency

	foreach child parent/pane [
		resize-deep child
	]

	exit
]

]
