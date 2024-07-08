"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBDumbArgument',
	#superclass : 'Object',
	#classInstVars : [
		'current'
	],
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'accessing' }
SSWDBDumbArgument class >> current [

	^current ifNil: [current := self new]
]

{ #category : 'accessing' }
SSWDBDumbArgument class >> icon [

	^DeafObject icon
]

{ #category : 'initialize' }
SSWDBDumbArgument class >> reset [

	current := nil
]

{ #category : 'accessing' }
SSWDBDumbArgument >> _id [

	"Avoid the superclass implementation"

	^self
]

{ #category : 'exceptions' }
SSWDBDumbArgument >> doesNotUnderstand: aMessage [
	"The receiver is deaf to all requests. Answer the current instance to ensure that our answers are also dumb"
	
	^self class current
]
