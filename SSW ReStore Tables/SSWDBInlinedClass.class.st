"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBInlinedClass,
	#superclass : #SSWDBClassWithInfo,
	#instVars : [
		'inlinedClass'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #defining }
SSWDBInlinedClass >> defineAs: aSymbol in: aDBTable [

	aDBTable define: aSymbol asInstVarHoldingInlined: self inlinedClass
]

{ #category : #accessing }
SSWDBInlinedClass >> infoClass [

	^self inlinedClass
]

{ #category : #accessing }
SSWDBInlinedClass >> inlinedClass [
	^inlinedClass
]

{ #category : #accessing }
SSWDBInlinedClass >> inlinedClass: anObject [
	inlinedClass := anObject
]
