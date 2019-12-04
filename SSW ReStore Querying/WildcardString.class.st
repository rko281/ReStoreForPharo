"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #WildcardString,
	#superclass : #Object,
	#instVars : [
		'string'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #enumerating }
WildcardString >> collect: aBlock [

	^self string collect: aBlock
]

{ #category : #accessing }
WildcardString >> hash [

	^self string hash
]

{ #category : #testing }
WildcardString >> isEmpty [

	^self size = 0
]

{ #category : #accessing }
WildcardString >> orNilIfEmpty [

	^self isEmpty
		ifTrue: [nil]
		ifFalse: [self]
]

{ #category : #accessing }
WildcardString >> reStoreValue [

	^self string
]

{ #category : #accessing }
WildcardString >> similarityComparator [

	"Private - The receiver is just a String for which the similarity is defined by like:"

	^#matches:
]

{ #category : #accessing }
WildcardString >> size [

	^self string size
]

{ #category : #accessing }
WildcardString >> string [
	^string
]

{ #category : #accessing }
WildcardString >> string: anObject [
	string := anObject
]
