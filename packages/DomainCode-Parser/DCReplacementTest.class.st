Class {
	#name : #DCReplacementTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Parser-Test'
}

{ #category : #'as yet unclassified' }
DCReplacementTest >> parse: aString withQueries: aCollection do: aBlock [

	| root editor |
	root := DCBlock parse: aString language: SBJavascript.
	root queryState querySourceOverride: [:type :block | aCollection do: [:assoc | assoc key = type ifTrue: [block value: assoc value]]].
	editor := self editorAndWorldFor: root.
	self tick.
	aBlock value: root value: editor
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testEditEmbeddedChild [

	self
		parse: '(23)'
		withQueries: {
			#always -> {
				[:x | x type = #'parenthesized_expression'].
				[:x |
					x
						ensureReplacement: DCTestReplacement
						initDo: [:w | w addMorphBack: (w embed: [:s | s children second])]]}}
		do: [:block :editor | | replacement |
			editor selection firstDeepChild startInputAtEnd.
			editor performForSelection: #moveCursorLeft.
			editor handle: (SBTest keyboardEvent: $+).
			self tick.
			
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCTestReplacement equals: replacement class.
			self assert: #'parenthesized_expression' equals: block children first children first type.
			self assert: #'binary_expression' equals: block children first children first children second type.
			self
				assert: '2+3'
				equals: block children first children first children second generatedSourceString.
			
			self assert: #'binary_expression' equals: replacement firstSubmorph source type.
			self assert: DCShard equals: replacement firstSubmorph class.
			self assert: DCBlock equals: replacement firstSubmorph firstSubmorph class]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testEditEmbeddedRoot [

	self
		parse: '2'
		withQueries: {
			#always -> {
				[:x | x type = #number].
				[:x | x ensureReplacement: DCTestReplacement initDo: [:w | w addMorphBack: (w embed: [:s | s])]]}}
		do: [:block :editor | | replacement |
			editor selection firstDeepChild startInputAtEnd.
			editor handle: (SBTest keyboardEvent: $3).
			
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCTestReplacement equals: replacement class.
			self assert: #number equals: block children first children first type.
			self assert: '23' equals: block children first children first contents.
			
			self assert: DCShard equals: replacement firstSubmorph class]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testMoveOutFullReplaced [

	
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testMoveOutPartOfReplaced [

	
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testPassiveReplacement [

	self
		parse: '2'
		withQueries: {#always -> {[:x | x type = #number]. [:x | x ensureReplacement: DCTestReplacement initDo: [:w | ]]}}
		do: [:block :editor | self assert: DCTestReplacement equals: block childSandblocks first childSandblocks first class]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testPassiveReplacementWithChildEmbed [

	self
		parse: '(2)'
		withQueries: {
			#always -> {
				[:x | x type = #'parenthesized_expression'].
				[:x |
					x
						ensureReplacement: DCTestReplacement
						initDo: [:w | w addMorphBack: (w embed: [:s | s children second])]]}}
		do: [:block :editor | | replacement |
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCTestReplacement equals: replacement class.
			self assert: #'parenthesized_expression' equals: block children first children first type.
			self assert: #number equals: block children first children first children second type.
			
			self assert: #number equals: replacement firstSubmorph firstSubmorph type.
			self assert: DCBlock equals: replacement firstSubmorph firstSubmorph class.
			
			self assert: DCShard equals: replacement firstSubmorph class]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testPassiveReplacementWithRootEmbed [

	self
		parse: '2'
		withQueries: {
			#always -> {
				[:x | x type = #number].
				[:x | x ensureReplacement: DCTestReplacement initDo: [:w | w addMorphBack: (w embed: [:s | s])]]}}
		do: [:block :editor | | replacement |
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCTestReplacement equals: replacement class.
			self assert: #number equals: block children first children first type.
			
			self assert: DCShard equals: replacement firstSubmorph class]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testUninstallAfterTypeChange [

	self
		parse: ';2'
		withQueries: {
			#always -> {
				[:x | x type = #number].
				[:x | x ensureReplacement: DCTestReplacement initDo: [:w | w addMorphBack: SBIcon iconAt]]}}
		do: [:block :editor |
			editor selection firstDeepChild startInputAtEnd.
			editor handle: (SBTest keyboardEvent: $a).
			self tick.
			
			self assert: 'a2' equals: block children second children first contents]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testUninstallWithEmbeddedChild [

	self
		parse: '(23)'
		withQueries: {
			#always -> {
				[:x | x type = #'parenthesized_expression'].
				[:x | x children first type = #number].
				[:x |
					x
						ensureReplacement: DCTestReplacement
						initDo: [:w :num | w addMorphBack: (w embed: [:s | s children second])]]}}
		do: [:block :editor | | replacement |
			editor selection firstDeepChild startInputAtStart.
			editor handle: (SBTest keyboardEvent: $a).
			self tick.
			
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCBlock equals: replacement class.
			self assert: #'parenthesized_expression' equals: block children first children first type.
			self assert: #identifier equals: block children first children first children second type.
			self assert: '(a23)' equals: block sourceString.
			block allMorphsDo: [:m | self assert: m replacedParent isNil]]
]

{ #category : #'as yet unclassified' }
DCReplacementTest >> testUninstallWithEmbeddedRoot [

	self
		parse: '2'
		withQueries: {
			#always -> {
				[:x | x type = #number].
				[:x | x ensureReplacement: DCTestReplacement initDo: [:w | w addMorphBack: (w embed: [:s | s])]]}}
		do: [:block :editor | | replacement |
			editor selection firstDeepChild startInputAtStart.
			editor handle: (SBTest keyboardEvent: $a).
			
			replacement := block childSandblocks first childSandblocks first.
			self assert: DCBlock equals: replacement class.
			self assert: #identifier equals: block children first children first type.
			self assert: 'a2' equals: block children first children first contents]
]
