"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBQueryFieldCollection',
	#superclass : 'SSWSQLFieldCollection',
	#type : 'variable',
	#instVars : [
		'parser'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'converting' }
SSWDBQueryFieldCollection >> asSQLFields [

	"Convert the receiver to the standard non-query subsystem representation"

	| sql |

	sql := SSWSQLFieldCollection new: self size.

	^self inject: sql into: [ :all :each | all add: each asSQLFields; yourself]
]

{ #category : 'accessing' }
SSWDBQueryFieldCollection >> concatenateCondition: aCondition [

	self add: (self parser unprocessedConditionsCombinedWithArgument: aCondition)
]

{ #category : 'parsing - internal' }
SSWDBQueryFieldCollection >> doesNotUnderstand: aMessage [
	
	"Attempt to interpret selector as a function message send"
	(self first table reStore sqlDialect sqlFunctionFor: aMessage selector) ifNotNil: 
		[ :function | 
		^self parser applyFunction: function to: self withArguments: aMessage arguments].

	^super doesNotUnderstand: aMessage
]

{ #category : 'accessing' }
SSWDBQueryFieldCollection >> parser [
	^parser
]

{ #category : 'accessing' }
SSWDBQueryFieldCollection >> parser: anObject [
	parser := anObject
]

{ #category : 'accessing' }
SSWDBQueryFieldCollection >> || anObject [

	^anObject forConcatenation concatenatedWith: self
]
