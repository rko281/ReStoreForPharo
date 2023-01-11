Class {
	#name : #SSWP3Statement,
	#superclass : #P3PreparedStatement,
	#traits : 'SSWReStoreDBStatement',
	#classTraits : 'SSWReStoreDBStatement classTrait',
	#instVars : [
		'values'
	],
	#category : #'SSW ReStore P3'
}

{ #category : #accessing }
SSWP3Statement >> client: aP3Connection [

	client := aP3Connection 
]

{ #category : #'initialize - release' }
SSWP3Statement >> client: aClient name: aString paramDescriptions: pCollection fieldDescriptions: fCollection [

	client := aClient.
	name := aString.
	paramDescriptions := pCollection.
	fieldDescriptions := fCollection
]

{ #category : #'initialize-release' }
SSWP3Statement >> cursoredFetch: aBoolean [

	"Not implemented?"
]

{ #category : #executing }
SSWP3Statement >> execute [

	^(self query: self values) 
		query: self query; 
		yourself

]

{ #category : #testing }
SSWP3Statement >> isFreed [ 
	^client isNil
]

{ #category : #accessing }
SSWP3Statement >> parent [

	^client
]

{ #category : #accessing }
SSWP3Statement >> valueAt: anIndex put: anObject [

	self values at: anIndex put: anObject
]

{ #category : #accessing }
SSWP3Statement >> values [
	^ values ifNil: [ #() ]
]

{ #category : #accessing }
SSWP3Statement >> values: anObject [
	values := anObject collect: [  :each | each reStoreValue ]
]
