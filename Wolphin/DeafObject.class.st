Class {
	#name : #DeafObject,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #Wolphin
}

{ #category : #accessing }
DeafObject class >> current [ 

	^Current ifNil: [ Current := self new ]
]

{ #category : #'reflective operations' }
DeafObject >> = anotherObject [

	^self class = anotherObject class
]

{ #category : #'reflective operations' }
DeafObject >> doesNotUnderstand: aMessage [

	^self
]

{ #category : #'reflective operations' }
DeafObject >> mustBeBoolean [

	^true
]
