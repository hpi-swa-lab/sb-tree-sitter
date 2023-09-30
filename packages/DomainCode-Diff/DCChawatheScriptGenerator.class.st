Class {
	#name : #DCChawatheScriptGenerator,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping [

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
				k := self findPosition: b dest: destInOrder in: aMapping.
				self move: a to: w at: k.
				srcInOrder add: a.
				destInOrder add: b]]]
]

{ #category : #actions }
DCChawatheScriptGenerator >> delete: aMorph [

	aMorph delete
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> findPosition: aTree dest: destInOrder in: aMapping [

	| siblings v u |
	siblings := aTree owner submorphs.
	siblings do: [:c | (destInOrder includes: c) ifTrue: [c = aTree ifTrue: [^ 1]]].
	
	v := nil.
	(siblings viewFirst: aTree submorphIndex) do: [:c | (destInOrder includes: c) ifTrue: [v := c]].
	
	v ifNil: [^ 1].
	
	u := aMapping srcForDest: v.
	
	^ u submorphIndex + 1
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> flashChanges [

	^ true
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> generateFrom: src to: dest in: aMapping [

	| srcInOrder destInOrder inserted |
	srcInOrder := Set new.
	destInOrder := Set new.
	inserted := Set new.
	
	dest allMorphsBreadthFirstDo: [:x | | y z w |
		w := nil.
		y := x owner.
		z := aMapping srcForDest: y.
		(aMapping isDestMapped: x)
			ifFalse: [
				w := x shallowCopyBlock.
				inserted add: w.
				self insert: w at: (self findPosition: x dest: destInOrder in: aMapping) in: z.
				aMapping addMappingFrom: w to: x]
			ifTrue: [
				w := aMapping srcForDest: x.
				w range: x range.
				x = dest ifFalse: [ | v |
					v := w owner.
					w treeLabel = x treeLabel ifFalse: [self update: w with: x contents].
					z = v ifFalse: [self move: w to: z at: (self findPosition: x dest: destInOrder in: aMapping)]]].
		
		srcInOrder add: w.
		destInOrder add: x.
		self alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping].
	
	(Array streamContents: [:s | src allMorphsDo: [:w | ((aMapping isSrcMapped: w) not and: [(inserted includes: w) not]) ifTrue: [s nextPut: w]]]) do: [:w | self delete: w]
]

{ #category : #actions }
DCChawatheScriptGenerator >> insert: aMorph at: aNumber in: anOwnerMorph [

	anOwnerMorph addMorph: aMorph asElementNumber: aNumber
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

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> maybeAttachFlash: aMorph [

	self flashChanges ifTrue: [aMorph containingSandblock attachDecorator: SBFlashDecorator new]
]

{ #category : #actions }
DCChawatheScriptGenerator >> move: aMorph to: anOwnerMorph at: aNumber [

	anOwnerMorph addMorph: aMorph asElementNumber: aNumber
]

{ #category : #actions }
DCChawatheScriptGenerator >> update: aMorph with: aString [

	aMorph contents: aString
]
