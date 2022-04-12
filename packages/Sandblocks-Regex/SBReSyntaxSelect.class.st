"
A SBReSyntaxSelect is a combo box/dropdown menu modified for our needs.

To use this, use value: aCollection, where aCollection is a collection of Associations from a syntax string to a display string:

SBReSyntaxSelect new
	values: {
		'\d' -> 'digit'.
		'[13579]' -> 'odd digit'.
	}

In the dropdown, only the value of each association is shown. The syntax method returns the syntax for the currently selected element, which can also be set using the syntax: method.
"
Class {
	#name : #SBReSyntaxSelect,
	#superclass : #SBSelect,
	#category : #'Sandblocks-Regex'
}
