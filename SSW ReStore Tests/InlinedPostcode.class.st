"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #InlinedPostcode,
	#superclass : #Object,
	#instVars : [
		'code1',
		'code2'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
InlinedPostcode class >> reStoreDefinition [

	^super reStoreDefinition
		define: #code1 as: (String maxSize: 16);
		define: #code2 as: (String maxSize: 16)
]

{ #category : #comparing }
InlinedPostcode >> = anotherPostcode [

	^(self code1 = anotherPostcode code1) & (self code2 = anotherPostcode code2)
]

{ #category : #accessing }
InlinedPostcode >> code1 [
	^code1
]

{ #category : #accessing }
InlinedPostcode >> code1: anObject [
	code1 := anObject
]

{ #category : #accessing }
InlinedPostcode >> code2 [
	^code2
]

{ #category : #accessing }
InlinedPostcode >> code2: anObject [
	code2 := anObject
]

{ #category : #accessing }
InlinedPostcode >> hash [

	^self code1 hash
]
