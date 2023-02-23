Class {
	#name : #SBGDPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-GDScript'
}

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildAbstractionsOn: aBuilder [

	aBuilder addSectionHeader: 'Abstractions'.
	aBuilder addBlock: 'function' as: (SBGDScript parseWithPlaceholders: 'func _():
	_').
	aBuilder addBlock: 'class' as: (SBGDScript parseWithPlaceholders: 'class _:
	_').
	aBuilder addBlock: 'constructor' as: (SBGDScript parseWithPlaceholders: 'func _init():
	_')
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildAnnotationsOn: aBuilder [

	aBuilder addBlock: 'extends' as: (SBGDScript parseWithPlaceholders: 'extends _').
	aBuilder addBlock: 'tool' as: (SBGDScript parseWithPlaceholders: 'tool').
	aBuilder addBlock: 'class name' as: (SBGDScript parseWithPlaceholders: 'class_name _')
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildControlFlowOn: aBuilder [

	aBuilder addSectionHeader: 'Control Flow'.
	aBuilder addBlock: 'if' as: (SBGDScript parseWithPlaceholders: 'if _:
	_').
	aBuilder
		addBlock: 'elif'
		as: (SBGDScript parseWithPlaceholders: 'if _:
	_
elif _:
	_') childSandblocks third.
	aBuilder
		addBlock: 'else'
		as: (SBGDScript parseWithPlaceholders: 'if _:
	_
else:
	_') childSandblocks third.
	aBuilder addBlock: 'for' as: (SBGDScript parseWithPlaceholders: 'for _ in _:
	_').
	aBuilder addBlock: 'while' as: (SBGDScript parseWithPlaceholders: 'while _:
	_').
	aBuilder addBlock: 'match' as: (SBGDScript parseWithPlaceholders: 'match _:
	_condition:
		pass').
	aBuilder addBlock: 'return' as: (SBGDScript parseWithPlaceholders: 'return _').
	aBuilder addBlock: 'break' as: (SBGDScript parseWithPlaceholders: 'break').
	aBuilder addBlock: 'continue' as: (SBGDScript parseWithPlaceholders: 'continue')
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildDataOn: aBuilder [

	aBuilder addSectionHeader: 'Data'.
	aBuilder addBlock: 'variable' as: (SBGDScript parseWithPlaceholders: 'var _ = _').
	aBuilder addBlock: 'exported variable' as: (SBGDScript parseWithPlaceholders: 'export var _ = _').
	aBuilder addBlock: 'constant' as: (SBGDScript parseWithPlaceholders: 'const _ = _').
	aBuilder addBlock: 'enum' as: (SBGDScript parseWithPlaceholders: 'enum _ {_ = _}')
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildExampleOn: aBuilder [

	aBuilder addSectionHeader: 'Example'.
	
	(SBGDFunctionCall signatures at: 'KinematicBody2D') do: [:method |
		method name first ~= $_ ifTrue: [
			aBuilder
				addBlock: method name
				as: (SBGDScript parseWithPlaceholders: ('{1}({2})' format: {method name. (method arguments collect: [:arg | '_', arg name]) joinSeparatedBy: ', '})) applyReplacement]]
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildOn: aBuilder [

	aBuilder addHeader: 'Godot'.
	self buildDataOn: aBuilder.
	self buildPrimitivesOn: aBuilder.
	self buildAbstractionsOn: aBuilder.
	self buildControlFlowOn: aBuilder.
	self buildExampleOn: aBuilder
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> buildPrimitivesOn: aBuilder [

	aBuilder addSectionHeader: 'Primitives'.
	aBuilder addBlock: 'Vector2' as: (SBGDScript parseWithPlaceholders: 'Vector2(_x, _y)')
]

{ #category : #'as yet unclassified' }
SBGDPalette class >> language [

	^ SBGDScript
]
