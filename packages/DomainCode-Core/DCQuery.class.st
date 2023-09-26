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
