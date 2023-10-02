Class {
	#name : #DCCommandScriptGenerator,
	#superclass : #DCChawatheScriptGenerator,
	#instVars : [
		'editor'
	],
	#category : #'DomainCode-Diff'
}

{ #category : #actions }
DCCommandScriptGenerator >> delete: aMorph [

	self editor do: (SBDeleteCommand new
		target: aMorph;
		shouldMergeWithNext: true).
	self logChanges ifTrue: [Transcript showln: {#delete. aMorph}]
]

{ #category : #accessing }
DCCommandScriptGenerator >> editor [

	^ editor
]

{ #category : #accessing }
DCCommandScriptGenerator >> editor: anEditor [

	editor := anEditor
]

{ #category : #'initialize-release' }
DCCommandScriptGenerator >> initialize [

	super initialize.
	
	commands := OrderedCollection new
]

{ #category : #actions }
DCCommandScriptGenerator >> insert: aMorph at: aNumber in: anOwnerMorph [

	self editor do: (SBInsertCommand new
		shouldMergeWithNext: true;
		index: aNumber;
		container: anOwnerMorph;
		morph: aMorph).
	self maybeAttachFlash: aMorph.
	self logChanges ifTrue: [Transcript showln: {#insert. anOwnerMorph. aNumber. aMorph}]
]

{ #category : #testing }
DCCommandScriptGenerator >> logChanges [

^true
]

{ #category : #actions }
DCCommandScriptGenerator >> move: aMorph to: anOwnerMorph postDeleteDo: aBlock [

	| command |
	command := SBMoveCommand new
		shouldMergeWithNext: true;
		container: anOwnerMorph;
		morph: aMorph;
		notePosition.
	aMorph delete.
	command index: aBlock value.
	self editor do: command.
	
	self maybeAttachFlash: aMorph.
	self logChanges ifTrue: [Transcript showln: {#move. anOwnerMorph. aBlock. aMorph}]
]

{ #category : #actions }
DCCommandScriptGenerator >> update: aMorph with: aString [
	"check if we have an active input command for this morph"

	(editor currentInputCommand ifNotNil: #textMorph) = aMorph
		ifTrue: [aMorph contents: aString]
		ifFalse: [
			self editor do: (SBMutatePropertyCommand new
				shouldMergeWithNext: true;
				target: aMorph;
				selector: #contents;
				value: aString)].
	self maybeAttachFlash: aMorph.
	self logChanges ifTrue: [Transcript showln: {#update. aMorph. aString}]
]
