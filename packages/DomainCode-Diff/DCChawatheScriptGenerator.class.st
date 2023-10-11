Class {
	#name : #DCChawatheScriptGenerator,
	#superclass : #Object,
	#category : #'DomainCode-Diff'
}

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping [

	| s1 s2 lcs |
	w childrenDo: [:c | srcInOrder remove: c ifAbsent: []].
	x childrenDo: [:c | destInOrder remove: c ifAbsent: []].
	
	s1 := w childrenSelect: [:c | (aMapping isSrcMapped: c) and: [x children includes: (aMapping destForSrc: c)]].
	s2 := x childrenSelect: [:c | (aMapping isDestMapped: c) and: [w children includes: (aMapping srcForDest: c)]].
	
	lcs := self lcsWith: s1 and: s2 in: aMapping.
	lcs do: [:mapping |
		srcInOrder add: mapping first.
		destInOrder add: mapping second].
	
	s2 do: [:b |
		s1 do: [:a |
			((aMapping includes: {a. b}) and: [(lcs includes: {a. b}) not]) ifTrue: [
				self move: a to: w postDeleteDo: [self findPosition: b dest: destInOrder in: aMapping].
				srcInOrder add: a.
				destInOrder add: b]]]
]

{ #category : #actions }
DCChawatheScriptGenerator >> delete: aMorph [

	| target |
	target := aMorph replacedParent
		ifNotNil: [:p | p isReplacement ifTrue: [p] ifFalse: [aMorph]]
		ifNil: [aMorph].
	
	aMorph delete.
	
	self logChanges ifTrue: [Transcript showln: {#delete. target}]
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> findPosition: aTree dest: destInOrder in: aMapping [

	| siblings v u |
	siblings := aTree parent children.
	siblings do: [:c | (destInOrder includes: c) ifTrue: [c = aTree ifTrue: [^ 1]]].
	
	v := nil.
	(siblings viewFirst: aTree siblingIndex) do: [:c | (destInOrder includes: c) ifTrue: [v := c]].
	
	v ifNil: [^ 1].
	
	u := aMapping srcForDest: v.
	
	^ u siblingIndex + 1
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> generateFrom: src to: dest in: aMapping [

	| srcInOrder destInOrder inserted |
	srcInOrder := Set new.
	destInOrder := Set new.
	inserted := Set new.
	
	dest allChildrenBreadthFirstDo: [:x | | y z w |
		w := nil.
		y := x parent.
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
				x = dest ifFalse: [ | v k |
					v := w parent.
					w treeLabel = x treeLabel ifFalse: [self update: w with: x contents].
					k := self findPosition: x dest: destInOrder in: aMapping.
					(z isNode: v) ifFalse: [self move: w to: z postDeleteDo: [k]]]].
		
		srcInOrder add: w.
		destInOrder add: x.
		self alignChildrenSrc: w dest: x srcInOrder: srcInOrder destInOrder: destInOrder in: aMapping].
	
	(Array streamContents: [:s | src allChildrenDo: [:w | ((aMapping isSrcMapped: w) not and: [(inserted includes: w) not]) ifTrue: [s nextPut: w]]]) do: [:w | self delete: w]
]

{ #category : #actions }
DCChawatheScriptGenerator >> insert: aMorph at: aNumber in: anOwnerMorph [

	anOwnerMorph addMorph: aMorph asElementNumber: aNumber.
	self maybeAttachFlash: aMorph.
	self logChanges ifTrue: [Transcript showln: {#insert. anOwnerMorph. aNumber. aMorph}]
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> lcsWith: x and: y in: aMapping [

	| opt lcs ix jy |
	opt := Matrix rows: x size + 1 columns: y size + 1 element: 0.
	lcs := OrderedCollection new.
	
	x size to: 1 by: -1 do: [:i |
		y size to: 1 by: -1 do: [:j |
			opt at: i at: j put: ((aMapping srcForDest: (y at: j)) = (x at: i)
				ifTrue: [(opt at: i + 1 at: j + 1) + 1]
				ifFalse: [(opt at: i + 1 at: j) max: (opt at: i at: j + 1)])]].
	
	ix := 1.
	jy := 1.
	[ix <= x size and: [jy <= y size]] whileTrue: [
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
DCChawatheScriptGenerator >> logChanges [

	^ false
]

{ #category : #'as yet unclassified' }
DCChawatheScriptGenerator >> maybeAttachFlash: aMorph [

	self logChanges ifTrue: [aMorph containingSandblock attachDecorator: SBFlashDecorator new]
]

{ #category : #actions }
DCChawatheScriptGenerator >> move: aMorph to: anOwnerMorph postDeleteDo: aBlock [

	| index target |
	target := aMorph replacedParent
		ifNotNil: [:p | p isReplacement ifTrue: [p] ifFalse: [aMorph]]
		ifNil: [aMorph].
	
	aMorph delete.
	index := aBlock value.
	anOwnerMorph addMorph: aMorph asElementNumber: index.
	
	self maybeAttachFlash: target.
	self logChanges ifTrue: [Transcript showln: {#move. anOwnerMorph. index. target}]
]

{ #category : #actions }
DCChawatheScriptGenerator >> update: aMorph with: aString [

	aMorph contents: aString.
	self maybeAttachFlash: aMorph.
	self logChanges ifTrue: [Transcript showln: {#update. aMorph. aString}]
]
