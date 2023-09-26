Class {
	#name : #DCChawatheScriptGenerator,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping do: aBlock [

	| s1 s2 lcs |
	w submorphs do: [:c | srcInOrder remove: c ifAbsent: []].
	x submorphs do: [:c | destInOrder remove: c ifAbsent: []].
	
	s1 := w submorphs select: [:c | (aMapping isSrcMapped: c) and: [x submorphs includes: (aMapping destForSrc: c)]].
	s2 := x submorphs select: [:c | (aMapping isDestMapped: c) and: [x submorphs includes: (aMapping srcForDest: c)]].
	
	lcs := self lcsWith: s1 and: s2 in: aMapping.
	lcs do: [:mapping |
		srcInOrder add: mapping first.
		destInOrder add: mapping second].
	
	s2 do: [:b |
		s1 do: [:a |
			(aMapping includes: {a. b}) ifFalse: [ | k |
				"FIXME delete first or find position first?"
				a delete.
				k := self findPosition: b dest: destInOrder in: aMapping.
				aBlock value: #move value: {a. w. k}.
				w addMorph: a asElementNumber: k.
				srcInOrder add: a.
				srcInOrder add: b]]]
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> findPosition: aTree dest: destInorder in: aMapping [

	| siblings v u |
	siblings := aTree owner submorphs.
	siblings do: [:c | (destInorder includes: c) ifTrue: [c = aTree ifTrue: [^ 1]]].
	
	v := nil.
	(siblings viewFirst: aTree submorphIndex) do: [:c | (destInorder includes: c) ifTrue: [v := c]].
	
	v ifNil: [^ 1].
	
	u := aMapping srcForDest: v.
	
	^ u submorphIndex
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> generateFrom: src to: dest in: aMapping do: aBlock [

	| srcInOrder destInOrder inserted |
	srcInOrder := Set new.
	destInOrder := Set new.
	inserted := Set new.
	
	dest allMorphsBreadthFirstDo: [:x | | y z w |
		w := nil.
		y := x owner.
		z := aMapping srcForDest: y.
		(aMapping isDestMapped: x)
			ifFalse: [ | k |
				k := self findPosition: x dest: destInOrder in: aMapping.
				aBlock value: #insert value: {x. z. k}.
				w := x shallowCopyBlock.
				inserted add: w.
				z addMorph: w asElementNumber: k.
				aMapping addMappingFrom: w to: x]
			ifTrue: [
				w := aMapping srcForDest: x.
				x = dest ifFalse: [ | v |
					v := w owner.
					w treeLabel = x treeLabel ifFalse: [
						self assert: (w isTextMorph and: [x isTextMorph]).
						w contents: x contents.
						aBlock value: #update value: {w. x contents}].
					z = v ifFalse: [ | k |
						k := self findPosition: x dest: destInOrder in: aMapping.
						aBlock value: #move value: {w. z. k}.
						w delete.
						z addMorph: w asElementNumber: k]]].
		
		srcInOrder add: w.
		destInOrder add: x.
		self alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping do: aBlock].
	
	src allMorphsDo: [:w | ((aMapping isSrcMapped: w) not and: [(inserted includes: w) not]) ifTrue: [aBlock value: #delete value: {w}]]
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> lcsWith: x and: y in: aMapping [

	| opt lcs ix jy |
	opt := Matrix rows: x size + 1 columns: y size + 1.
	lcs := OrderedCollection new.
	
	x size to: 1 by: -1 do: [:i |
		y size to: 1 by: -1 do: [:j |
			opt at: i at: j put: ((aMapping srcForDest: (y at: j)) = (x at: i)
				ifTrue: [(opt at: i + 1 at: j + 1) + 1]
				ifFalse: [(opt at: i + 1 at: j) max: (opt at: i at: j + 1)])]].
	
	ix := 0.
	jy := 0.
	[ix < x size and: [jy < y size]] whileTrue: [
		(aMapping srcForDest: (y at: jy)) = (x at: ix)
			ifTrue: [
				lcs add: {x at: ix. y at: jy}.
				ix := ix + 1.
				jy := jy + 1]
			ifFalse: [
				(opt at: ix + 1 at: jy) >= (opt at: ix at: jy + 1)
					ifTrue: [ix := ix + 1]
					ifFalse: [jy := jy + 1]]].
	
	^ lcs
]
