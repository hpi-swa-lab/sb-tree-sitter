Class {
	#name : #DCJsTableOfContents,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCJsTableOfContents >> initialize [

	super initialize.
	
	self
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		layoutInset: 4
]
