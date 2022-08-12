"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLFunction,
	#superclass : #Object,
	#instVars : [
		'parameterizedString',
		'resultParamIndex',
		'staticResultClass',
		'isAggregateFunction'
	],
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #'instance creation' }
SSWSQLFunction class >> new [

	^super new initialize
]

{ #category : #initializing }
SSWSQLFunction >> beAggregateFunction [

	self isAggregateFunction: true
]

{ #category : #helpers }
SSWSQLFunction >> convertValue: aValue forFunctionField: aFunctionField [

	"Convert the given DB value object to the class of object specified as the result of this function. Return the converted object.

	The result can be of a specified class (staticResultClass) or the class of one of the parameters (the index of which is stored in resultParamIndex).
	The latter is the default, with resultParamIndex being 1"

	^self staticResultClass isNil 
		ifTrue: [(aFunctionField fieldAtIndex: self resultParamIndex) convertValue: aValue]
		ifFalse: [self staticResultClass instanceFromDBValue: aValue in: aFunctionField reStore]
]

{ #category : #initializing }
SSWSQLFunction >> initialize [

	"By default the class of the first parameter (the receiver in the corresponding Smalltalk expression) is the class of the result"
	self resultParamIndex: 1.

	self isAggregateFunction: false
]

{ #category : #accessing }
SSWSQLFunction >> isAggregateFunction [
	^isAggregateFunction
]

{ #category : #accessing }
SSWSQLFunction >> isAggregateFunction: anObject [
	isAggregateFunction := anObject
]

{ #category : #accessing }
SSWSQLFunction >> parameterizedString [
	^parameterizedString
]

{ #category : #accessing }
SSWSQLFunction >> parameterizedString: anObject [
	parameterizedString := anObject
]

{ #category : #accessing }
SSWSQLFunction >> resultParamIndex [
	^resultParamIndex
]

{ #category : #accessing }
SSWSQLFunction >> resultParamIndex: anObject [
	resultParamIndex := anObject
]

{ #category : #accessing }
SSWSQLFunction >> staticResultClass [
	^staticResultClass
]

{ #category : #accessing }
SSWSQLFunction >> staticResultClass: anObject [
	staticResultClass := anObject
]

{ #category : #accessing }
SSWSQLFunction >> targetClassForFunctionField: aFunctionField [

	^self staticResultClass ifNil: [(aFunctionField fieldAtIndex: self resultParamIndex) targetClass]
]
