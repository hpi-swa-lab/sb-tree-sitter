Class {
	#name : #DCQuery,
	#superclass : #Object,
	#classVars : [
		'Properties'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCQuery class >> addProperty: anObject to: aDomainObject [

	(self properties at: aDomainObject ifAbsentPut: [OrderedCollection new]) add: anObject.
	self checkQueriesFor: aDomainObject domainRoot
]

{ #category : #'as yet unclassified' }
DCQuery class >> checkQueriesFor: aRoot [

	Object allSubclassesDo: [:cls |
		Pragma
			withPragmasIn: cls
			do: [:pragma | pragma keyword = #domainQuery ifTrue: [cls theNonMetaClass perform: pragma selector with: aRoot]]]
]

{ #category : #'as yet unclassified' }
DCQuery class >> does: aDomainObject haveProperty: anObject [

	^ self properties
		at: aDomainObject
		ifPresent: [:properties | properties includes: anObject]
		ifAbsent: [false]
]

{ #category : #'as yet unclassified' }
DCQuery class >> firstScript: aCollectionOfCollections with: anObject [

	aCollectionOfCollections do: [:script | (self script: script with: anObject) ifNotNil: [:res | ^ res]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCQuery class >> match: aClosure with: anObject do: anotherClosure [

	(aClosure value: anObject) ifTrue: [anotherClosure value: anObject].
	anObject domainReferencesDo: [:ref | self match: aClosure with: ref do: anotherClosure]
]

{ #category : #'as yet unclassified' }
DCQuery class >> properties [

	^ Properties ifNil: [Properties := WeakKeyDictionary new]
]

{ #category : #'as yet unclassified' }
DCQuery class >> removeProperty: anObject from: aDomainObject [

	self properties
		at: aDomainObject
		ifPresent: [:properties | properties remove: aDomainObject]
]

{ #category : #'as yet unclassified' }
DCQuery class >> script: aCollection allDeep: anotherCollection [

	^ Array streamContents: [:s | anotherCollection allChildrenDo: [:obj | (self script: aCollection with: obj) ifNotNil: [:res | s nextPut: res]]]
]

{ #category : #'as yet unclassified' }
DCQuery class >> script: aCollection first: anotherCollection [

	anotherCollection do: [:obj | (self script: aCollection with: obj) ifNotNil: [:res | ^ res]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCQuery class >> script: aCollection firstDeep: anotherCollection [

	anotherCollection allChildrenDo: [:obj | (self script: aCollection with: obj) ifNotNil: [:res | ^ res]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCQuery class >> script: aCollection with: anObject [

	| current |
	current := anObject.
	aCollection do: [:block | | res |
		block isCollection
			ifTrue: [
				(self script: block with: current)
					ifNil: [^ nil]
					ifNotNil: [:o | current := o]]
			ifFalse: [
				res := (current isCollection and: [current notEmpty and: [current first = #args]])
					ifTrue: [block valueWithArguments: current allButFirst]
					ifFalse: [block value: current].
				res == nil ifTrue: [^ nil].
				res == false ifTrue: [^ nil].
				res isCollection ifTrue: [
					res ifEmpty: [^ nil].
					res first = #args and: [(res anySatisfy: [:subRes | subRes == nil or: [subRes == false or: [subRes isCollection and: [subRes isEmpty]]]]) ifTrue: [^ nil]]].
				res ~~ true ifTrue: [current := res]]].
	^ current
]
